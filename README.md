# architecture-future_pro_2_0
Учебный проект спринта 11, кейс «Будущее 2.0». 
Результаты заданий — в директориях `Task1Advanced` … `Task5Advanced`.

## Оглавление

### Task 1 — Модульная инфраструктура для нескольких сред (`Task1Advanced/`)

- [README модуля и окружений](Task1Advanced/README.md)
- [modules/vm/main.tf — ВМ + диск + сеть](Task1Advanced/modules/vm/main.tf)
- [modules/vm/variables.tf — входные параметры](Task1Advanced/modules/vm/variables.tf)
- [modules/vm/outputs.tf — выходы модуля](Task1Advanced/modules/vm/outputs.tf)
- [envs/dev/terraform.tfvars](Task1Advanced/envs/dev/terraform.tfvars)
- [envs/stage/terraform.tfvars](Task1Advanced/envs/stage/terraform.tfvars)
- [envs/prod/terraform.tfvars](Task1Advanced/envs/prod/terraform.tfvars)

### Task 2 — CI/CD и удалённое хранение состояния (`Task2Advanced/`)

- [README — скрипты и pipeline](Task2Advanced/README.md)
- [backend.tf — backend S3: состояние по ключам envs/<workspace>/ + блокировка](Task2Advanced/backend.tf)
- [main.tf — единый корневой модуль (workspace на окружение + check-guard)](Task2Advanced/main.tf)
- [envs/dev/terraform.tfvars](Task2Advanced/envs/dev/terraform.tfvars) · [envs/stage/terraform.tfvars](Task2Advanced/envs/stage/terraform.tfvars) · [envs/prod/terraform.tfvars](Task2Advanced/envs/prod/terraform.tfvars)
- [.github/workflows/terraform.yml — init → plan → apply (approval)](Task2Advanced/.github/workflows/terraform.yml)
- [bootstrap/docker-compose.minio.yml — локальный MinIO](Task2Advanced/bootstrap/docker-compose.minio.yml)

### Task 3 — Целевая архитектура (C4) и оценка рисков (`Task3Advanced/`)

- [C4 Container (горизонт 3 года)](Task3Advanced/c4-container.md) · [PNG](Task3Advanced/diagrams/c4-container.png)
- [C4 Component — портал самообслуживания](Task3Advanced/c4-component.md) · [PNG](Task3Advanced/diagrams/c4-component.png)
- [Карта рисков (вероятность × влияние)](Task3Advanced/risk-map.md)
- [План управления рисками](Task3Advanced/risk-management-plan.md)

### Task 4 — Моделирование домена и интеграций (`Task4Advanced/`)

- [Bounded contexts (DDD)](Task4Advanced/bounded-contexts.md)
- [Event Storming](Task4Advanced/event-storming.md)
- [Агрегаты (границы, инварианты, ключи)](Task4Advanced/aggregates.md)
- [Каталог доменных событий](Task4Advanced/events.md)
- [Обоснование событийного подхода vs Camel/DWH](Task4Advanced/justification.md)

### Task 5 — Технологический стек и стоимость (`Task5Advanced/`)

- [Технический радар (технологии + паттерны)](Task5Advanced/tech-radar.md)
- [TCO-анализ as-is / to-be, 3 года](Task5Advanced/tco-analysis.md)
- [Роадмап внедрения Data Mesh](Task5Advanced/roadmap.md)
