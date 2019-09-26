.DEFAULT_GOAL := help 

DOCKER_PARAM = --rm
DB_FILE      = tradesv3.dryrun.sqlite
CONFIG_FILE  = config_dry.json
NAME=freqtrade

init: ## creates initial config files
	./init_config.sh

run: ## basic docker command to run the bot
	docker run \
		$(DOCKER_PARAM) \
		--name ${NAME} \
		-v /etc/timezone:/etc/timezone:ro \
	 	-v ~/.freqtrade/$(CONFIG_FILE):/freqtrade/config.json \
		-v ~/.freqtrade/$(DB_FILE):/freqtrade/$(DB_FILE) \
		-v $(PWD)/strategies:/freqtrade/user_data/strategies \
		-it freqtradeorg/freqtrade:latest \
		--db-url sqlite:///$(DB_FILE) \
		--strategy=$(STRATEGY) \
		${PARAMS}

run-prod: ## run in production in the background
	make run \
	DOCKER_PARAM=-d \
	NAME=freqtrade_prod

run-backtest: ## run backtests
	make run \
	PARAMS='backtesting --refresh-pairs-cached'

stop-prod: ## stop container that is running in production
	docker stop freqtrade_prod

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'