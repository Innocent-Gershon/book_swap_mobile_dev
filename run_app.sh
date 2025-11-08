#!/bin/bash

echo "🚀 Starting BookSwap App..."
echo "📱 Make sure you have a device/emulator connected"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation
echo "🔧 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check for devices
echo "📱 Available devices:"
flutter devices

echo ""
echo "🎯 Running app..."
flutter run

echo "✅ App started successfully!"
