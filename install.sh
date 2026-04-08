#!/bin/bash

# Скрипт автоматической сборки NekoBoxForAndroid
# Требования: установленные JDK 17+, Android SDK, переменная ANDROID_HOME

set -e

echo "🚀 Начало сборки NekoBoxForAndroid..."

# Проверка наличия Java
if ! command -v java &> /dev/null; then
    echo "❌ Ошибка: Java не найдена. Установите JDK 17 или выше."
    exit 1
fi

java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
echo "✅ Найдена Java версия: $java_version"

# Проверка переменной окружения ANDROID_HOME
if [ -z "$ANDROID_HOME" ]; then
    echo "❌ Ошибка: Переменная окружения ANDROID_HOME не установлена."
    echo "Установите её перед запуском скрипта:"
    echo "  export ANDROID_HOME=/path/to/android/sdk"
    exit 1
fi

echo "✅ Android SDK найден в: $ANDROID_HOME"

# Клонирование репозитория (если еще не клонирован)
REPO_DIR="NekoBoxForAndroid"
if [ ! -d "$REPO_DIR" ]; then
    echo "📥 Клонирование репозитория..."
    git clone --depth 1 https://github.com/MatsuriDayo/NekoBoxForAndroid.git "$REPO_DIR"
else
    echo "✅ Репозиторий уже существует, обновляем..."
    cd "$REPO_DIR"
    git pull
    cd ..
fi

cd "$REPO_DIR"

# Создание local.properties если не существует
if [ ! -f "local.properties" ]; then
    echo "sdk.dir=$ANDROID_HOME" > local.properties
    echo "✅ Создан файл local.properties"
fi

# Предоставление прав на gradlew
chmod +x gradlew

# Сборка Debug APK (быстрая, без подписи)
echo "🔨 Сборка Debug APK..."
./gradlew assembleOssDebug --no-daemon

# Поиск собранного APK
APK_PATH=$(find app/build/outputs/apk -name "*-debug.apk" -type f | head -n 1)

if [ -n "$APK_PATH" ]; then
    echo ""
    echo "✅ Сборка успешно завершена!"
    echo "📦 APK файл находится по пути: $APK_PATH"
    echo ""
    echo "Для установки на устройство:"
    echo "  adb install $APK_PATH"
else
    echo "❌ Ошибка: APK файл не найден после сборки."
    exit 1
fi
