#!/bin/bash
# 🔒 ПРОВЕРКА НА СИГУРНОСТТА - ДИАГНОСТИЧЕН
echo "=== 🔒 SECURITY AUDITOR ==="

echo "🔍 Checking ADB debugging status..."
ADB_STATUS=$(adb shell settings get global adb_enabled 2>/dev/null)
echo "📱 ADB Debugging: $ADB_STATUS"

echo ""
echo "🌐 Checking network connections..."
echo "📡 Listening ports:"
adb shell netstat -tulpn 2>/dev/null | grep LISTEN | head -15

echo ""
echo "🔓 Checking installed apps..."
echo "⚠️ Potentially dangerous apps (user installed):"
adb shell pm list packages -3 | sed 's/package://g' | grep -E "(debug|test|root|admin)" || echo "✅ No suspicious apps found"

echo ""
echo "📱 App permissions audit..."
echo "🔐 Apps with dangerous permissions:"
adb shell dumpsys package | grep -A2 "android.permission.INTERNET" | grep "Package" | head -10

echo ""
echo "🔒 Security recommendations:"
if [ "$ADB_STATUS" = "1" ]; then
    echo "❌ ADB debugging is ENABLED - consider disabling in production"
else
    echo "✅ ADB debugging is disabled - good for security"
fi

echo ""
echo "✅ Security audit complete!"
