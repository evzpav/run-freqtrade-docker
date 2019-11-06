#!/bin/bash

EXCHANGE=$1
TIMEFRAME=$2
STRATEGY=$3

CONFIG=config_dry.json
FOLDER=.freqtrade


if [[ -n $STRATEGY ]];then
    FOLDER=.freqtrade_$STRATEGY
    CONFIG=config_dry_$STRATEGY.json
fi

make run \
	folder=$FOLDER \
	CONFIG_FILE=$CONFIG \
	PARAMS="download-data --exchange=$EXCHANGE --timeframes=$TIMEFRAME"
