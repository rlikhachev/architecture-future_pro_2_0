# Task 1. Модульная инфраструктура для нескольких сред

## Структура

```
Task1Advanced/
├── modules/
│   └── vm/
│       ├── versions.tf    # требования к Terraform и провайдеру
│       ├── main.tf        # ресурсы: ВМ + подключаемый диск + сеть (подключение к подсети)
│       ├── variables.tf   # входные параметры модуля
│       └── outputs.tf     # выходы: id ВМ, ip, имя, id диска и др.
├── versions.tf          # требования к Terraform и провайдеру (едины для всех окружений)
├── main.tf              # provider + вызов модуля vm + check-защита окружения
├── variables.tf         # входные параметры окружения (заполняются из tfvars)
├── outputs.tf           # выходы окружения
└── envs/
    ├── dev/             # только terraform.tfvars — параметры окружения разработки
    ├── stage/           # только terraform.tfvars — предпрод
    └── prod/            # только terraform.tfvars — продуктив
```

Код корневых модулей (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`) не дублируется на каждое окружение: он один в корне `Task1Advanced/`, а `envs/<окружение>/` содержит только `terraform.tfvars`. Terraform не поддерживает include-файлы между каталогами, поэтому вместо трёх копий идентичного кода используется один корень + изоляция состояний через workspace (по одному workspace на окружение).

## Что делает модуль

Модуль `modules/vm` создаёт:

1. Подключаемый диск данных (`yandex_compute_disk`) — отдельный ресурс нужного размера и типа;
2. Виртуальную машину (`yandex_compute_instance`) — заданное число ядер, доля vCPU, RAM, загрузочный диск из образа ОС;
3. Сеть — подключение ВМ к подсети через `subnet_id` (`network_interface`), опциональный публичный IP (NAT);
4. SSH-доступ — публичный SSH-ключ размещается в метаданных ВМ.

## Параметры модуля (`modules/vm/variables.tf`)

| Переменная        | Тип          | По умолчанию   | Описание                                            |
|-------------------|--------------|----------------|-----------------------------------------------------|
| `name`            | string       | —              | Имя ВМ и префикс имени диска                        |
| `zone_id`         | string       | —              | Зона доступности                                    |
| `platform_id`     | string       | `standard-v3`  | Платформа ВМ                                        |
| `core_count`      | number       | —              | Количество ядер CPU                                 |
| `core_fraction`   | number       | `100`          | Гарантированная доля vCPU (5/20/25/50/100)          |
| `memory`          | number       | —              | Объём RAM, ГБ                                       |
| `image_id`        | string       | —              | ID образа ОС для загрузочного диска                 |
| `boot_disk_size`  | number       | `10`           | Размер загрузочного диска, ГБ                       |
| `boot_disk_type`  | string       | `network-ssd`  | Тип загрузочного диска                              |
| `disk_size`       | number       | —              | Размер подключаемого диска данных, ГБ               |
| `disk_type`       | string       | `network-hdd`  | Тип подключаемого диска                             |
| `subnet_id`       | string       | —              | ID подсети для подключения ВМ                       |
| `nat_enabled`     | bool         | `false`        | Публичный IP (NAT)                                  |
| `ssh_user`        | string       | `ubuntu`       | Пользователь SSH                                    |
| `ssh_key`         | string       | —              | Публичный SSH-ключ                                  |
| `preemptible`     | bool         | `false`        | Прерываемая ВМ (дешевле, для dev/test)              |
| `labels`          | map(string)  | `{}`           | Метки ресурсов                                      |

## Выходы модуля (`modules/vm/outputs.tf`)

| Выход          | Описание                                        |
|----------------|-------------------------------------------------|
| `vm_id`        | ID виртуальной машины                           |
| `vm_name`      | Имя виртуальной машины                          |
| `vm_ip`        | Внутренний (private) IP-адрес                   |
| `vm_public_ip` | Публичный NAT IP (пусто, если NAT отключён)     |
| `vm_fqdn`      | FQDN ВМ                                         |
| `disk_id`      | ID подключаемого диска данных                   |

## Отличия окружений

| Параметр                | dev                  | stage           | prod             |
|-------------------------|----------------------|-----------------|------------------|
| `core_count`            | 2                    | 4               | 8                |
| `core_fraction`         | 20                   | 100             | 100              |
| `memory`, ГБ             | 2                    | 8               | 32               |
| `disk_size` / тип       | 10 / network-hdd     | 30 / network-ssd| 100 / network-ssd|
| `preemptible`           | true                 | false           | false            |
| `nat_enabled`           | true                 | true            | false            |

## Запуск

### 1. Аутентификация

Учётные данные в коде и `.tfvars` НЕ хранятся. Задайте их через переменные окружения:

```bash
export YC_TOKEN="ваш OAuth/IAM-токен"       # или сервисный аккаунт:
export YC_SA_KEY_FILE="/path/to/sa-key.json"
```

### 2. Реальные ID

`cloud_id`, `folder_id`, `subnet_id`, `image_id` уже проставлены в `envs/*/terraform.tfvars` (одинаковые для всех окружений — рабочий каталог и одна подсеть), `ssh_key` — публичный ключ из `certs/`. Секреты (токены, приватные ключи) в tfvars не хранятся.

### 3. Применение для каждого окружения

Все команды выполняются из корня `Task1Advanced/`. Каждое окружение — отдельный workspace, состояние изолированы (`terraform.tfstate.d/<workspace>/`). Пара workspace ↔ tfvars контролируется check-блоком `workspace_matches_env`: если выбрать tfvars не того окружения, plan/apply завершится ошибкой.

```bash
terraform init

# DEV
terraform workspace new dev 2>/dev/null || terraform workspace select dev
terraform plan  -var-file=envs/dev/terraform.tfvars
terraform apply -var-file=envs/dev/terraform.tfvars

# STAGE
terraform workspace new stage 2>/dev/null || terraform workspace select stage
terraform apply -var-file=envs/stage/terraform.tfvars

# PROD
terraform workspace new prod 2>/dev/null || terraform workspace select prod
terraform apply -var-file=envs/prod/terraform.tfvars
```

Проверка состояния после применения:

```bash
terraform workspace show    # активное окружение
terraform output            # vm_id, vm_ip, vm_name, disk_id и др.
```

Удаление ресурсов окружения: `terraform destroy -var-file=envs/<окружение>/terraform.tfvars` (в соответствующем workspace).

### 4. Статические проверки

```bash
terraform fmt -check -recursive
terraform init -backend=false && terraform validate
```
