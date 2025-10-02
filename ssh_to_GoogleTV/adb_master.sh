#!/bin/bash
# 🎮 ПЪЛЕН КОНТРОЛ НА TV ПРЕЗ ADB - ЗАДЪЛЖИТЕЛЕН!
echo "=== 🎮 ADB MASTER CONTROLLER ==="

if [ $# -eq 0 ]; then
    echo "❌ Usage: $0 {screen|install apk|uninstall package|reboot|apps|info}"
    echo ""
    echo "Examples:"
    echo "  $0 screen                    - 📸 Take screenshot"
    echo "  $0 install /sdcard/app.apk   - 📦 Install app"
    echo "  $0 uninstall com.example.app - 🗑️ Remove app"
    echo "  $0 reboot                    - 🔃 Reboot TV"
    echo "  $0 apps                      - 📱 List user apps"
    echo "  $0 info                      - ℹ️ System info"
    exit 1
fi

case $1 in
    "screen")
        FILENAME="screen_$(date +%Y%m%d_%H%M%S).png"
        adb exec-out screencap -p > "$FILENAME"
        echo "📸 Screenshot saved: $FILENAME"
        ;;
    "install")
        if [ -n "$2" ]; then
            adb install -r "$2"
            echo "📦 App installed: $2"
        else
            echo "❌ Please specify APK file"
        fi
        ;;
    "uninstall")
        if [ -n "$2" ]; then
            adb uninstall "$2"
            echo "🗑️ App removed: $2"
        else
            echo "❌ Please specify package name"
        fi
        ;;
    "reboot")
        adb reboot
        echo "🔃 Rebooting TV..."
        ;;
    "apps")
        echo "📱 User installed apps:"
        adb shell pm list packages -3 | sed 's/package://g'
        ;;
    "info")
        echo "📊 Device Information:"
        adb shell getprop ro.product.model
        adb shell getprop ro.build.version.release
        ;;
    *)
        echo "❌ Unknown command: $1"
        ;;
esac
