# Navigate to your project root directory
cd pet_health_companion

# Build the APK. This creates app-release.apk in build/app/outputs/flutter-apk/
flutter build apk --release

# For a more optimized bundle format (preferred for Play Store):
flutter build appbundle --release
# This creates app-release.aab in build/app/outputs/bundle/release/