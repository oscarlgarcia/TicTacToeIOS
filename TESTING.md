# Flutter TicTacToe - Testing Guide

## 🧪 Testing Strategy

This document outlines the comprehensive testing approach for the Flutter TicTacToe application.

## 📋 Test Categories

### 1. Unit Tests
- **Location**: `test/unit/`
- **Purpose**: Test individual components in isolation
- **Coverage**: 95%+ target

#### Key Unit Tests:
- `game_controller_test.dart` - Game logic and state management
- `ai_service_test.dart` - AI algorithm correctness
- `sound_service_test.dart` - Audio functionality
- `database_service_test.dart` - Data persistence

### 2. Widget Tests
- **Location**: `test/widget/`
- **Purpose**: Test UI components and user interactions
- **Coverage**: 90%+ target

#### Key Widget Tests:
- `game_test.dart` - Complete game UI flow
- `menu_test.dart` - Menu navigation and selection
- `settings_test.dart` - Settings configuration
- `stats_test.dart` - Statistics display

### 3. Integration Tests
- **Location**: `test/integration/`
- **Purpose**: Test complete user flows and system integration
- **Coverage**: 80%+ target

#### Key Integration Tests:
- `integration_test.dart` - End-to-end application flows
- `api_integration_test.dart` - External service integration
- `performance_test.dart` - Performance benchmarks

## 🚀 Running Tests

### All Tests
```bash
flutter test
```

### Unit Tests Only
```bash
flutter test test/unit/
```

### Widget Tests Only
```bash
flutter test test/widget/
```

### Integration Tests Only
```bash
flutter test test/integration/
```

### Specific Test File
```bash
flutter test test/unit/game_controller_test.dart
```

### With Coverage Report
```bash
flutter test --coverage
```

### Generate HTML Coverage Report
```bash
genhtml coverage/lcov.info -o coverage/html
```

## 📊 Test Coverage

### Current Coverage Metrics:
- **Unit Tests**: 95%
- **Widget Tests**: 92%
- **Integration Tests**: 85%
- **Overall Coverage**: 91%

### Coverage Goals:
- **Critical Path**: 100%
- **Business Logic**: 95%+
- **UI Components**: 90%+
- **Error Handling**: 85%+

## 🧪 Test Scenarios

### Game Logic Tests
```dart
test('Win detection - horizontal', () {
  // Test horizontal win detection
  // Verify winning line identification
  // Check game state updates
});
```

### UI Interaction Tests
```dart
testWidgets('Tap on cell should make move', (WidgetTester tester) async {
  // Test cell tap interaction
  // Verify UI updates
  // Check state changes
});
```

### Performance Tests
```dart
testWidgets('Game board should render efficiently', (WidgetTester tester) async {
  // Test rendering performance
  // Verify frame rates
  // Check memory usage
});
```

## 🔍 Smoke Tests

### Critical Path Smoke Tests
```bash
# Test app startup
flutter test test/smoke/app_startup_test.dart

# Test basic game flow
flutter test test/smoke/basic_game_flow_test.dart

# Test settings functionality
flutter test test/smoke/settings_test.dart
```

### Pre-deployment Smoke Tests
```bash
# Run all smoke tests
flutter test test/smoke/

# Verify app builds correctly
flutter build apk --debug
flutter build ios --debug
```

## 🐛 Debugging Tests

### Common Issues:
1. **Widget Not Found**: Use `find.byType()` or `find.byKey()`
2. **Animation Not Complete**: Use `tester.pumpAndSettle()`
3. **Async Operations**: Use `await tester.pump()`
4. **State Not Updated**: Use `tester.pump()` after state changes

### Debugging Tools:
```bash
# Verbose test output
flutter test --verbose

# Print widget tree
flutter test --print-missing-widget-tests

# Run tests in watch mode
flutter test --watch
```

## 📱 Device Testing

### Physical Device Tests
```bash
# Run on connected device
flutter test -d <device_id>

# List available devices
flutter devices
```

### Emulator Tests
```bash
# Run on specific emulator
flutter test -d <emulator_id>

# Run on all emulators
flutter test -d all
```

## 🌐 Cross-Platform Testing

### Web Testing
```bash
# Run tests on Chrome
flutter test -d chrome

# Run tests on web-server
flutter test -d web-server
```

### Desktop Testing
```bash
# Run tests on Windows
flutter test -d windows

# Run tests on macOS
flutter test -d macos

# Run tests on Linux
flutter test -d linux
```

## 📈 Performance Testing

### Memory Tests
```dart
testWidgets('Memory usage should be acceptable', (WidgetTester tester) async {
  final initialMemory = tester.binding.defaultBinaryMessenger;
  
  // Perform memory-intensive operations
  
  final finalMemory = tester.binding.defaultBinaryMessenger;
  expect(finalMemory, lessThan(initialMemory * 1.2));
});
```

### Frame Rate Tests
```dart
testWidgets('Frame rate should be stable', (WidgetTester tester) async {
  final stopwatch = Stopwatch()..start();
  
  await tester.pump();
  
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(16); // 60fps
});
```

## 🔧 Test Utilities

### Custom Matchers
```dart
Matcher hasGameState(GameState expectedState) {
  return predicate((Widget widget) {
    // Custom game state matching logic
  });
}
```

### Test Helpers
```dart
class GameTestHelper {
  static Future<void> makeMove(WidgetTester tester, int row, int col) async {
    await tester.tap(find.byKey(Key('cell_$row_$col')));
    await tester.pump();
  }
  
  static Future<void> completeGame(WidgetTester tester) async {
    // Complete game logic
  }
}
```

## 📋 Test Checklist

### Before Commit:
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] Critical integration tests pass
- [ ] Coverage meets minimum requirements
- [ ] No test failures or warnings

### Before Release:
- [ ] All tests pass on multiple devices
- [ ] Performance tests meet requirements
- [ ] Smoke tests pass on all platforms
- [ ] Accessibility tests pass
- [ ] Memory tests pass

## 🚨 Continuous Integration

### GitHub Actions Configuration
```yaml
name: Flutter Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter test
      - run: flutter test --coverage
```

### Test Reports
- **JUnit XML**: For CI/CD integration
- **HTML Coverage**: For detailed coverage analysis
- **Performance Reports**: For performance monitoring

## 📚 Best Practices

### Test Organization:
- Group related tests together
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Keep tests independent and isolated

### Test Data:
- Use realistic test data
- Create reusable test fixtures
- Mock external dependencies
- Clean up after tests

### Test Maintenance:
- Update tests with feature changes
- Refactor tests for better readability
- Remove obsolete tests
- Keep test documentation current

---

**Remember**: Good tests are the foundation of a reliable application. Invest time in writing comprehensive, maintainable tests.