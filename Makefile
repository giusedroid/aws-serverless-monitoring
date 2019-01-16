ifeq ($(CIRCLE_BRANCH), master)
	DEPLOY_ENV=stable
else
	DEPLOY_ENV=unstable
endif



backend:
	echo "Deploying Aurora Serverless Backend to $(DEPLOY_ENV)"
	@aws cloudformation deploy \
	--template-file cloudformation/10-aurora-backend.yml \
	--stack-name $(DEPLOY_ENV)-grafana-backend \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
	Environment=$(DEPLOY_ENV) \
	DatabaseAZs=eu-west-1a,eu-west-1b \
	GrafanaDatabaseName=grafana \
	GrafanaDatabaseUser=grafanauser \
	GrafanaDatabasePassword=$(GRAFANA_DATABASE_PASSWORD) \
	--no-fail-on-empty-changeset

backend-local:
	. .secrets/GrafanaDatabasePassword
	. .secrets/aws
	echo "Deploying Aurora Serverless Backend from my machine"
	@aws cloudformation deploy \
	--template-file cloudformation/10-aurora-backend.yml \
	--stack-name local-grafana-backend \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
	Environment=local \
	DatabaseAZs=eu-west-1a,eu-west-1b \
	GrafanaDatabaseName=localgrafana \
	GrafanaDatabaseUser=localgrafanauser \
	GrafanaDatabasePassword=$(GRAFANA_DATABASE_PASSWORD) \
	--no-fail-on-empty-changeset

grafana:
	echo "Deploying Grafana on ECS@Fargate to $(DEPLOY_ENV)"
	@aws cloudformation deploy \
	--stack-name $(DEPLOY_ENV)-grafana-service \
	--template-file cloudformation/20-grafana-ecs-service.yml \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
	Environment=$(DEPLOY_ENV) \
	HostedZone=$(GRAFANA_HOSTED_ZONE) \
	CertificateArn=$(GRAFANA_CERTIFICATE_ARN) \
	GrafanaImage=grafana/grafana:5.4.3 \
	GrafanaServiceDomain=grafana-$(DEPLOY_ENV).$(GRAFANA_DOMAIN) \
	GrafanaDatabaseEngine=mysql \
	GrafanaSessionProviderString="grafanauser:$(GRAFANA_DATABASE_PASSWORD)@tcp(grafana-$(DEPLOY_ENV)-db.$(GRAFANA_DOMAIN):$(GRAFANA_DATABASE_PORT))/grafana" \
	GrafanaDatabaseHost=grafana-$(DEPLOY_ENV)-db.$(GRAFANA_DOMAIN):$(GRAFANA_DATABASE_PORT) \
	GrafanaDatabaseName=grafana \
	GrafanaDatabaseUser=grafanauser \
	GrafanaDatabasePassword=$(GRAFANA_DATABASE_PASSWORD) \
	GrafanaServiceAdminUser=$(GRAFANA_SERVICE_ADMIN_USER) \
	GrafanaServiceAdminPassword=$(GRAFANA_SERVICE_ADMIN_PASSWORD) \
	GoogleAuthClientId=$(GOOGLE_AUTH_CLIENT_ID) \
	GoogleAuthClientSecret=$(GOOGLE_AUTH_CLIENT_SECRET) \
	GoogleAuthAllowedDomains="$(GOOGLE_AUTH_ALLOWED_DOMAINS)" \
	--no-fail-on-empty-changeset

grafana-local:
	. .secrets/aws
	. .secrets/GrafanaService
	echo "Deploying Grafana on ECS@Fargate from local machine"
	aws cloudformation deploy \
	--stack-name $(DEPLOY_ENV)-grafana-service \
	--template-file cloudformation/20-grafana-ecs-service.yml \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
	Environment=$(DEPLOY_ENV) \
	HostedZone=$(GRAFANA_HOSTED_ZONE) \
	CertificateArn=$(GRAFANA_CERTIFICATE_ARN) \
	GrafanaImage=grafana/grafana:5.4.3 \
	GrafanaServiceDomain=grafana-$(DEPLOY_ENV).$(GRAFANA_DOMAIN) \
	GrafanaDatabaseEngine=mysql \
	GrafanaSessionProviderString=grafanauser:$(GRAFANA_DATABASE_PASSWORD)@tcp(grafana-$(DEPLOY_ENV)-db.$(GRAFANA_DOMAIN):$(GRAFANA_DATABASE_PORT))/grafana \
	GrafanaDatabaseHost=grafana-$(DEPLOY_ENV)-db.$(GRAFANA_DOMAIN):$(GRAFANA_DATABASE_PORT) \
	GrafanaDatabaseName=grafana \
	GrafanaDatabaseUser=grafanauser \
	GrafanaDatabasePassword=$(GRAFANA_DATABASE_PASSWORD) \
	GrafanaServiceAdminUser=$(GRAFANA_SERVICE_ADMIN_USER) \
	GrafanaServiceAdminPassword=$(GRAFANA_SERVICE_ADMIN_PASSWORD) \
	GoogleAuthClientId=$(GOOGLE_AUTH_CLIENT_ID) \
	GoogleAuthClientSecret=$(GOOGLE_AUTH_CLIENT_SECRET) \
	GoogleAuthAllowedDomains=$(GOOGLE_AUTH_ALLOWED_DOMAINS) \
	--no-fail-on-empty-changeset

dns-grafana:
	echo "Deploying DNS Records for Grafana Service on $(DEPLOY_ENV)"
	@aws cloudformation deploy \
	--stack-name $(DEPLOY_ENV)-grafana-service-dns \
	--template-file cloudformation/21-dns-grafana.yml \
	--parameter-overrides \
	Environment=$(DEPLOY_ENV) \
	HostedZoneId=$(GRAFANA_HOSTED_ZONE) \
	DomainName=grafana-$(DEPLOY_ENV).$(GRAFANA_DOMAIN) \
	--no-fail-on-empty-changeset

dns-aurora:
	echo "Deploying DNS Records for Aurora on $(DEPLOY_ENV)"
	@aws cloudformation deploy \
	--stack-name $(DEPLOY_ENV)-grafana-db-dns \
	--template-file cloudformation/11-dns-aurora.yml \
	--parameter-overrides \
	Environment=$(DEPLOY_ENV) \
	HostedZoneId=$(GRAFANA_HOSTED_ZONE) \
	DomainName=grafana-$(DEPLOY_ENV)-db.$(GRAFANA_DOMAIN) \
	--no-fail-on-empty-changeset

security:
	echo "Deploying Security and Core Exports on $(DEPLOY_ENV)"
	@aws cloudformation deploy \
	--stack-name $(DEPLOY_ENV)-grafana-security \
	--template-file cloudformation/00-security-and-exports.yml \
	--parameter-overrides \
	Environment=$(DEPLOY_ENV) \
	--no-fail-on-empty-changeset