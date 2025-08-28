SHELL := /bin/bash
.DEFAULT_GOAL := help

# Variables
APP_NAME := skill-gap-analysis-tool
DOCKER_IMAGE := $(APP_NAME):latest
DOCKER_COMPOSE_FILE := docker-compose.yml

# Colors for output
RED := \033[0;31m
]
GREEN := \033[0;32m
]
YELLOW := \033[1;33m
]
BLUE := \033[0;34m
]
NC := \033[0m # No Color
]

.PHONY: help build run test lint clean dev docker-build docker-run docker-stop sbom security-scan

help: ## Display this help message
	@echo "$(BLUE)SKILL Gap Analysis Tool - Make Commands$(NC)"
	@echo "========================================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}\' $(MAKEFILE_LIST)

install: ## Install dependencies
	@echo "$(YELLOW)Installing dependencies...$(NC)"
	npm install
	@echo "$(GREEN)Dependencies installed successfully!$(NC)"

dev: ## Start development server
	@echo "$(YELLOW)Starting development server...$(NC)"
	npm run dev

build: ## Build the application for production
	@echo "$(YELLOW)Building application...$(NC)"
	npm run build
	@echo "$(GREEN)Application built successfully!$(NC)"

test: ## Run tests
	@echo "$(YELLOW)Running tests...$(NC)"
	npm test
	@echo "$(GREEN)Tests completed!$(NC)"

lint: ## Run linter
	@echo "$(YELLOW)Running linter...$(NC)"
	npm run lint
	@echo "$(GREEN)Linting completed!$(NC)"

docker-build: ## Build Docker image
	@echo "$(YELLOW)Building Docker image...$(NC)"
	docker build -t $(DOCKER_IMAGE) .
	@echo "$(GREEN)Docker image built: $(DOCKER_IMAGE)$(NC)"

docker-run: ## Run application with Docker Compose
	@echo "$(YELLOW)Starting services with Docker Compose...$(NC)"
	docker-compose -f $(DOCKER_COMPOSE_FILE) up -d
	@echo "$(GREEN)Services started! Frontend: http://localhost:3000$(NC)"

docker-stop: ## Stop Docker Compose services
	@echo "$(YELLOW)Stopping Docker Compose services...$(NC)"
	docker-compose -f $(DOCKER_COMPOSE_FILE) down
	@echo "$(GREEN)Services stopped!$(NC)"

docker-logs: ## View Docker Compose logs
	@echo "$(YELLOW)Viewing Docker Compose logs...$(NC)"
	docker-compose -f $(DOCKER_COMPOSE_FILE) logs -f

sbom: ## Generate Software Bill of Materials
	@echo "$(YELLOW)Generating SBOM...$(NC)"
	@command -v syft >/dev/null 2>&1 || { echo "$(RED)Error: syft is required but not installed.$(NC)" >&2; exit 1; }
	syft packages . -o json > sbom.json
	syft packages . -o table
	@echo "$(GREEN)SBOM generated: sbom.json$(NC)"

security-scan: ## Run security vulnerability scan
	@echo "$(YELLOW)Running security scan...$(NC)"
	npm audit
	@if command -v grype >/dev/null 2>&1; then \
		echo "$(YELLOW)Running container security scan...$(NC)"; \
		grype $(DOCKER_IMAGE) -o table; \
	else \
		echo "$(YELLOW)Note: Install grype for container security scanning$(NC)"; \
	fi
	@echo "$(GREEN)Security scan completed!$(NC)"

clean: ## Clean build artifacts and dependencies
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	rm -rf dist/
	rm -rf node_modules/
	docker system prune -f
	@echo "$(GREEN)Cleanup completed!$(NC)"

run: docker-run ## Alias for docker-run

stop: docker-stop ## Alias for docker-stop

logs: docker-logs ## Alias for docker-logs

# Production deployment targets
deploy-staging: ## Deploy to staging environment
	@echo "$(YELLOW)Deploying to staging...$(NC)"
	@echo "$(RED)Note: Configure your staging deployment process$(NC)"

deploy-prod: ## Deploy to production environment
	@echo "$(YELLOW)Deploying to production...$(NC)"
	@echo "$(RED)Note: Configure your production deployment process$(NC)"

# Health checks
health-check: ## Run application health checks
	@echo "$(YELLOW)Running health checks...$(NC)"
	@curl -f http://localhost:3000/ >/dev/null 2>&1 && echo "$(GREEN)Frontend: OK$(NC)" || echo "$(RED)Frontend: FAIL$(NC)"
	@curl -f http://localhost:8080/health >/dev/null 2>&1 && echo "$(GREEN)API: OK$(NC)" || echo "$(RED)API: FAIL$(NC)"

# Database operations
db-migrate: ## Run database migrations
	@echo "$(YELLOW)Running database migrations...$(NC)"
	@echo "$(RED)Note: Implement your database migration process$(NC)"

db-seed: ## Seed database with sample data
	@echo "$(YELLOW)Seeding database...$(NC)"
	@echo "$(RED)Note: Implement your database seeding process$(NC)"

# Monitoring and observability
metrics: ## View application metrics
	@echo "$(YELLOW)Opening metrics dashboard...$(NC)"
	@command -v open >/dev/null 2>&1 && open http://localhost:9090 || echo "Open http://localhost:9090 in your browser"

all: install lint test build docker-build ## Run full CI/CD pipeline

.PHONY: install dev build test lint docker-build docker-run docker-stop docker-logs sbom security-scan clean run stop logs deploy-staging deploy-prod health-check db-migrate db-seed metrics all