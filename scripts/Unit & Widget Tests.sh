# Run all tests in the project
flutter test

# Run tests in a specific file
flutter test test/features/auth/domain/usecases/sign_in_with_email_test.dart

# Get a coverage report (after adding `flutter_test_coverage` to dev_dependencies)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# Then open coverage/html/index.html in your browser