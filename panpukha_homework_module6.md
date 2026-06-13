## Скрипт бекапу логів
Код скрипта backup.sh

```bash
#!/bin/bash

# Directory with log files
LOG_DIR="$1"

# Directory where backup archive will be saved
BACKUP_DIR="$2"

# Lock file to prevent parallel script execution
LOCK_FILE="/tmp/backup.lock"

# Check that exactly 2 arguments were passed
# Also check that both arguments are existing directories
if [ "$#" -ne 2 ] || [ ! -d "$LOG_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
    echo "Usage: ./backup.sh <log_dir><backup_dir>"
    exit 1
fi

# Check if backup is already running
if [ -f "$LOCK_FILE" ]; then
    echo "Backup already running"
    exit 1
fi

# Create lock file
touch "$LOCK_FILE"

# Remove lock file automatically when script finishes
trap 'rm -f "$LOCK_FILE"' EXIT

# Create archive filename with current date and time
DATE=$(date +"%Y-%m-%d_%H-%M")
ARCHIVE_NAME="logs_backup_${DATE}.tar.gz"

# Get full path to backup archive
ARCHIVE_PATH="$(realpath "$BACKUP_DIR")/$ARCHIVE_NAME"

# Create archive from all files inside log directory
tar -czf "$ARCHIVE_PATH" -C "$LOG_DIR" .

# Check if archive creation was successful
if [ "$?" -ne 0 ]; then
    echo "Backup failed"
    exit 2
fi

echo "Backup created: $ARCHIVE_PATH"
```

---

## Короткий опис роботи скрипта

Скрипт `backup.sh` створює архів з файлами логів.

Він приймає два аргументи:

```bash
./backup.sh /path/to/logs /path/to/backup
```

Перший аргумент — це каталог з логами, другий аргумент — каталог, куди потрібно зберегти архів.

Спочатку скрипт перевіряє, що передано рівно два аргументи і що обидва аргументи є існуючими каталогами. Якщо перевірка не пройдена, скрипт виводить повідомлення:

```
Usage: ./backup.sh <log_dir><backup_dir>
```

Після цього скрипт перевіряє lock-файл `/tmp/backup.lock`. Якщо такий файл вже існує, це означає, що бекап вже виконується, тому скрипт виводить:

Backup already running

Якщо lock-файлу немає, скрипт створює його і починає архівацію. Назва архіву містить дату і час у форматі:

```
logs_backup_YYYY-MM-DD_HH-MM.tar.gz
```

Архів створюється в каталозі для бекапів. Якщо архівація не вдалася, скрипт виводить:

```
Backup failed
```

і завершується з кодом 2.

Якщо все пройшло успішно, скрипт виводить повний шлях до створеного архіву:

```
Backup created: /full/path/to/archive
```

---

## Перевірка роботи скрипта

1. Створення тестових каталогів

```bash
mkdir -p /tmp/test_logs
mkdir -p /tmp/test_backup
```

2. Створення тестових логів

```bash
echo "Application started" > /tmp/test_logs/app.log
echo "Error example" > /tmp/test_logs/error.log
```

3. Створення файлу скрипта

```bash
nano backup.sh
```

Після цього у файл `backup.sh` було додано код скрипта.

4. Додавання прав на виконання

```bash
chmod +x backup.sh
```

5. Запуск скрипта з правильними аргументами

```bash
./backup.sh /tmp/test_logs /tmp/test_backup
```

Очікуваний результат:

```
Backup created: /tmp/test_backup/logs_backup_YYYY-MM-DD_HH-MM.tar.gz
```

6. Перевірка створеного архіву

```bash
ls -l /tmp/test_backup
```

У каталозі `/tmp/test_backup` з'явився архів з логами.

7. Перевірка запуску без аргументів

```bash
./backup.sh
```

Очікуваний результат:

```
Usage: ./backup.sh <log_dir><backup_dir>
```

8. Перевірка запуску з неправильним каталогом

```bash
./backup.sh /wrong/path /tmp/test_backup
```

Очікуваний результат:

```
Usage: ./backup.sh <log_dir><backup_dir>
```

9. Перевірка захисту від паралельного запуску

```bash
touch /tmp/backup.lock
./backup.sh /tmp/test_logs /tmp/test_backup
```

Очікуваний результат:

```
Backup already running
```

Після перевірки lock-файл було видалено:

```bash
rm -f /tmp/backup.lock
```

