#!/bin/bash
# 🚀 ОПТИМИЗАЦИЯ НА TV ПРОИЗВОДИТЕЛНОСТ - ПРЕПОРЪЧИТЕЛЕН!
echo "=== 🚀 PERFORMANCE BOOSTER ==="

echo "🔍 Checking current performance..."
MEM_BEFORE=$(adb shell free -m | grep Mem: | awk '{print $4}')
echo "🧠 Available memory before: ${MEM_BEFORE}MB"

echo ""
echo "🧹 Clearing app caches..."
CACHE_APPS=(
    "com.netflix.ninja"
    "com.amazon.firetv.youtube" 
    "com.google.android.youtube.tv"
    "com.spotify.music"
    "com.hulu.plus"
)

for app in "${CACHE_APPS[@]}"; do
    if adb shell pm list packages | grep -q "$app"; then
        adb shell pm clear "$app"
        echo "✅ Cleared cache: $app"
    fi
done

echo ""
echo "🗑️ Removing temporary files..."
adb shell rm -rf /data/local/tmp/* 2>/dev/null
adb shell rm -rf /cache/* 2>/dev/null
echo "✅ Temp files cleaned"

echo ""
echo "🔧 Restarting system UI..."
adb shell am force-stop com.android.systemui
sleep 2
adb shell input keyevent KEYCODE_HOME
echo "✅ UI restarted"

echo ""
echo "📊 Performance report:"
MEM_AFTER=$(adb shell free -m | grep Mem: | awk '{print $4}')
echo "🧠 Available memory after: ${MEM_AFTER}MB"
echo "📈 Memory freed: $((MEM_AFTER - MEM_BEFORE))MB"

echo ""
echo "✅ Performance optimization complete!"
