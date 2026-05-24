# Архитектура Десктопного Приложения для Трейдинга

## 📁 Структура проекта

```
project-root/
├── .env                          # API ключи (НЕ коммитить!)
├── .env.example                  # Шаблон .env
├── .gitignore                    # Git ignore (исключает .env, .venv, logs/)
├── .initialized                  # Флаг инициализации (созданный оркестратором)
├── .roomodes                     # Конфигурация агентов (Roo Code)
├── requirements.txt              # Python зависимости
├── requirements-build.txt        # Зависимости для сборки (PyInstaller)
├── build.py                      # Скрипт для создания бинарного файла
├── setup.py                      # Скрипт для распространения через pip
├── README.md                     # Документация для пользователя
├── INSTALL.md                    # Инструкции по установке
├── CONTRIBUTING.md               # Инструкции для разработчиков
│
├── src/
│   ├── __init__.py              # Пустой (инициализация пакета)
│   ├── main.py                  # Точка входа для FastAPI (тестирование интеграций)
│   │
│   ├── models/                  # Расчётные модели (СОЗДАЁТ: deepseek-models)
│   │   ├── __init__.py
│   │   ├── options_pricing.py   # Расчёты Black-Scholes, греков
│   │   ├── market_data.py       # Работа с OHLCV, индикаторы
│   │   └── position.py          # Управление позициями, PnL
│   │
│   ├── strategies/              # Торговые стратегии (СОЗДАЁТ: deepseek-strategies)
│   │   ├── __init__.py
│   │   ├── base_strategy.py     # Абстрактный базовый класс
│   │   └── gamma_scalping.py    # Конкретная стратегия (gamma scalping)
│   │
│   ├── backtests/               # Раннеры для бэктестов (СОЗДАЁТ: deepseek-backtester)
│   │   ├── __init__.py
│   │   ├── backtest_engine.py   # Основной движок бэктестирования
│   │   └── backtest_runner.py   # CLI и функции запуска
│   │
│   ├── live_trading/            # Точка входа для live-торговли (СОЗДАЁТ: deepseek-architect)
│   │   ├── __init__.py
│   │   └── run_live.py          # Запуск стратегии в реальном режиме
│   │
│   ├── integrations/            # API для бирж (СОЗДАЁТ: deepseek-integrations)
│   │   ├── __init__.py
│   │   ├── binance.py           # Binance API клиент + WebSocket
│   │   ├── bybit.py             # Bybit API клиент + WebSocket
│   │   └── base_client.py       # Абстрактный базовый клиент
│   │
│   ├── ui/                      # Десктопный интерфейс (СОЗДАЁТ: qwen-ui-designer)
│   │   ├── __init__.py
│   │   ├── main_window.py       # Главное окно приложения
│   │   └── modules/             # Модули для каждой функции
│   │       ├── live_trading_module.py     # Модуль live-торговли
│   │       ├── backtester_module.py       # Модуль бэктестирования
│   │       ├── settings_module.py         # Модуль настроек
│   │       ├── logs_module.py             # Модуль просмотра логов
│   │       └── positions_module.py        # Модуль позиций
│   │
│   └── utils/                   # Общие функции (СОЗДАЁТ: deepseek-architect)
│       ├── __init__.py
│       ├── config.py            # Загрузка конфига из .env
│       ├── logger.py            # Логирование в logs/app.log
│       └── helpers.py           # Вспомогательные функции
│
├── tests/                       # Тесты (СОЗДАЁТ: deepseek-architect + специалисты)
│   ├── conftest.py             # Конфигурация pytest
│   ├── test_models.py          # Тесты для src/models/
│   ├── test_strategies.py      # Тесты для src/strategies/
│   ├── test_backtests.py       # Тесты для src/backtests/
│   ├── test_integrations.py    # Тесты для src/integrations/
│   └── test_integration.py     # Интеграционные тесты
│
├── logs/                        # Логи приложения
│   ├── app.log                 # Основной лог приложения
│   ├── audit.log               # Лог аудита кода (kimi-auditor)
│   ├── cycle.log               # Лог цикла разработки (оркестратор)
│   └── audit_report.md         # Отчёт аудита
│
├── dist/                        # Собранное приложение (PyInstaller)
│   └── TradingApp.exe          # Бинарный файл (Windows)
│
└── .kilo/                      # Конфигурация Kilo Code (опционально)
    └── ...
```

## 🎯 Разделение ответственности агентов

### 1. **Orchestrator** (главный координатор)
- Инициализирует проект
- Запускает циклы разработки
- Логирует ход выполнения

### 2. **DeepSeek Architect** (окружение + core)
- Инициализирует окружение (Python, .venv, requirements.txt)
- Создаёт структуру папок src/, tests/, logs/
- Создаёт базовые файлы (config.py, logger.py)
- Запускает тесты и исправляет ошибки

### 3. **DeepSeek Integrations** (API для бирж)
- Создаёт src/integrations/binance.py (Binance API + WebSocket)
- Создаёт src/integrations/bybit.py (Bybit API + WebSocket)
- **НЕ создаёт** стратегии или UI

### 4. **DeepSeek Models** (математические модели)
- Создаёт src/models/options_pricing.py (Black-Scholes, греки)
- Создаёт src/models/market_data.py (OHLCV, индикаторы)
- Создаёт src/models/position.py (управление позициями)
- **НЕ создаёт** стратегии или интеграции

### 5. **DeepSeek Strategies** (торговые стратегии)
- Создаёт src/strategies/base_strategy.py (абстрактный класс)
- Создаёт src/strategies/gamma_scalping.py (конкретная стратегия)
- Использует src/models/ для расчётов
- **НЕ создаёт** интеграции или UI

### 6. **DeepSeek Backtester** (раннер для тестирования)
- Создаёт src/backtests/backtest_engine.py (основной движок)
- Создаёт src/backtests/backtest_runner.py (CLI)
- Использует src/strategies/ и src/models/
- **НЕ создаёт** стратегии

### 7. **Qwen UI Designer** (десктопный интерфейс)
- Создаёт src/ui/main_window.py (главное окно с табами)
- Создаёт src/ui/modules/ (отдельные модули для функций)
- **НЕ содержит** бизнес-логику (только UI слой)
- Вызывает функции из src/ (strategies, integrations, backtests)

### 8. **DeepSeek Packager** (упаковка & сборка)
- Создаёт build.py (PyInstaller конфиг)
- Создаёт setup.py (распространение через pip)
- Создаёт инсталляторы для разных ОС
- **НЕ изменяет** основной код

### 9. **Kimi Auditor** (контроль качества)
- Проверяет безопасность (API ключи в .env, валидация)
- Проверяет модульность (независимость модулей)
- Проверяет тесты (покрытие, проверка что pytest проходит)
- **НЕ исправляет** код (только рекомендации)

### 10. **Qwen GitHub Manager** (Git & DevOps)
- Инициализирует Git репозиторий
- Создаёт репозиторий на GitHub
- Делает коммиты и pushes
- Создаёт документацию (README, INSTALL, CONTRIBUTING)

## 📐 Принципы модульности

### ✅ Правильно:
```python
# src/strategies/gamma_scalping.py
from src.models import options_pricing, market_data
from src.integrations import binance_client

class GammaScalpingStrategy:
    def analyze(self, market_data_obj):
        # Использует функции из src.models/
        gamma = options_pricing.calculate_gamma(...)
        delta = options_pricing.calculate_delta(...)
        return signals
    
    def execute(self, client, signals):
        # Использует функции из src.integrations/
        order = client.place_order(...)
        return order_id
```

### ❌ Неправильно:
```python
# src/strategies/gamma_scalping.py
# ❌ Создание API клиента внутри стратегии
client = BinanceClient(api_key, api_secret)
order = client.place_order(...)

# ❌ Дублирование расчётов
gamma = (100 * second_derivative) / spot_price
```

## 🔗 Зависимости между модулями

```
┌─────────────────────────────────────────────────┐
│                    UI (PyQt6)                    │
│  src/ui/main_window.py + src/ui/modules/*      │
└──────────┬───────────┬─────────────┬────────────┘
           │           │             │
      ┌────▼─┐    ┌────▼──────┐  ┌──▼──────┐
      │Live  │    │ Backtester│  │ Settings│
      │Trade │    │   Module  │  │ Module  │
      └────┬─┘    └────┬──────┘  └──┬──────┘
           │           │             │
    ┌──────▼───────────▼─────────────▼──────┐
    │   Core Business Logic (src/)           │
    │                                        │
    │  ┌──────────────────────────────────┐ │
    │  │ Integrations: Binance, Bybit    │ │
    │  │ (API + WebSocket)               │ │
    │  └──────────────────────────────────┘ │
    │                                        │
    │  ┌──────────────────────────────────┐ │
    │  │ Strategies: BaseStrategy,        │ │
    │  │ GammaScalping                    │ │
    │  └──────────────────────────────────┘ │
    │                                        │
    │  ┌──────────────────────────────────┐ │
    │  │ Models: Options, MarketData,     │ │
    │  │ Position (расчёты)               │ │
    │  └──────────────────────────────────┘ │
    │                                        │
    │  ┌──────────────────────────────────┐ │
    │  │ BacktestEngine, BacktestRunner   │ │
    │  └──────────────────────────────────┘ │
    │                                        │
    │  ┌──────────────────────────────────┐ │
    │  │ Utils: Config, Logger, Helpers   │ │
    │  └──────────────────────────────────┘ │
    │                                        │
    └────────────────────────────────────────┘
```

## 🧪 Тестирование

Каждый модуль должен иметь unit-тесты:

```
tests/test_models.py        # Тесты для src/models/
tests/test_strategies.py    # Тесты для src/strategies/
tests/test_integrations.py  # Тесты для src/integrations/
tests/test_backtests.py     # Тесты для src/backtests/
tests/test_integration.py   # Интеграционные тесты (все вместе)
```

Запуск всех тестов:
```bash
pytest tests/ -v
```

## 🚀 Запуск приложения

### Разработка:
```bash
# Активировать окружение
.venv\Scripts\activate  # Windows
source .venv/bin/activate  # Linux/macOS

# Запустить UI
python -m src.ui.main_window
```

### Запуск бэктеста:
```bash
python -m src.backtests.backtest_runner --strategy gamma_scalping --symbol ETHUSDT --start 2024-01-01 --end 2024-12-31
```

### Сборка бинарного файла:
```bash
python build.py
# Результат: dist/TradingApp.exe (Windows) или dist/TradingApp (Linux/macOS)
```

## 📝 Требования к кодеру (агентам):

1. **Не вмешиваешься в другие модули** — каждый агент создаёт только свой модуль
2. **Используешь type hints** — для всех функций и методов
3. **Документируешь код** — docstrings для классов и функций
4. **Логируешь правильно** — через src/utils/logger
5. **Нет секретов в коде** — все из .env через config.py
6. **Пишешь тесты** — для каждого модуля
7. **Следуешь PEP8** — черный формат, isort для импортов
