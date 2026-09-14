T1  := Task1Advanced
T2  := Task2Advanced
ENV ?= dev
TF  := terraform

-include .env
export

TF_CLI_CONFIG_FILE ?= $(CURDIR)/.tmp/tf-cli.tfrc
override TF_CLI_CONFIG_FILE := $(abspath $(TF_CLI_CONFIG_FILE))

ifeq ($(filter dev stage prod,$(ENV)),)
$(error ENV=$(ENV) — допустимы dev|stage|prod)
endif

WS       = TF_WORKSPACE=$(ENV)
VARFILE  = -var-file=envs/$(ENV)/terraform.tfvars

.DEFAULT_GOAL := help

.PHONY: help fmt t1-init t1-validate t1-plan t1-apply t1-output t1-destroy \
        t2-init t2-validate t2-plan t2-apply t2-output t2-destroy \
        t2-minio-up t2-minio-down

help: ## список команд
	@grep -hE '^[a-z0-9-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  %-15s %s\n", $$1, $$2}'

fmt: ## отформатировать весь terraform-код заданий
	$(TF) fmt -recursive $(T1) $(T2)

t1-init: ## Task1: init (локальное состояние)
	cd $(T1) && $(TF) init -input=false

t1-validate: ## Task1: init -backend=false + validate
	cd $(T1) && $(TF) init -backend=false -input=false >/dev/null && $(TF) validate

t1-plan: ## Task1: plan для ENV (make t1-plan ENV=stage)
	cd $(T1) && $(WS) $(TF) plan -input=false $(VARFILE)

t1-apply: ## Task1: apply для ENV
	cd $(T1) && $(WS) $(TF) apply -input=false $(VARFILE)

t1-output: ## Task1: outputs для ENV
	cd $(T1) && $(WS) $(TF) output

t1-destroy: ## Task1: destroy ресурсов ENV
	cd $(T1) && $(WS) $(TF) destroy -input=false $(VARFILE)

t2-minio-up: ## Task2: поднять локальный MinIO (альтернатива YOS для состояния)
	docker compose -f $(T2)/bootstrap/docker-compose.minio.yml up -d --wait

t2-minio-down: ## Task2: остановить локальный MinIO
	docker compose -f $(T2)/bootstrap/docker-compose.minio.yml down

t2-bootstrap-apply: ## Task2 bootstrap: создать бакет+SA+ключи в YOS (state бутстрапа локальный)
	cd $(T2)/bootstrap/terraform && $(TF) init -input=false >/dev/null && $(TF) apply -input=false -auto-approve

t2-bootstrap-outputs: ## Task2 bootstrap: outputs (имя бакета, ключи для .env)
	cd $(T2)/bootstrap/terraform && $(TF) output

t2-bootstrap-destroy: ## Task2 bootstrap: удалить бакет+SA+ключи (состояние в бакете сначала!)
	cd $(T2)/bootstrap/terraform && $(TF) destroy -input=false

t2-init: ## Task2: init с удалённым backend (YOS; бакет из make t2-bootstrap-apply)
	cd $(T2) && $(TF) init -input=false

t2-init-minio: ## Task2: init для локального MinIO (override use_path_style=true)
	cd $(T2) && $(TF) init -input=false -backend-config="use_path_style=true"

t2-validate: ## Task2: init -backend=false + validate
	cd $(T2) && $(TF) init -backend=false -input=false >/dev/null && $(TF) validate

t2-plan: ## Task2: plan для ENV (state envs/$(ENV)/ из S3)
	cd $(T2) && $(WS) $(TF) plan -input=false $(VARFILE)

t2-apply: ## Task2: apply для ENV
	cd $(T2) && $(WS) $(TF) apply -input=false $(VARFILE)

t2-output: ## Task2: outputs для ENV
	cd $(T2) && $(WS) $(TF) output

t2-destroy: ## Task2: destroy ресурсов ENV
	cd $(T2) && $(WS) $(TF) destroy -input=false $(VARFILE)
