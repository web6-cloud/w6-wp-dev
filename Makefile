# Executables (local)
DOCKER_COMP = docker-compose -f docker/docker-compose.yml --env-file .env

# Docker containers
WP_CONTAINER = $(DOCKER_COMP) exec wp

# Misc
.DEFAULT_GOAL = help
.PHONY        = help build up start down sh

## —— 🎵 🐳 The WordPress Base Theme Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

up: ## Start the docker hub in detached mode (no logs)
	@$(DOCKER_COMP) up --detach

start: build up ## Build and start the containers

down: ## Stop the docker hub
	@$(DOCKER_COMP) down --remove-orphans

sh: ## Connect to the WordPress container
	@$(WP_CONTAINER) sh

## —— WordPress Dockerized 🐳 Dev Env ——————————————————————————————————————————

# --- ✨ CONFIG ✨ -------------------------------------------------------------

# Sane defaults
SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Default params
environment ?= "dev"

# Env file
include .env

# Make available to subscripts.
export

# --- ✨ COMMANDS ✨ ------------------------------------------------------------

up: env-Global # 💻 New local dev env
	@echo "Installing.."
	@docker compose pull
	@docker compose up --detach --remove-orphans
	@echo "Done"

down: stop # ⛔ Stop the stack

start: env-Global # 🚀 Start the dev env
	@docker compose start

stop: # ⛔ Stop the stack
	@docker compose stop

prune: check-Confirm # 🗑️ Prune one or more containers / volumes
	@docker compose down -v $(filter-out $@,$(MAKECMDGOALS))

ps: # 🔎 List running containers
	@docker ps --filter name='$(PROJECT_NAME)*'

shell: env-Global # 🩺 Shell access to container (default: php).
	@docker compose exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_$(or $(filter-out $@,$(MAKECMDGOALS)), 'php')' --format "{{ .ID }}") sh

wp: env-Global # 📝 `wp cli` command (no --flag)
	@docker compose exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_php' --format "{{ .ID }}") wp --path=$(WP_ROOT) $(filter-out $@,$(MAKECMDGOALS))

logs: env-Global # 🚩 View logs (add args to select containers)
	@docker compose logs -v $(filter-out $@,$(MAKECMDGOALS))

# --- ✨ ENV CHECKS ✨ --------------------------------------------------------------

env-Global: env-DotEnv env-DbConf env-ProjectConf # [ENV] Performs all env checks at once

env-DbConf: # [ENV] Checks DB related env vars
	@if test -z ${DB_NAME}; then echo -e "${ERR}Missing ENV VAR: DB_NAME in .env file.${NC}"; exit 1; fi
	@if test -z ${DB_USER}; then echo -e "${ERR}Missing ENV VAR: DB_USER in .env file.${NC}"; exit 1; fi
	@if test -z ${DB_PASSWORD}; then echo -e "${ERR}Missing ENV VAR: DB_PASSWORD in .env file.${NC}"; exit 1; fi
	@if test -z ${DB_ROOT_PASSWORD}; then echo -e "${ERR}Missing ENV VAR: DB_ROOT_PASSWORD in .env file.${NC}"; exit 1; fi
	@if test -z ${DB_HOST}; then echo -e "${ERR}Missing ENV VAR: DB_HOST in .env file.${NC}"; exit 1; fi
	@if test -z ${DB_CHARSET}; then echo -e "${ERR}Missing ENV VAR: DB_CHARSET in .env file.${NC}"; exit 1; fi

env-ProjectConf: # [ENV] Checks project related env vars
	@if test -z ${PROJECT_NAME}; then echo -e "${ERR}Missing env var: PROJECT_NAME${NC}"; exit 1; fi
	@if test -z ${PROJECT_BASE_URL}; then echo -e "${ERR}Missing env var: PROJECT_BASE_URL${NC}"; exit 1; fi
	@if test -z ${PROJECT_LANG}; then echo -e "${ERR}Missing env var: PROJECT_LANG${NC}"; exit 1; fi

env-DotEnv: # [ENV] Checks if .env file is present
	@if [ ! -f ".env" ]; then echo -e "${ERR}Missing .env file. Run 'cp .env.example .env'${NC}"; exit 1; fi

# --- ✨ ARGS CHECKS ✨ -------------------------------------------------------------

arg-Target: # [ARG] Checks if param is present: make key=value
	@if [ "$(target)" = "" ]; then echo -e "${ERR}Missing param: target. Use 'make <cmd> arg=value'${NC}"; exit 1; fi

# --- ✨ OTHER CHECKS ✨ ------------------------------------------------------------

check-Confirm: # [CHECK] Simple Y/N confirmation
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ] || (echo "Aborted!" && exit 1)


check-NodeModules: # [CHECK] Checks if /node_modules are present
	@if [ ! -d "node_modules" ]; then echo -e "${ERR}Missing /node_modules. Run npm / yarn install.${NC}"; exit 1; fi

# --- ✨ HELP/DOC ✨ ------------------------------------------------------------

help-WritingCommands: # [HELP] How to write new commands?
	@echo "Add your commands at the end of the command section of this Makefile."

# -----------------------------------------------------------
# CAUTION: If you have a file with the same name as make
# command, you need to add it to .PHONY below, otherwise it
# won't work. E.g. `make run` wouldn't work if you have
# `run` file in pwd.
.PHONY: help

# -----------------------------------------------------------
# -----       (Makefile helpers and decoration)      --------
# -----------------------------------------------------------

.DEFAULT_GOAL := help

# check https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
NC = \033[0m
ERR = \033[31;1m
TAB := '%-20s' # Increase if you have long commands

# tput colors
red := $(shell tput setaf 1)
green := $(shell tput setaf 2)
yellow := $(shell tput setaf 3)
blue := $(shell tput setaf 4)
cyan := $(shell tput setaf 6)
cyan80 := $(shell tput setaf 86)
grey500 := $(shell tput setaf 244)
grey300 := $(shell tput setaf 240)
bold := $(shell tput bold)
underline := $(shell tput smul)
reset := $(shell tput sgr0)

help:
	@printf '\n'
	@printf '    $(underline)$(cyan80)$(bold)Available make commands:$(reset)\n\n'
	@# Print non-check commands with comments
	@grep -E '^([a-zA-Z0-9_-]+\.?)+:.+#.+$$' Makefile \
		| grep -v '^check-' \
		| grep -v '^env-' \
		| grep -v '^arg-' \
		| grep -v '^help' \
		| grep -v '^help-' \
		| grep -v '^doc-' \
		| sed 's/:.*#/: #/g' \
		| awk 'BEGIN {FS = "[: ]+#[ ]+"}; \
		{printf " $(grey500)   make $(reset)$(cyan80)$(bold)$(TAB) $(reset)$(grey300)# %1s$(reset)\n", \
			$$1, $$2}'
	@echo -e "\n    $(underline)$(yellow)$(bold)Helpers/Checks$(reset)\n"
	@grep -E '^([a-zA-Z0-9_-]+\.?)+:.+#.+$$' Makefile \
		| grep -E '^(check|arg|env)-' \
		| sed 's/:.*#/: #/g' \
		| awk 'BEGIN {FS = "[: ]+#[ ]+"}; \
		{printf " $(grey500)   make $(reset)$(yellow)$(bold)$(TAB) $(reset)$(grey300)# %1s$(reset)\n", \
			$$1, $$2}'
	@echo -e "\n    $(underline)$(green)$(bold)Help/Doc$(reset)\n"
	@grep -E '^([a-zA-Z0-9_-]+\.?)+:.+#.+$$' Makefile \
		| grep -E '^(help|doc)-' \
		| sed 's/:.*#/: #/g' \
		| awk 'BEGIN {FS = "[: ]+#[ ]+"}; \
		{printf " $(grey500)   make $(reset)$(green)$(bold)$(TAB) $(reset)$(grey300)# %1s$(reset)\n", \
			$$1, $$2}'
	@echo -e ""

