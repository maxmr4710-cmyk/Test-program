# Workflow Panel Summary

Краткая версия для панели рабочего процесса.

## Быстрые шаги
1. Проверь `.env` и `KODIKROUTER_API_KEY`.
2. Активируй `.venv`:
   - Windows: `.venv\Scripts\activate`
   - Unix: `source .venv/bin/activate`
3. Установи зависимости:
   - `pip install --upgrade pip`
   - `pip install -r requirements.txt`
4. Переключись в Roo Code на режим `orchestrator`.
5. Запусти задачу оркестратора:
   - `/mode orchestrator`
   - `/task Запусти полный цикл разработки для десктопного приложения трейдинга`

## Цель
- создать базовую структуру проекта
- подготовить окружение
- запустить разработку модулей агентами
- обеспечить тестирование и аудит

## Контрольные точки
- `src/` и `tests/` созданы
- `requirements.txt` обновлён
- `logs/cycle.log` ведёт запись
- код и документация закоммичены
