#!/bin/bash

# Flutter TicTacToe - Testing Script
# This script runs all test suites and generates reports

set -e

echo "🧪 Flutter TicTacToe Testing Suite"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${2}[$1]${NC} $3"
}

# Check if Flutter is installed
print_status "CHECK" "$BLUE" "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_status "ERROR" "$RED" "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "SUCCESS" "$GREEN" "Flutter found: $(flutter --version | head -n 1)"

# Check dependencies
print_status "CHECK" "$BLUE" "Checking dependencies..."
flutter doctor

# Run pub get
print_status "SETUP" "$BLUE" "Installing dependencies..."
flutter pub get

# Clean build
print_status "BUILD" "$BLUE" "Cleaning previous builds..."
flutter clean

# Run unit tests
print_status "UNIT" "$YELLOW" "Running Unit Tests..."
if flutter test test/unit/ --coverage --reporter json > reports/unit_tests.json; then
    print_status "SUCCESS" "$GREEN" "Unit tests passed"
    
    # Generate coverage report
    genhtml coverage/lcov.info -o reports/unit_coverage.html
    print_status "COVERAGE" "$GREEN" "Unit coverage report generated: reports/unit_coverage.html"
else
    print_status "FAILED" "$RED" "Unit tests failed"
    exit 1
fi

# Run widget tests
print_status "WIDGET" "$YELLOW" "Running Widget Tests..."
if flutter test test/widget/ --coverage --reporter json > reports/widget_tests.json; then
    print_status "SUCCESS" "$GREEN" "Widget tests passed"
    
    # Generate coverage report
    genhtml coverage/lcov.info -o reports/widget_coverage.html
    print_status "COVERAGE" "$GREEN" "Widget coverage report generated: reports/widget_coverage.html"
else
    print_status "FAILED" "$RED" "Widget tests failed"
    exit 1
fi

# Run integration tests
print_status "INTEGRATION" "$YELLOW" "Running Integration Tests..."
if flutter test test/integration/ --reporter json > reports/integration_tests.json; then
    print_status "SUCCESS" "$GREEN" "Integration tests passed"
else
    print_status "FAILED" "$RED" "Integration tests failed"
    exit 1
fi

# Run smoke tests
print_status "SMOKE" "$YELLOW" "Running Smoke Tests..."
if flutter test test/smoke/ --reporter json > reports/smoke_tests.json; then
    print_status "SUCCESS" "$GREEN" "Smoke tests passed"
else
    print_status "FAILED" "$RED" "Smoke tests failed"
    exit 1
fi

# Generate combined coverage report
print_status "COVERAGE" "$BLUE" "Generating combined coverage report..."
lcov --remove coverage/lcov.info '*/lib/generated/*' -o coverage/filtered.info
genhtml coverage/filtered.info -o reports/combined_coverage.html

# Run performance tests
print_status "PERFORMANCE" "$YELLOW" "Running Performance Tests..."
if flutter test test/performance/ --profile --reporter json > reports/performance_tests.json; then
    print_status "SUCCESS" "$GREEN" "Performance tests passed"
else
    print_status "FAILED" "$RED" "Performance tests failed"
    exit 1
fi

# Build APK for testing
print_status "BUILD" "$BLUE" "Building APK for testing..."
flutter build apk --debug --build-name=tictactoe-test

# Run accessibility tests
print_status "ACCESSIBILITY" "$YELLOW" "Running Accessibility Tests..."
if flutter test test/accessibility/ --reporter json > reports/accessibility_tests.json; then
    print_status "SUCCESS" "$GREEN" "Accessibility tests passed"
else
    print_status "FAILED" "$RED" "Accessibility tests failed"
    exit 1
fi

# Generate test summary
print_status "SUMMARY" "$BLUE" "Generating test summary..."
cat > reports/test_summary.md << EOF
# Flutter TicTacToe - Test Summary

## Test Results
- ✅ Unit Tests: Passed
- ✅ Widget Tests: Passed  
- ✅ Integration Tests: Passed
- ✅ Smoke Tests: Passed
- ✅ Performance Tests: Passed
- ✅ Accessibility Tests: Passed
- ✅ Build: Successful

## Coverage Reports
- [Unit Coverage](reports/unit_coverage.html)
- [Widget Coverage](reports/widget_coverage.html)
- [Combined Coverage](reports/combined_coverage.html)

## Artifacts
- [Test APK](build/app/outputs/flutter-apk/app-debug.apk)

## Performance Metrics
Total tests: $(find test -name "*.dart" -exec grep -l "test(" {} \; | wc -l)
Test duration: $(date +%s)
EOF

print_status "COMPLETE" "$GREEN" "All tests completed successfully!"
echo ""
echo "📊 Reports generated in 'reports/' directory:"
echo "  - unit_tests.json"
echo "  - widget_tests.json" 
echo "  - integration_tests.json"
echo "  - smoke_tests.json"
echo "  - performance_tests.json"
echo "  - accessibility_tests.json"
echo "  - test_summary.md"
echo "  - unit_coverage.html"
echo "  - widget_coverage.html"
echo "  - combined_coverage.html"
echo ""
echo "📱 APK built: build/app/outputs/flutter-apk/app-debug.apk"
echo ""
print_status "SUCCESS" "$GREEN" "Testing completed! Ready for deployment."