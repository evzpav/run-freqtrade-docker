#!/bin/bash

STRATEGY=$1
DRYRUN=${2:-false}
CONFIG=config_prod_$STRATEGY.json

if $DRYRUN = true; then
    CONFIG=config_dry_$STRATEGY.json
fi

make run-in-background \
    STRATEGY=$STRATEGY \
    CONFIG_FILE=$CONFIG \
    DB_FILE=tradesv3_$STRATEGY.sqlite

echo "Run: docker logs freqtrade_$STRATEGY"