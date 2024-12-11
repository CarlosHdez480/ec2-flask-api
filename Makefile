include .env

TF_PLAN := tfplan
TF_PLAN_BACKEND := tfplan_backend

INFRA_DIR := infra
INFRA_DIR_BACKEND := infra_backend

BUCKET_CONFIG := -backend-config="bucket=$(BUCKET_BACKEND)"


## Poetry methods

init-poetry:
	@poetry init \
	--name ec2-flask-api \
	--description $(DESCRIPTION_PROJECT) \
	--author $(AUTHOR) \
	--python $(PYTHON_VERSION) \
	--dependency flask \
	--dependency gunicorn

dev-poetry:
	@poetry config virtualenvs.in-project true
	@poetry install

recreate-poetry:
	@make destroy
	@poetry env use ${PYTHON_PATH}
	@poetry config virtualenvs.in-project true
	@poetry install

destroy-poetry:
	@poetry env info -p
	@del /f /s /q .venv 1>nul
	@rmdir /s /q .venv
	@del /s /q poetry.lock


## Python methods
app:
	@poetry run python src/api.py

## Docker

build:
	@docker build -t $(CONTAINER_NAME) .

run:
	@docker run -d -p 5000:5000 --name $(CONTAINER_NAME) $(CONTAINER_NAME)

delete:
	@docker rm $(CONTAINER_NAME)

debug:
	@docker run -it --entrypoint /bin/bash $(CONTAINER_NAME)

local-compose:
	@docker-compose up --build -d

down-compose:
	@docker-compose down

## Terraform methods

init-back:
	@echo "Generating init backend"
	@cd $(INFRA_DIR_BACKEND) && \
	terraform init
	@echo "Generated init backend"

plan-back:
	@echo "Generating plan backend"
	@cd $(INFRA_DIR_BACKEND) && \
	terraform plan \
	-out=$(TF_PLAN) \
	-input=false \
	-var="repository_name=$(ECR_REPOSITORY_NAME)" \
	-var="bucket_backend=$(BUCKET_BACKEND)"
	@echo "Generated plan backend"

deploy-back:
	@echo "Generating deploy backend"
	@cd $(INFRA_DIR_BACKEND) && \
	terraform apply \
	-auto-approve \
	-var="repository_name=$(ECR_REPOSITORY_NAME)" \
	-var="bucket_backend=$(BUCKET_BACKEND)"
	@echo "Generated deploy backend"

destroy-back:
	@echo "Destroying infra backend"
	@cd $(INFRA_DIR_BACKEND) && \
	terraform destroy \
	-var="repository_name=$(ECR_REPOSITORY_NAME)" \
	-var="bucket_backend=$(BUCKET_BACKEND)"
	@echo "Destroying infra backend"


init:
	@echo "Generating plan"
	@cd $(INFRA_DIR) && \
	terraform init $(BUCKET_CONFIG) -reconfigure
	@echo "Generated plan"

plan:
	@echo "Generating plan"
	@cd $(INFRA_DIR) && \
	terraform plan \
	-out=$(TF_PLAN)  \
	-input=false \
	-var="repository_name=$(ECR_REPOSITORY_NAME)" \
	-var="bucket_backend=$(BUCKET_BACKEND)"
	@echo "Generated plan"

deploy:
	@echo "Deploying infra"
	@cd $(INFRA_DIR) && \
	terraform apply \
	-auto-approve \
	-var="repository_name=$(ECR_REPOSITORY_NAME)" \
	-var="bucket_backend=$(BUCKET_BACKEND)"
	@echo "Deployed infra"

destroy:
	@echo "Destroying infra"
	@cd $(INFRA_DIR) && \
	terraform destroy \
	-var="repository_name=$(ECR_REPOSITORY_NAME)" \
	-var="bucket_backend=$(BUCKET_BACKEND)"
	@echo "Destroying infra"

format:
	@echo "Formatting code"
	@terraform fmt -recursive
	@echo "Code formatted"


## AWS methods

identity:
	@aws sts get-caller-identity

update-kube:
	@aws eks update-kubeconfig --name my-eks-cluster --region us-east-1

## AWS ECR

deploy-image:
	@docker build -t $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com/$(ECR_REPOSITORY_NAME):latest .
	@aws ecr get-login-password --region $(AWS_DEFAULT_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com
	@docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com/$(ECR_REPOSITORY_NAME):latest


## Clean

clean:
	@cd $(INFRA_DIR) && \
	del /f /s /q .terraform 1>nul && \
	rmdir /s /q .terraform && \
	del /s /q .terraform.lock.hcl

clean-back:
	cd $(INFRA_DIR_BACKEND) && \
	del /f /s /q .terraform 1>nul && \
	rmdir /s /q .terraform && \
	del /s /q .terraform.lock.hcl && \
	del /s /q tfplan && \
	del /s /q terraform.tfstate && \
	del /s /q terraform.tfstate.backup