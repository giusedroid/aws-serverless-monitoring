ifeq ($(CIRCLE_BRANCH), master)
	DEPLOY_ENV=stable
else
	DEPLOY_ENV=$(CIRCLE_BRANCH)
endif

backend:
	echo "Deploying Aurora Serverless Backend to $(DEPLOY_ENV)"
	@aws cloudformation deploy \
	--template-file cloudformation/10-aurora-backend.yml \
	--stack-name $(DEPLOY_ENV)-grafana-backend \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
	Environment=$(DEPLOY_ENV) \
	DatabaseAZs=eu-west-1a,eu-west-1b,eu-west-1c \
	GrafanaDatabaseName=$(DEPLOY_ENV)-grafana-backend \
	GrafanaDatabaseUser=$(DEPLOY_ENV)-grafana-user \
	GrafanaDatabasePassword=$(GRAFANA_DATABASE_PASSWORD) \
	--no-fail-on-empty-changeset

backend-local:
	source .secrets/GrafanaDatabasePassword
	source .secrets/aws
	echo "Deploying Aurora Serverless Backend from my machine"
	@aws cloudformation deploy \
	--template-file cloudformation/10-aurora-backend.yml \
	--stack-name local-grafana-backend \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
	Environment=local \
	DatabaseAZs=eu-west-1a,eu-west-1b \
	GrafanaDatabaseName=local-grafana-backend \
	GrafanaDatabaseUser=local-grafana-user \
	GrafanaDatabasePassword=$(GRAFANA_DATABASE_PASSWORD) \
	--no-fail-on-empty-changeset
