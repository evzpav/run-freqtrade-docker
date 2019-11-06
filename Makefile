.DEFAULT_GOAL := help 

DB_FILE      		 = tradesv3.dryrun.sqlite
CONFIG_FILE  		 = config_dry.json
IND2				 = volume
TIMEFRAME   		 = 1h
EXCHANGE			 = binance
FEE	        		 = 0.001 # 0.1%
TIMERANGE     		 = 20180101-
ITERATIONS   		 = 100
OPT_TARGET   		 = all
name				 = run-freqtrade-docker
folder				 = .freqtrade
backtest_result_path = /freqtrade/user_data/backtest_results
backtest_file		 = backtest_results_$(STRATEGY)_$(TIMEFRAME).json
docker_param 		 = --rm

init: ## creates initial config files
	./scripts/generate_configs.sh

image: ## generate docker image with plot lib
	docker build -t $(name) ./docker

run: image ## basic docker command to run the bot
	docker run \
		$(docker_param) \
		--name ${name} \
		-v /etc/timezone:/etc/timezone:ro \
	 	-v ~/$(folder)/$(CONFIG_FILE):/freqtrade/config.json \
		-v ~/$(folder)/user_data/:/freqtrade/user_data \
		-v $(PWD)/user_data/strategies:/freqtrade/user_data/strategies \
		-v $(PWD)/user_data/hyperopts:/freqtrade/user_data/hyperopts \
		-v ~/$(folder)/$(DB_FILE):/freqtrade/$(DB_FILE) \
		-it $(name) \
		-c /freqtrade/config.json \
		--db-url sqlite:///$(DB_FILE) \
		${PARAMS} 

init-prod: ## creates initial config files for specific strategy
	./scripts/check_set_var.sh $(STRATEGY)
	./scripts/generate_configs.sh $(STRATEGY) $(CONFIG_PATH) $(EXCHANGE_KEY) $(EXCHANGE_SECRET) $(TELEGRAM_TOKEN) $(TELEGRAM_CHAT_ID)

run-prod: ## run strategy in production: STRATEGY and DRYRUN needed
	./scripts/check_set_var.sh $(STRATEGY)
	./scripts/run_prod.sh $(STRATEGY) $(DRYRUN)

stop-prod: ## stop container that is running in production
	./scripts/check_set_var.sh $(STRATEGY)
	docker stop freqtrade_$(STRATEGY)

run-in-background: ## run in the background for production
	./scripts/check_set_var.sh $(STRATEGY)
	make run \
		docker_param='-d --restart always' \
		folder=.freqtrade_$(STRATEGY) \
		name=freqtrade_$(STRATEGY) \
		PARAMS='--strategy=$(STRATEGY)'

download-data: ## download data
	./scripts/download_data.sh $(EXCHANGE) $(TIMEFRAME) $(STRATEGY)

timeframes: ## list timeframes
	make run \
		PARAMS='list-timeframes --exchange=$(EXCHANGE)'

exchanges: ## list exchanges
	make run \
		PARAMS='list-exchanges --one-column'

backtest: ## run backtests
	./scripts/check_set_var.sh $(STRATEGY)
	make run \
		PARAMS='backtesting --strategy=$(STRATEGY) \
		--export trades --export-filename=$(backtest_result_path)/$(backtest_file) \
		--fee $(FEE) --ticker-interval $(TIMEFRAME) --timerange=$(TIMERANGE)' 

plot: ## plot-dataframe chart and open in firefox
	./scripts/check_set_var.sh $(STRATEGY)
	./scripts/check_set_var.sh $(PAIRS)
	make run \
		PARAMS='--strategy=$(STRATEGY) plot-dataframe \
			--export trades --export-filename=$(backtest_result_path)/$(backtest_file) --trade-source=file \
			--pairs ${PAIRS}  --indicators1 ${IND1} --indicators2 ${IND2}'	
	firefox ~/$(folder)/user_data/plot/

plot-profit: ## plot profit charts
	make run \
		PARAMS='plot-profit  \
			--export trades --export-filename=$(backtest_result_path)/$(backtest_file) \
			--pairs ${PAIRS} --trade-source file'	
	firefox ~/$(folder)/user_data/plot/

hyperopt: ## run optmization
	./scripts/check_set_var.sh $(HYPEROPT)
	make run \
		PARAMS='hyperopt --customhyperopt=$(HYPEROPT) --epochs=$(ITERATIONS) \
		--spaces $(OPT_TARGET) --fee $(FEE) --timerange=$(TIMERANGE) --print-json' 

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'