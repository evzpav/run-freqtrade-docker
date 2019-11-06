# pragma pylint: disable=missing-docstring, invalid-name, pointless-string-statement

from functools import reduce
from typing import Any, Callable, Dict, List

import talib.abstract as ta
from pandas import DataFrame
from skopt.space import Categorical, Dimension, Integer

import freqtrade.vendor.qtpylib.indicators as qtpylib
from freqtrade.optimize.hyperopt_interface import IHyperOpt


class donchian(IHyperOpt):
    """
    Default hyperopt provided by the Freqtrade bot.
    You can override it with your own Hyperopt
    """
    @staticmethod
    def populate_indicators(dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Add several indicators needed for buy and sell strategies defined below.
        """
        upperlength=70
        
        dataframe['max'] = ta.MAX(dataframe, timeperiod=upperlength)
        dataframe['upper'] = dataframe['max'].shift(periods=1)

        dataframe['min'] = ta.MIN(dataframe, timeperiod=upperlength)
        dataframe['lower'] = dataframe['min'].shift(periods=1)
        dataframe['middle'] = dataframe['min'] + (dataframe['upper'] - dataframe['min'])/2


        return dataframe

    @staticmethod
    def buy_strategy_generator(params: Dict[str, Any]) -> Callable:
        """
        Define the buy strategy parameters to be used by Hyperopt.
        """
        def populate_buy_trend(dataframe: DataFrame, metadata: dict) -> DataFrame:
            """
            Buy strategy Hyperopt will build and use.
            """
            conditions = []

         
            # TRIGGERS
            if 'trigger' in params:
                if params['trigger'] == 'upper':
                    conditions.append(qtpylib.crossed_above(dataframe['close'], dataframe['upper']))
  
            if conditions:
                dataframe.loc[
                    reduce(lambda x, y: x & y, conditions),
                    'buy'] = 1

            return dataframe

        return populate_buy_trend

    @staticmethod
    def indicator_space() -> List[Dimension]:
        """
        Define your Hyperopt space for searching buy strategy parameters.
        """
        return [
            Integer(40, 100, name='upper-value'),
       
        ]

    @staticmethod
    def sell_strategy_generator(params: Dict[str, Any]) -> Callable:
        """
        Define the sell strategy parameters to be used by Hyperopt.
        """
        def populate_sell_trend(dataframe: DataFrame, metadata: dict) -> DataFrame:
            """
            Sell strategy Hyperopt will build and use.
            """
            conditions = []

            # TRIGGERS
            if 'sell-trigger' in params:
                if params['sell-trigger'] == 'sell-middle':
                    conditions.append(qtpylib.crossed_below(
                        dataframe['close'], dataframe['middle']
                    ))

            if conditions:
                dataframe.loc[
                    reduce(lambda x, y: x & y, conditions),
                    'sell'] = 1

            return dataframe

        return populate_sell_trend

    @staticmethod
    def sell_indicator_space() -> List[Dimension]:
        """
        Define your Hyperopt space for searching sell strategy parameters.
        """
        return [
            Integer(10, 70, name='sell-middle-value'),
        ]

    def populate_buy_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Based on TA indicators. Should be a copy of same method from strategy.
        Must align to populate_indicators in this file.
        Only used when --spaces does not include buy space.
        """
        dataframe.loc[
            (
                (qtpylib.crossed_above(dataframe['close'], dataframe['upper']))
            ),
            'buy'] = 1
        return dataframe
   
    def populate_sell_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Based on TA indicators. Should be a copy of same method from strategy.
        Must align to populate_indicators in this file.
        Only used when --spaces does not include sell space.
        """     
        dataframe.loc[
            (
                (qtpylib.crossed_below(dataframe['close'], dataframe['middle']))
            ),
            'sell'] = 1
        return dataframe