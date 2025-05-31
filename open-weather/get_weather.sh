#!/usr/bin/bash
CONF_FILE=$(dirname $0)/config
if [ -e "$CONF_FILE" ]; then
    . "$CONF_FILE"
else
    echo "Configuration file $CONF_FILE not found"
    exit 1
fi

if [ -z "$LAT" -o -z "$LONG" -o -z "$APPID" ]; then
    echo "Configuration file must declare latitude (LAT), longitude (LONG) "
    echo "and app ID (APPID)."
    exit 1
fi

CURRENT=/tmp/open-weather.json
FORECAST=/tmp/open-weather-forecast.json
TZ=+07:00

wget -q "https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LONG}&tz=${TZ}&units=metric&appid=${APPID}" -O "${CURRENT}"
wget -q "https://api.openweathermap.org/data/2.5/forecast?lat=${LAT}&lon=${LONG}&tz=${TZ}&units=metric&appid=${APPID}" -O "${FORECAST}"