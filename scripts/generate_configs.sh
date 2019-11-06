#!/bin/bash

STRATEGY=$1
CONFIG_PATH=${2:-config_example.json}
EXCHANGE_KEY=$3
EXCHANGE_SECRET=$4
TELEGRAM_TOKEN=$5
TELEGRAM_CHAT_ID=$6

FOLDER=.freqtrade
dry_run_config=~/$FOLDER/config_dry.json
prod_config=~/$FOLDER/config_prod.json
prod_db_file=~/$FOLDER/tradesv3.sqlite
dryrun_db_file=~/$FOLDER/tradesv3.dryrun.sqlite

if [[ -n $STRATEGY ]];then
    FOLDER=.freqtrade_$STRATEGY
    dry_run_config=~/$FOLDER/config_dry_$STRATEGY.json
    prod_config=~/$FOLDER/config_prod_$STRATEGY.json
    dryrun_db_file=~/$FOLDER/tradesv3_$STRATEGY.dryrun.sqlite
    prod_db_file=~/$FOLDER/tradesv3_$STRATEGY.sqlite
fi

if [[ ! -d ~/$FOLDER ]];then
    mkdir ~/$FOLDER
    echo "Folder created: ~/$FOLDER"
fi

cp $CONFIG_PATH config.json 
echo "Copying config from: $CONFIG_PATH"


if [[ -n $EXCHANGE_KEY ]];then
    sed -i -e "s/your_exchange_key/$EXCHANGE_KEY/g" config.json
fi

if [[ -n $EXCHANGE_SECRET ]];then
    sed -i -e "s/your_exchange_secret/$EXCHANGE_SECRET/g" config.json
fi

if [[ -n $TELEGRAM_TOKEN ]];then
    sed -i -e "s/your_telegram_token/$TELEGRAM_TOKEN/g" config.json
fi

if [[ -n $TELEGRAM_CHAT_ID ]];then
    sed -i -e "s/your_telegram_chat_id/$TELEGRAM_CHAT_ID/g" config.json
fi


if [[ ! -e $dry_run_config ]];then
   cp config.json $dry_run_config
   echo "Dry run config file created: $dry_run_config"
fi

if [[ ! -e $prod_config ]];then
   perl -pe '/dry_run/ && s/true/false/g' config.json > $prod_config
   echo "Prod file created: $prod_config"
fi


if [[ ! -e $prod_db_file ]];then
    touch $prod_db_file
    echo "Prod DB file created: $prod_db_file"
fi


if [[ ! -e $dryrun_db_file ]];then
   touch $dryrun_db_file
   echo "Dry run DB file created: $dryrun_db_file"
fi



