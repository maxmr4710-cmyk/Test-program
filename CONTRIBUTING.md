# 🤝 Вклад в RooPyth_GS

Спасибо, что хочешь внести свой вклад в проект! Этот документ описывает правила разработки и процесс контрибьютинга.

## 📋 Общие правила

### 1. Архитектура и модульность

**ВАЖНО:** Не нарушай модульную архитектуру проекта!

Каждый модуль должен быть **независимым** и **самодостаточным**:

```
✅ ПРАВИЛЬНО:
src/strategies/my_strategy.py → использует src/models/ для расчётов

❌ НЕПРАВИЛЬНО:
src/strategies/my_strategy.py → прямо вычисляет Greeks (логика должна быть в src/models/)
src/ui/main_window.py → содержит логику торговли (должна быть в src/)
```

### 2. Где добавлять код

| Папка | Для чего | Пример |
|-------|----------|--------|
| `src/models/` | Математические модели, расчёты | Black-Scholes, Greeks, RSI, EMA |
| `src/strategies/` | Торговые стратегии | GammaScalping, MeanReversion |
| `src/integrations/` | API для бирж, WebSocket | BinanceClient, BybitClient |
| `src/backtests/` | Фреймворк тестирования, runners | BacktestEngine, CLI runner |
| `src/ui/` | Десктопный интерфейс, окна | MainWindow, QTableWidget views |
| `src/live_trading/` | Запуск стратегии в реальном времени | RunLiveStrategy |
| `src/utils/` | Общие функции | logger, config, helpers |
| `tests/` | Unit-тесты для каждого модуля | test_models.py, test_strategies.py |

### 3. Правила кодирования

#### Type Hints (обязательно)

```python
# ✅ ПРАВИЛЬНО
def calculate_delta(spot: float, strike: float, time_to_exp: float) -> float:
    """Calculate option delta using Black-Scholes model."""
    # implementation
    return delta

# ❌ НЕПРАВИЛЬНО
def calculate_delta(spot, strike, time_to_exp):
    """Calculate option delta using Black-Scholes model."""
    # implementation
    return delta
```

#### Docstrings (для публичных функций/классов)

```python
# ✅ ПРАВИЛЬНО
class GammaScalpingStrategy(BaseStrategy):
    """Gamma scalping strategy for delta-neutral option trading.
    
    This strategy maintains a delta-neutral portfolio by hedging gamma exposure
    in the underlying asset.
    
    Attributes:
        target_gamma: Target gamma level for the strategy (float)
        delta_range: Acceptable delta range for rehedging (tuple of float)
    """
    
    def analyze(self, market_data: MarketData, positions: List[Position]) -> Dict:
        """Analyze market data and generate trading signals.
        
        Args:
            market_data: Current market data (OHLCV)
            positions: List of current positions
            
        Returns:
            Dictionary with signals: {'action': 'buy'/'sell'/'hedge', 'quantity': float}
        """
        pass
```

#### Logging (обязательно используй src/utils/logger)

```python
# ✅ ПРАВИЛЬНО
from src.utils.logger import logger

def execute_order(client, symbol, side, quantity):
    try:
        logger.info(f"Placing {side} order for {symbol}: {quantity} units")
        order = client.place_order(symbol, side, quantity)
        logger.info(f"Order placed successfully: order_id={order['id']}")
        return order
    except Exception as e:
        logger.error(f"Failed to place order: {str(e)}")
        raise

# ❌ НЕПРАВИЛЬНО
def execute_order(client, symbol, side, quantity):
    print(f"Placing order...")  # не используй print!
    order = client.place_order(symbol, side, quantity)
```

#### Конфигурация (используй src/utils/config.py)

```python
# ✅ ПРАВИЛЬНО
from src.utils.config import get_config

config = get_config()
api_key = config.get('BINANCE_API_KEY')
api_secret = config.get('BINANCE_API_SECRET')

# ❌ НЕПРАВИЛЬНО
api_key = "sk_live_..."  # никогда не вставляй секреты в код!
api_secret = "..."
```

#### Error Handling

```python
# ✅ ПРАВИЛЬНО
def place_order(self, symbol: str, side: str, quantity: float) -> Dict:
    """Place an order with proper error handling."""
    try:
        if not symbol or quantity <= 0:
            raise ValueError("Invalid symbol or quantity")
        
        response = self.client.place_order(symbol, side, quantity)
        if response.get('status') != 'success':
            logger.warning(f"Order placement returned status: {response['status']}")
        return response
        
    except TimeoutError as e:
        logger.error(f"Timeout while placing order: {e}")
        # Retry logic here
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise

# ❌ НЕПРАВИЛЬНО
def place_order(self, symbol, side, quantity):
    response = self.client.place_order(symbol, side, quantity)
    return response  # нет обработки ошибок!
```

### 4. Тестирование (обязательно)

Каждый модуль должен иметь unit-тесты:

```python
# tests/test_my_strategy.py
import pytest
from src.strategies.my_strategy import MyStrategy
from src.models import market_data

def test_my_strategy_analyze():
    """Test that strategy generates correct signals."""
    strategy = MyStrategy(target_gamma=0.05, delta_range=(-0.1, 0.1))
    
    # Создай mock market data
    market_data_mock = {
        'spot': 100,
        'iv': 0.25,
        'close_prices': [98, 99, 100, 101, 102]
    }
    
    signals = strategy.analyze(market_data_mock)
    
    assert signals is not None
    assert 'action' in signals
    assert signals['action'] in ['buy', 'sell', 'hedge', 'hold']
    assert 'quantity' in signals
    assert signals['quantity'] >= 0

def test_my_strategy_error_handling():
    """Test that strategy handles invalid inputs."""
    strategy = MyStrategy()
    
    with pytest.raises(ValueError):
        strategy.analyze({'spot': -100})  # Negative spot price should fail
```

Запусти тесты:
```bash
pytest tests/test_my_strategy.py -v
```

### 5. Форматирование кода (Black)

Используй Black для форматирования:

```bash
# Проверь, нужна ли переформатировка
black src/ tests/ --check

# Или автоматически переформатируй
black src/ tests/
```

### 6. Импорты (isort)

Используй isort для организации импортов:

```python
# ✅ ПРАВИЛЬНО (отсортировано)
import sys
from typing import Dict, List

import numpy as np
import pandas as pd

from src.models import options_pricing
from src.utils.logger import logger

# ❌ НЕПРАВИЛЬНО (не отсортировано)
from src.utils.logger import logger
import numpy as np
from typing import Dict
import pandas as pd
from src.models import options_pricing
```

---

## 🚀 Процесс контрибьютинга

### Для внесения изменений:

1. **Создай feature branch**:
   ```bash
   git checkout -b feature/gamma-scalping-improvements
   ```

2. **Сделай изменения**:
   - Добавь код в соответствующую папку
   - Напиши тесты
   - Обнови документацию

3. **Проверь качество**:
   ```bash
   # Запусти тесты
   pytest tests/ -v
   
   # Проверь форматирование
   black src/ tests/ --check
   
   # Проверь импорты
   isort src/ tests/ --check
   
   # Проверь типы (опционально)
   mypy src/ --ignore-missing-imports
   ```

4. **Сделай коммит**:
   ```bash
   git add .
   git commit -m "feat: add gamma scalping improvements for better hedging"
   ```
   
   Используй conventional commits:
   - `feat:` – новая фича
   - `fix:` – исправление баги
   - `docs:` – обновление документации
   - `test:` – добавление тестов
   - `refactor:` – рефакторинг без изменения функциональности
   - `perf:` – улучшения производительности

5. **Push и создай Pull Request**:
   ```bash
   git push origin feature/gamma-scalping-improvements
   ```
   
   На GitHub создай PR с описанием:
   - Что изменилось
   - Почему это нужно
   - Как тестировать

---

## 📚 Примеры добавления новых компонентов

### Пример 1: Добавить новый индикатор

```python
# src/models/market_data.py

from typing import List
import numpy as np
from src.utils.logger import logger

def calculate_bollinger_bands(prices: List[float], period: int = 20, std_dev: float = 2) -> Dict[str, List[float]]:
    """Calculate Bollinger Bands.
    
    Args:
        prices: List of closing prices
        period: Moving average period (default 20)
        std_dev: Number of standard deviations (default 2)
        
    Returns:
        Dictionary with 'upper', 'middle', 'lower' bands
    """
    if len(prices) < period:
        logger.warning(f"Not enough data for Bollinger Bands calculation (need {period}, got {len(prices)})")
        return None
    
    prices_array = np.array(prices[-period:])
    middle = np.mean(prices_array)
    std = np.std(prices_array)
    
    return {
        'upper': middle + (std_dev * std),
        'middle': middle,
        'lower': middle - (std_dev * std)
    }


# tests/test_market_data.py
import pytest
from src.models.market_data import calculate_bollinger_bands

def test_bollinger_bands():
    """Test Bollinger Bands calculation."""
    prices = [100, 101, 102, 101, 100, 99, 98, 99, 100, 101]
    
    bands = calculate_bollinger_bands(prices, period=5, std_dev=2)
    
    assert bands is not None
    assert 'upper' in bands and 'middle' in bands and 'lower' in bands
    assert bands['lower'] < bands['middle'] < bands['upper']
```

### Пример 2: Добавить новую стратегию

```python
# src/strategies/mean_reversion.py

from typing import Dict, List
from src.strategies.base_strategy import BaseStrategy
from src.models import market_data
from src.utils.logger import logger

class MeanReversionStrategy(BaseStrategy):
    """Mean reversion trading strategy.
    
    This strategy trades deviations from a moving average, assuming prices
    will revert to the mean.
    """
    
    def __init__(self, ma_period: int = 20, std_threshold: float = 2.0):
        """Initialize the strategy.
        
        Args:
            ma_period: Period for moving average (default 20)
            std_threshold: Number of std deviations for signal (default 2.0)
        """
        super().__init__()
        self.ma_period = ma_period
        self.std_threshold = std_threshold
        logger.info(f"MeanReversionStrategy initialized: ma_period={ma_period}, threshold={std_threshold}")
    
    def analyze(self, market_data_obj: Dict) -> Dict:
        """Generate trading signals based on mean reversion."""
        try:
            close_prices = market_data_obj.get('close_prices', [])
            if len(close_prices) < self.ma_period:
                return {'action': 'hold', 'reason': 'Not enough data'}
            
            # Calculate Bollinger Bands
            bands = market_data.calculate_bollinger_bands(close_prices, self.ma_period, self.std_threshold)
            current_price = close_prices[-1]
            
            if current_price > bands['upper']:
                logger.info(f"Price {current_price} above upper band, selling signal")
                return {'action': 'sell', 'quantity': 1.0}
            elif current_price < bands['lower']:
                logger.info(f"Price {current_price} below lower band, buying signal")
                return {'action': 'buy', 'quantity': 1.0}
            else:
                return {'action': 'hold', 'quantity': 0}
        
        except Exception as e:
            logger.error(f"Error in analyze: {e}")
            return {'action': 'hold', 'error': str(e)}
```

---

## 🔍 Pre-commit Checklist

Перед каждым коммитом проверь:

- [ ] Код следует PEP8
- [ ] Используются type hints
- [ ] Все функции задокументированы (docstrings)
- [ ] Логирование используется везде (не print)
- [ ] Секреты не в коде (только в .env)
- [ ] Все новые модули имеют unit-тесты
- [ ] Тесты проходят: `pytest tests/ -v`
- [ ] Нет дублирования кода
- [ ] Архитектура не нарушена
- [ ] Изменения локализованы (не трогал другие модули)

---

## 🐛 Отчёт об ошибках

Если нашёл баг:

1. Проверь, что это действительно баг, а не особенность
2. Создай issue на GitHub с описанием:
   - Как воспроизвести
   - Ожидаемый результат
   - Получаемый результат
   - Логи (если есть)

3. Если можешь исправить:
   - Создай feature branch
   - Исправь баг
   - Напиши тесты для бага
   - Сделай PR

---

## 📞 Вопросы?

- Посмотри документацию в [README.md](README.md) и [PROJECT_ARCHITECTURE.md](PROJECT_ARCHITECTURE.md)
- Проверь логи в папке `logs/`
- Напиши issue на GitHub

---

## 📜 Лицензия

Все контрибьюции лицензируются под MIT License.

---

**Спасибо за вклад в развитие проекта! 🙏**
