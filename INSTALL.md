# 📦 Установка RooPyth_GS

## Системные требования

- **ОС**: Windows 10+, macOS 10.15+, Ubuntu 20.04+
- **Python**: 3.10 или выше
- **RAM**: минимум 4 GB (рекомендуется 8+ GB для live-торговли)
- **Интернет**: стабильное соединение для API и WebSocket

## Проверка Python

```powershell
python --version
# Ожидаемый результат: Python 3.10.0 или выше
```

Если Python не установлен или версия < 3.10:
- Скачай из https://www.python.org/downloads/
- Убедись, что при установке отмечена опция "Add Python to PATH"

---

## 📋 Пошаговая установка

### 1. Клонирование или распаковка проекта

```powershell
# Если есть Git
git clone <URL-репозитория>
cd RooPyth_GS

# Если архив
# Распакуй архив в удобное место
cd путь/к/распакованной/папке
```

### 2. Создание виртуального окружения

```powershell
# Windows
python -m venv .venv
.venv\Scripts\activate

# Linux/macOS
python3 -m venv .venv
source .venv/bin/activate
```

Должна появиться префиксная строка `(.venv)` перед командной строкой.

### 3. Установка зависимостей

```powershell
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

### 4. Настройка переменных окружения

Создай файл `.env` в корне проекта (если его нет):

```env
# API KodikRouter (обязательно)
KODIKROUTER_API_KEY="sk-kr_live_ваш_ключ_здесь"

# GitHub интеграция (опционально)
GITHUB_TOKEN="ghp_ваш_токен_здесь"

# Binance API (для live-торговли)
BINANCE_API_KEY="your_binance_api_key"
BINANCE_API_SECRET="your_binance_api_secret"

# Bybit API (опционально)
BYBIT_API_KEY="your_bybit_api_key"
BYBIT_API_SECRET="your_bybit_api_secret"

# Параметры логирования
LOG_LEVEL="INFO"  # DEBUG, INFO, WARNING, ERROR, CRITICAL

# Параметры торговли (для live-торговли)
TRADING_ENABLED="false"  # true только для реальной торговли (ВНИМАНИЕ!)
BACKTEST_MODE="true"     # true для тестирования
```

### 5. Запуск инициализации (автоматический)

Открой VS Code с расширением Roo Code и выполни:

```
/mode orchestrator
/task Запусти полный цикл разработки для десктопного приложения трейдинга
```

**Что будет сделано автоматически:**
- ✅ Создание структуры папок (src/, tests/, logs/)
- ✅ Разработка всех модулей (integrations, models, strategies, backtester, ui)
- ✅ Запуск тестов (pytest)
- ✅ Аудит кода (kimi-auditor)
- ✅ Упаковка в exe (PyInstaller)
- ✅ Push в GitHub

Этот процесс займёт 30-60 минут в зависимости от сложности.

### 6. Запуск приложения

После завершения инициализации запусти UI:

```powershell
python -m src.ui.main_window
```

Должно открыться окно приложения с вкладками:
- Live Trading
- Backtester
- Settings
- Logs
- Positions

---

## 🧪 Проверка установки

### Тест 1: Импорты

```powershell
python -c "import src; import numpy; import pandas; import PyQt6; print('✓ Все импорты OK')"
```

### Тест 2: Структура проекта

```powershell
# Проверь, что существуют папки:
dir src\models
dir src\strategies
dir src\integrations
dir tests
```

### Тест 3: Запуск тестов

```powershell
pytest tests\ -v
```

Все тесты должны быть зелёными (PASSED).

### Тест 4: Запуск UI

```powershell
python -m src.ui.main_window
```

Должно открыться окно приложения без ошибок.

---

## ⚙️ Дополнительная конфигурация

### Получение API ключей

#### KodikRouter
1. Перейди на https://kodikrouter.ru
2. Зарегистрируйся/войди
3. В личном кабинете создай новый API-ключ
4. Скопируй ключ в `.env` как `KODIKROUTER_API_KEY`

#### Binance (для live-торговли)
1. Перейди на https://www.binance.com/
2. Создай аккаунт и пройди верификацию
3. В "API Management" создай новый ключ
4. Скопируй API Key и Secret в `.env`

#### Bybit (опционально)
1. Перейди на https://www.bybit.com/
2. Создай аккаунт
3. Сгенерируй API ключ в настройках
4. Скопируй в `.env`

#### GitHub (опционально)
1. Перейди на https://github.com/settings/tokens
2. Создай Personal Access Token с правами `repo`
3. Скопируй токен в `.env` как `GITHUB_TOKEN`

### Настройка IDE

#### VS Code
1. Открой проект в VS Code
2. Установи расширения:
   - Python (Microsoft)
   - Pylance (Microsoft)
   - Roo Code (Roo Vet)
   - PyTest Explorer
3. Выбери интерпретатор Python:
   - Ctrl+Shift+P → "Python: Select Interpreter" → выбери `.venv`

#### PyCharm
1. Открой проект в PyCharm
2. File → Settings → Project → Python Interpreter
3. Нажми ⚙ → Add → Existing Environment
4. Выбери `.venv/Scripts/python.exe` (Windows) или `.venv/bin/python` (Linux/macOS)

---

## 🐛 Решение проблем при установке

### Проблема: "ModuleNotFoundError: No module named 'PyQt6'"

**Решение:**
```powershell
pip install PyQt6
# Если не сработало:
pip install --upgrade PyQt6
```

### Проблема: "python: command not found"

**Решение:**
1. Проверь, что Python добавлен в PATH
2. На Windows: 
   - Открой "Edit environment variables"
   - Добавь путь к Python (например, `C:\Users\YourName\AppData\Local\Programs\Python\Python310`)
3. Перезапусти терминал

### Проблема: ".venv не создаётся"

**Решение:**
```powershell
# Проверь свободное место на диске (нужно минимум 2 GB)
# Если проблема в правах, запусти PowerShell от администратора
python -m venv .venv --system-site-packages
```

### Проблема: "KODIKROUTER_API_KEY not set"

**Решение:**
1. Убедись, что в файле `.env` есть строка: `KODIKROUTER_API_KEY="sk-kr_live_..."`
2. Перезапусти VS Code (Ctrl+K → Ctrl+W → открой проект заново)
3. Проверь, что `.env` находится в корне проекта (не в подпапке)

### Проблема: "Ошибка при подключении к API"

**Решение:**
1. Проверь интернет соединение
2. Убедись, что API ключ корректен (скопируй прямо с сайта, без пробелов)
3. Проверь, что токен не истёк или не заблокирован
4. Посмотри логи в `logs/app.log`

### Проблема: "pytest не найден"

**Решение:**
```powershell
# Убедись, что .venv активирован
.venv\Scripts\activate  # Windows
source .venv/bin/activate  # Linux/macOS

# Переустанови pytest
pip install --upgrade pytest
```

---

## 🚀 После установки

1. **Запусти полный цикл разработки** (см. README.md)
2. **Проверь логи** в папке `logs/`
3. **Запусти UI приложения** (`python -m src.ui.main_window`)
4. **Протестируй бэктестер** (см. примеры в README.md)

---

## 📊 Структура после полной установки

```
RooPyth_GS/
├── .env                      # ✅ Созданнен
├── .env.example              # ✅ Созданнен
├── .initialized              # ✅ Созданнен (флаг инициализации)
├── .venv/                    # ✅ Созданнен (виртуальное окружение)
├── .roomodes                 # ✅ Обновлён (конфигурация агентов)
├── requirements.txt          # ✅ Обновлён
├── build.py                  # ✅ Созданнен (PyInstaller скрипт)
├── README.md                 # ✅ Обновлён
├── PROJECT_ARCHITECTURE.md   # ✅ Созданнен
│
├── src/
│   ├── models/               # ✅ Созданнен
│   ├── strategies/           # ✅ Созданнен
│   ├── integrations/         # ✅ Созданнен
│   ├── backtests/            # ✅ Созданнен
│   ├── ui/                   # ✅ Созданнен
│   ├── live_trading/         # ✅ Созданнен
│   └── utils/                # ✅ Созданнен
│
├── tests/                    # ✅ Созданнен
├── logs/                     # ✅ Созданнен
└── dist/                     # ✅ Созданнен (exe после сборки)
    └── TradingApp.exe        # 📦 Готов к распространению
```

---

## 📝 Примеры команд

```powershell
# Активировать окружение
.venv\Scripts\activate

# Запустить UI
python -m src.ui.main_window

# Запустить бэктест
python -m src.backtests.backtest_runner --strategy gamma_scalping --symbol ETHUSDT --start 2024-01-01 --end 2024-12-31

# Запустить тесты
pytest tests/ -v

# Собрать exe
python build.py

# Запустить exe
dist\TradingApp.exe

# Просмотреть логи
tail -f logs/app.log  # Linux/macOS
Get-Content logs/app.log -Tail 50 -Wait  # Windows PowerShell
```

---

## ✅ Финальная проверка

Перед тем, как начать разработку:

- [ ] Python установлен (версия >= 3.10)
- [ ] .venv создано и активировано
- [ ] requirements.txt установлены
- [ ] .env настроен с API ключами
- [ ] Полный цикл разработки запущен и завершён успешно
- [ ] Тесты проходят (pytest)
- [ ] UI запускается без ошибок
- [ ] Логи пишутся в logs/

Если всё ✅, тогда **готово к использованию!**

Вопросы? Посмотри README.md или логи в папке logs/.
