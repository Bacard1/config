#!/bin/bash
# 📊 ДЕТАЙЛЕН СИСТЕМЕН ОТЧЕТ - ДИАГНОСТИЧЕН
echo "=== 📊 SYSTEM REPORT GENERATOR ==="

REPORT_FILE="tv_system_report_$(date +%Y%m%d_%H%M%S).txt"

{
echo "=========================================="
echo "       ANDROID TV SYSTEM REPORT"
echo "=========================================="
echo "Generated: $(date)"
echo ""

echo "📱 DEVICE INFORMATION:"
echo "----------------------"
adb shell getprop ro.product.manufacturer
adb shell getprop ro.product.model
adb shell getprop ro.product.device
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
echo ""

echo "💾 STORAGE INFORMATION:"
echo "----------------------"
adb shell df -h
echo ""

echo "🧠 MEMORY INFORMATION:"
echo "----------------------"
adb shell free -m
echo ""

echo "🌐 NETWORK INFORMATION:"
echo "----------------------"
adb shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print "IP Address: "$2}'
adb shell netstat -tulpn 2>/dev/null | grep LISTEN | head -10
echo ""

echo "📦 INSTALLED APPLICATIONS (User):"
echo "----------------------"
adb shell pm list packages -3 | sed 's/package://g' | head -20
echo ""

echo "🔥 SYSTEM TEMPERATURE:"
echo "----------------------"
adb shell cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -3 | while read temp; do
    echo "$((temp/1000))°C"
done

} > "$REPORT_FILE"

echo "✅ System report saved: $REPORT_FILE"
echo "📄 Content preview:"
head -20 "$REPORT_FILE"
