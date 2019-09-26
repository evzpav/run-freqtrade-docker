#!/bin/bash

mkdir ~/.freqtrade
cp config.json.example ~/.freqtrade/config_dry.json
cp config.json.example ~/.freqtrade/config_prod.json
touch ~/.freqtrade/tradesv3.sqlite
touch ~/.freqtrade/tradesv3.dryrun.sqlite
