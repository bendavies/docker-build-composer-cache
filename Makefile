.PHONY: *

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

development: ## Builds the development image needed to run tests etc.
	docker buildx build --load --target=development --tag=ghcr.io/bendavies/docker-build-composer-cache:development .

production: ## Build and tag a production image
	docker buildx build --load --target=production --tag=ghcr.io/bendavies/docker-build-composer-cache:production .