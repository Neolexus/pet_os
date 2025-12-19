# Set up environment variables
cp .env.example .env
# Add your API keys to .env file

# Get dependencies
flutter pub get

# Run tests
flutter test

# Build APK
flutter build apk --release

# For app bundle
flutter build appbundle --release