# Task 2. CI/CD и удалённое хранение состояния Terraform
## Структура

```
Task2Advanced/
├── .github/
│   └── workflows/
│       └── terraform.yml          # pipeline: init -> plan -> apply (manual/approval)
├── bootstrap/
│   ├── docker-compose.minio.yml   # альтернатива: локальный MinIO для состояния
│   └── terraform/                 # bootstrap-стек: бакет+SA+ключи в YOS (state локальный)
├── modules/
│   └── vm/                        # модуль ВМ (копия из Task1Advanced)
├── backend.tf                       # единый backend s3: бакет + workspace_key_prefix envs + lock
├── main.tf                          # provider + модуль vm + check workspace<->tfvars
├── variables.tf / outputs.tf / versions.tf
└── envs/
    ├── dev/                         # только terraform.tfvars
    ├── stage/                       # только terraform.tfvars
    └── prod/                        # только terraform.tfvars
```

Код окружений не дублируется: один корневой модуль, окружение выбирается workspace (`dev`/`stage`/`prod`), параметры — парным `envs/<env>/terraform.tfvars` (тот же приём, что в Task1Advanced; Terraform не поддерживает include файлов между каталогами).

## Удалённое состояние (backend S3)

Backend `s3` объявлен один раз в корневом `backend.tf`; нативная поддержка workspaces в S3-бэкенде раскладывает состояния по ключам:

- endpoint не хардкодится — задаётся переменной окружения `AWS_ENDPOINT_URL_S3`
  (YOS `https://storage.yandexcloud.net` — основной вариант; локальный MinIO
  `http://localhost:9000` — альтернатива, см. `make t2-init-minio`);
- учётные данные — `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` из переменных окружения
  (в CI — секреты), в коде не хранятся; для YOS — статические ключи сервисного аккаунта,
  созданного bootstrap-стеком (см. ниже);
- изоляция окружений — `workspace_key_prefix = "envs"`: состояние workspace'а хранится по
  пути `envs/<workspace>/terraform.tfstate`, т.е. собственный ключ на окружение (`envs/dev/…`,
  `envs/stage/…`, `envs/prod/…`);
- блокировка состояния — `use_lockfile = true`: нативные S3-lock-файлы (`*.tflock`) через
  conditional writes; DynamoDB не требуется (MinIO поддерживает с RELEASE.2024-11-07,
  YOS/AWS S3 — также). Lock создаётся на каждый workspace-ключ, т.е. блокировка per-env;
  параллельные apply разных пайплайнов исключаются;
- версионирование бакетов включается bootstrap-скриптом — защита от случайной
  перезаписи/удаления состояния.

## Скрипты и команды (детально)

### 1. `bootstrap/terraform/` — бакет состояния в Yandex Object Storage

Одноразовый bootstrap-стек (в собственном каталоге, чтобы не зависеть от
удалённого состояния): создаёт в YOS приватный бакет с версионированием, сервисный аккаунт,
статические ключи и `storage.editor` на бакет. Его состояние — локальное (`backend "local"`).

```bash
make t2-bootstrap-apply    # YC_TOKEN + TF_VAR_folder_id из .env
make t2-bootstrap-outputs  # bucket / access_key_id / access_key_secret (sensitive)
```

Outputs подставляются в `.env` (`AWS_*`) и согласованы с `backend.tf` (имя бакета).
Удаление — `make t2-bootstrap-destroy` (сначала `terraform destroy` окружений в backend).

### 2. `bootstrap/docker-compose.minio.yml` — альтернатива: локальный MinIO

```bash
cd Task2Advanced
docker compose -f bootstrap/docker-compose.minio.yml up -d
```

Что делает:

- сервис `minio` — поднимает S3-совместимый сервер (API `:9000`, веб-консоль `:9001`),
  данные на томе `minio-data`; креды — из переменных `MINIO_ROOT_USER`/`MINIO_ROOT_PASSWORD`
  (по умолчанию `minioadmin/minioadmin` — только для локальной разработки);
- сервис `createbuckets` — одноразовый init-контейнер на `mc`: ждёт healthcheck MinIO,
  создаёт бакет `future20-tfstate-b1g*********` (все окружения, ключи `envs/<env>/…`),
  включает на нём версионирование и завершается.

Остановка: `docker compose -f bootstrap/docker-compose.minio.yml down [-v — удалить данные]`.

### 3. Локальный прогон окружения

```bash
# креды (YC_TOKEN, AWS_*), ID (TF_VAR_*) — в .env; Makefile экспортирует их автоматически
make t2-bootstrap-apply                     # бакет в YOS (однократно)
make t2-init                                # backend подключён (для MinIO: t2-minio-up + t2-init-minio)
make t2-plan  ENV=dev                       # TF_WORKSPACE=dev + envs/dev/terraform.tfvars
make t2-apply ENV=dev
make t2-output ENV=dev
```

Несостыковка «workspace ↔ tfvars» отсекается check-блоком `workspace_matches_env` в `main.tf`:
если активен workspace `dev`, а передан `envs/prod/terraform.tfvars`, plan/apply завершится ошибкой.

### 4. Pipeline `.github/workflows/terraform.yml` (GitHub Actions)

Файл — артефакт задания; для активации скопируйте его в `.github/workflows/` корня репозитория

Триггеры

| Событие             | Что выполняется                                                |
|---------------------|----------------------------------------------------------------|
| `push` в `main`     | только `plan` для dev — обратная связь без изменения инфраструктуры |
| `workflow_dispatch` | `plan` + `apply` выбранного окружения (dev/stage/prod) — «по кнопке» |

Jobs

1. `plan`:
   - `actions/checkout` — исходники;
   - `hashicorp/setup-terraform` — фиксированная версия Terraform (`TF_VERSION`);
   - `terraform fmt -check -recursive` — gate на форматирование;
   - `terraform init -input=false` — подключение удалённого backend S3 (endpoint/ключи — из секретов окружения);
   - `terraform validate` — gate на валидность;
   - окружение задаётся двумя связанными значениями: `TF_WORKSPACE=<env>` (workspace выбирается,
     а при отсутствии создаётся автоматически) и `-var-file=envs/<env>/terraform.tfvars` — а check-блок
     `workspace_matches_env` не даёт применить tfvars не того окружения;
   - `terraform plan -out=tfplan` — план фиксируется в файл;
   - `upload-artifact` — бинарный план передаётся в job apply (apply применяет ровно reviewed-план).
2. `apply` (только `workflow_dispatch`, `needs: plan`):
   - `download-artifact` — получает `tfplan` из job plan (тот же workspace из `TF_WORKSPACE`);
   - `terraform init` — то же удалённое состояние;
   - `terraform apply tfplan` — применение утверждённого плана без повторных запросов.

Approval / «по кнопке»: job `apply` объявлен с `environment: <env>`. Для `stage`/`prod`
в настройках репозитория (Settings → Environments) включаются Required reviewers —
job стартует только после явного подтверждения. Дополнительно сам запуск — ручной
(`workflow_dispatch`), что и является «кнопкой».

Изоляция и переменные (Settings → Environments → dev/stage/prod)

| Тип       | Имя                   | Назначение                                          |
|-----------|-----------------------|-----------------------------------------------------|
| Secret    | `YC_TOKEN`            | IAM-токен / доступ в облако (у каждого окружения свой SA) |
| Secret    | `AWS_ACCESS_KEY_ID`   | доступ к хранилищу состояния (для prod — отдельный ключ) |
| Secret    | `AWS_SECRET_ACCESS_KEY` | —                                                 |
| Secret    | `AWS_ENDPOINT_URL_S3` | endpoint S3-совместимого хранилища                  |
| Variable  | `YC_CLOUD_ID`         | подставляется как `TF_VAR_cloud_id`                 |
| Variable  | `YC_FOLDER_ID`        | `TF_VAR_folder_id` (свой каталог на окружение)      |
| Variable  | `YC_SUBNET_ID`        | `TF_VAR_subnet_id`                                  |
| Variable  | `YC_IMAGE_ID`         | `TF_VAR_image_id`                                   |

Секреты/переменные привязаны к конкретному GitHub Environment, поэтому job dev физически
не видит кредов prod. `TF_VAR_*` (GitHub Variables) перекрывают значения `terraform.tfvars` —
учётные данные в репозиторий не попадают.

Concurrency: `group: terraform-<env>` — только один pipeline на окружение одновременно
(защита от гонок за lock состояния).

## Безопасность

- состояние только в удалённом хранилище; `*.tfstate*` в `.gitignore`, в git не попадает;
- секреты — исключительно GitHub Secrets по окружениям; в коде/`.tfvars` только
  несекретные идентификаторы (cloud/folder/subnet/image, публичные SSH-ключи);
- least privilege: отдельный сервисный аккаунт облака и отдельный ключ хранилища на окружение,
  у prod-ключа доступ только к префиксу `envs/prod/*` бакета состояния (в homework-конфигурации
  bootstrap создаёт один SA с `storage.editor` на каталог — разделение ключей по окружениям
  остаётся требованием к боевому CI);
- версионирование бакетов + S3-lock (`use_lockfile`) — целостность состояния;
- apply только вручную и только утверждённым планом (артефакт из job plan), для prod — approval;
- `permissions: contents: read` — минимальные права для самого workflow;
- прод-инфраструктура отделена: свой ключ состояния `envs/prod/…`, другой каталог облака
  (`TF_VAR_folder_id`), другие креды, approval на apply.

## Проверки

```bash
terraform fmt -check -recursive                        # OK (весь Task2Advanced)
terraform init -backend=false && terraform validate    # OK (корневой модуль)

# живой Yandex Object Storage:
make t2-bootstrap-apply      # бакет+SA+ключи+storage.editor созданы в каталоге
make t2-init                 # backend s3 подключён к YOS (virtual-hosted)
terraform workspace list     # листинг envs/ префикса с реального бакета — OK
make t2-plan ENV=dev         # план против живого облака: 2 to add (диск+ВМ), apply не выполнялся

```
