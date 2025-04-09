
# Specs:
# 1. Find amongst open apps, user specifies which ones they want to switch betweeen
# 2. User sets a timer for how long to wait to switch between apps
# 3. Specify how long to stay on an app before switching

#!/bin/bash

# Default values
stay_duration=10        # Time to stay on each app (in seconds)
total_runtime=60        # Total runtime (in seconds)
apps=( ) 

# Help message
show_help() {
  echo "Usage: $0 [-t total_runtime_seconds] [-s stay_duration_seconds]"
  echo ""
  echo "Options:"
  echo "  -t, --time    Total time to run the switcher (in seconds)"
  echo "  -s, --stay    Time to stay on each app before switching (in seconds)"
  echo "  -h, --help    Show this help message"
  exit 1
}

# Parse flags
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -t|--time) total_runtime="$2"; shift 2 ;;
    -s|--stay) stay_duration="$2"; shift 2 ;;
    -a|--apps) IFS=',' read -r -a apps <<< "$2"; shift 2 ;;    
    -h|--help) show_help ;;
    *) echo "Unknown parameter passed: $1"; show_help ;;
  esac
done

# Calculate how many full switches we can make
app_count=${#apps[@]}
if [[ "$app_count" -eq 0 ]]; then
  echo "No apps specified."
  exit 1
fi

switches=$(( total_runtime / stay_duration ))

echo "Running app switcher..."
echo "Apps: ${apps[*]}"
echo "Total runtime: $total_runtime seconds"
echo "Stay duration: $stay_duration seconds per app"
echo "Calculated switch cycles: $switches"

switch_count=0

while [[ "$switch_count" -lt "$switches" ]]; do
  for app in "${apps[@]}"; do
    if [[ "$switch_count" -ge "$switches" ]]; then
      break
    fi

    if pgrep -x "$app" > /dev/null; then
      echo "Switching to $app..."
      osascript -e "tell application \"$app\" to activate"
    else
      echo "App '$app' not running. Skipping."
    fi

    ((switch_count++))
    sleep "$stay_duration"
  done
done

echo "App switcher finished after $switch_count switches."

