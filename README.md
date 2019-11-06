# Run Freqtrade on Docker

Easier way to run [freqtrade](https://github.com/freqtrade/freqtrade) on Docker without having to download all the code base.

Example of use would be to clone this repo in a VM running Ubuntu and run the docker command.

### Pre-requisites: docker and make installed 

### 1) Clone project and generate config files
```bash
# Clone repo
git clone github.com/evzpav/run-freqtrade-docker

# Enter project folder
cd run-freqtrade-docker

# This script will create the ~./freqtrade folder with config files there
make init
```

### 2.0) Adjust and add Telegram and Exchange API keys to ~/.freqtrade/config_dry.json and ~/.freqtrade/config_prod.json newly created

### 2.1) Add your strategy file inside the folder ./user_data/strategies

### 3) Download exchange data
```bash
make download-data 
    TIMEFRAME=4h \
    STRATEGY=bbrsi #for production only
```

### 4.0) Run backtest
```bash
make backtest \
    STRATEGY=bbrsi \
    FEE=0.001 \ # 0.1% x 2 (entry and exit)
    TIMERANGE=20180101-20191008 \
    TIMEFRAME=4h \
    CONFIG_FILE=config_dry.json \
    DB_FILE=tradesv3.dryrun.sqlite
```

### 4.1) Plot dataframe chart after backtest
```bash
make plot \
    STRATEGY=bbrsi \
    CONFIG_FILE=config_dry.json \
    DB_FILE=tradesv3.dryrun.sqlite \
    PAIRS='ETH/BTC LTC/BTC' \ #with spaces between pairs
    IND1='bb_lowerband bb_middleband' \ #with spaces between indicators
    IND2=rsi
```

### 4.2) Plot profit charts
```bash
make plot-profit \
    DB_FILE=tradesv3.dryrun.sqlite \
    PAIRS='ETH/BTC LTC/BTC' #with spaces between pairs
```


### 4.3) Add your strategy optmization to ./user_data/hyperopts and run optimization:
```bash
make hyperopt \
    HYPEROPT=bbrsi \
    TIMERANGE=20180101-20191008 \
    ITERATIONS=100 \
    OPT_TARGET=all \
    FEE=0.001
```

### 5) Run bot locally in dry run mode
```bash
make run \
    STRATEGY=bbrsi \
    CONFIG_FILE=config_dry.json  \
    DB_FILE=tradesv3.dryrun.sqlite
```

### 6.0) Run in production mode 
#### This will run the freqtrade bot on docker in the background
```bash
# Create config folder and config file to be copied for production
make init-prod STRATEGY=bbrsi \
    CONFIG_PATH=./config_example.json \
    EXCHANGE_KEY=your_exchange_key \
    EXCHANGE_SECRET=your_exchange_secret \
    TELEGRAM_TOKEN=your_telegram_token \
    TELEGRAM_CHAT_ID=your_telegram_chat_id 

# Edit ~/.freqtrade_$STRATEGY/config_dry_$STRATEGY.json and ~/.freqtrade_$STRATEGY/config_prod_$STRATEGY.json files accordingly

# Run in production
make run-prod STRATEGY=bbrsi DRYRUN=false
```

### 6.1) Stop the docker of freqtrade in production
```bash
make stop-prod STRATEGY=bbrsi
```

### Other commands
```bash
# List timeframes
make timeframes EXCHANGE=bittrex

# List exchanges
make exchanges

```