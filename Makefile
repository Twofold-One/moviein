include .envrc

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm 
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## run/api: run the cmd/api application
.PHONY: run/api 
run/api:
	go run ./cmd/api -db-dsn=${MOVIEIN_DB_DSN} -smtp-password=${SMTP_PASSWORD}

## db/psql: connect to the database using psql
.PHONY: db/psql 
db/psql:
	psql ${MOVIEIN_DB_DSN}

## db/migrations/new name=$1: create a new database migration
.PHONY: db/migrations/new 
db/migrations/new:
	@echo 'Creating migration files for ${name}'
	migrate create -seq -ext=.sql -dir=./migrations ${name}

## db/miagratioins/up: apply all up database migrations
.PHONY: db/migrations/up 
db/migrations/up: confirm
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${MOVIEIN_DB_DSN} up

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## audit: tidy and vendor dependencies and format, vet and test all code
.PHONY: audit
audit: vendor
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	/home/twofold_one/go/bin/staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...


## vendor: tidy and vendor dependencies
.PHONY: vendor
vendor:
	@echo 'Tidying and veryfying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

# ==================================================================================== #
# BUILD
# ==================================================================================== #

current_time = ${shell date --iso-8601=seconds}
git_description = ${shell git describe --always --dirty --tags --long}
linker_flags = '-s -X main.buildTime=${current_time} -X main.version=${git_description}'


## build/api: build the cmd/api application
.PHONY: build/api
build/api:
	@echo 'Building cmd/api...'
	go build -ldflags=${linker_flags} -o=./bin/api ./cmd/api
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/api ./cmd/api

# ==================================================================================== #
# PRODUCTION
# ==================================================================================== #

production_host_ip = '193.201.115.198'

## production/connect: connect to the production server
.PHONY: production/connect
production/connect:
	ssh moviein@${production_host_ip}

## production/deploy/api: deploy the api to production
.PHONY: production/deploy/api
production/deploy/api:
	rsync -P ./bin/linux_amd64/api moviein@${production_host_ip}:~
	rsync -rP --delete ./migrations moviein@${production_host_ip}:~
	rsync -P ./remote/production/api.service moviein@${production_host_ip}:~
	rsync -P ./remote/production/Caddyfile moviein@${production_host_ip}:~
	ssh -t moviein@${production_host_ip} '\
	migrate -path ~/migrations -database $$MOVIEIN_DB_DSN up \
	&& sudo mv ~/api.service /etc/systemd/system/ \
	&& sudo systemctl enable api \
	&& sudo systemctl restart api \
	&& sudo mv ~/Caddyfile /etc/caddy/ \
	&& sudo systemctl reload caddy \
	'