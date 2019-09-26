# Run Freqtrade on Docker

Easier way to run freqtrade on Docker without having to download all the code base.

Example of use would be to clone this repo in a VM running Ubuntu VM and run the docker command.

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

### 2) Adjust and add Telegram and Exchange API keys to ~/.freqtrade/config_dry.json and ~/.freqtrade/config_prod.json newly created

### 3) Add your strategy file inside the folder ./strategies

### 4.0) Run backtest (if needed)
```bash
make run-backtest \
    STRATEGY=BBRSI \
    CONFIG_FILE=config_dry.json \
    DB_FILE=tradesv3.dryrun.sqlite
```

### 4.1) Run bot locally in dry run mode
```bash
make run \
    STRATEGY=BBRSI \
    CONFIG_FILE=config_dry.json  \
    DB_FILE=tradesv3.dryrun.sqlite
```

make run \
    STRATEGY=BBRSI \
    CONFIG_FILE=config2.json  \
    DB_FILE=tradesv3.dryrun.sqlite

### 4.2) Run in production mode (dry run or not) - this will run the freqtrade bot on docker in the background
```bash
make run-prod \
    STRATEGY=BBRSI \
    CONFIG_FILE=config_prod.json \
    DB_FILE=tradesv3.sqlite 
```

### 5) Stop the docker of freqtrade in production
```bash
make stop-prod
```

