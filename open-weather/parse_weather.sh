#!/bin/bash
TZ="Asia/Ho_Chi_Minh"

# Get new data
#./get_weather.sh

# Dependencies: jq, date, awk

WEATHER_FILE="/tmp/open-weather.json"
FORECAST_FILE="/tmp/open-weather-forecast.json"

# Define weather icon map
declare -A ICONS=(
  ["01d"]="🌞" ["01n"]="🌃" ["02d"]="🌤️" ["02n"]="🌥"
  ["03d"]="☁️" ["03n"]="🌤" ["04d"]="☁️" ["04n"]="🌤"
  ["09d"]="🌧️" ["10d"]="🌦️" ["10n"]="🌧"
  ["13d"]="❄️" ["50d"]="🌫️"
)

ret_text=""
ret_tooltip=""
ret_class="weather"
ret_percentage=100

# --- Current weather ---
if [ -f "$WEATHER_FILE" ]; then
  weather=$(<"$WEATHER_FILE")

  loc_name=$(echo "$weather" | jq -r '.name')
  icon_code=$(echo "$weather" | jq -r '.weather[0].icon')
  icon=${ICONS[$icon_code]:-"？$icon_code"}

  temp=$(echo "$weather" | jq -r '.main.temp')
  sens=$(echo "$weather" | jq -r '.main.feels_like')
  hum=$(echo "$weather" | jq -r '.main.humidity')
  wind_vel=$(echo "$weather" | jq -r '.wind.speed')
  wind_dir=$(echo "$weather" | jq -r '.wind.deg')

  text="$icon $(awk -v t="$temp" 'BEGIN {printf "%.2f", t}')°C ($(awk -v s="$sens" 'BEGIN {printf "%.2f", s}'))"
  ret_text="$text"
else
  ret_text="Could not process weather file ($WEATHER_FILE)"
fi

# --- Forecast tooltip ---
if [ -f "$FORECAST_FILE" ]; then
  forecast=$(<"$FORECAST_FILE")
  cast=""
  declare -A temps_by_day
  declare -A lines_by_day
  declare -A first_seen_day

  mapfile -t forecasts < <(echo "$forecast" | jq -c '.list[]')

  for f in "${forecasts[@]}"; do
    dt=$(echo "$f" | jq -r '.dt')
    time_str=$(date -u -d @"$dt" +'%H:%M')
    date_str=$(date -u -d @"$dt" +'%Y-%m-%d')
    day_label=$(date -u -d @"$dt" +'%A, %Y-%m-%d')

    temp=$(echo "$f" | jq -r '.main.temp')
    hum=$(echo "$f" | jq -r '.main.humidity')

    icon_code=$(echo "$f" | jq -r '.weather[0].icon')
    icon_desc=$(echo "$f" | jq -r '.weather[0].description')
    icon=${ICONS[$icon_code]:-"？$icon_code"}

    formatted_line="$time_str | $(awk -v t="$temp" 'BEGIN {printf "%.2f", t}')°C | 🌢$(awk -v h="$hum" 'BEGIN {printf "%d", h}')%% | $icon $icon_desc"

    # Group by date
    temps_by_day[$date_str]+="$temp "
    lines_by_day[$date_str]+="$formatted_line"$'\n'
  done

  for day in $(printf "%s\n" "${!lines_by_day[@]}" | sort); do
    min=$(echo "${temps_by_day[$day]}" | awk '{min=$1; for(i=2;i<=NF;i++) if($i<min) min=$i; print min}')
    max=$(echo "${temps_by_day[$day]}" | awk '{max=$1; for(i=2;i<=NF;i++) if($i>max) max=$i; print max}')
    cast+="┍━━━━━┫  <b>$day</b> ┠━━━━━┑\n"
    cast+="${lines_by_day[$day]}"
    cast+="↑ min: <b>$(awk -v m="$min" 'BEGIN {printf "%.2f", m}')°C</b> max: <b>$(awk -v m="$max" 'BEGIN {printf "%.2f", m}')°C</b>\n\n"
  done

  ret_tooltip=$(echo -e "$cast")
else
  ret_tooltip="Could not process forecast file ($FORECAST_FILE)"
fi

# --- Final JSON Output ---
echo $(jq -n \
  --arg text "$ret_text" \
  --arg tooltip "$ret_tooltip" \
  --arg class "$ret_class" \
  --argjson percentage "$ret_percentage" \
  '{text: $text, tooltip: $tooltip, class: $class, percentage: $percentage}')