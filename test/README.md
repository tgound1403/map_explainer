# Test Documentation

## Test Structure

```
test/
  core/
    helpers/
      test_helpers.dart      # Hive setup/teardown utilities
      test_data.dart         # Test data factories
    services/
      social/
        collections_service_test.dart
        favorites_service_test.dart
      tours/
        tour_service_test.dart
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/core/services/social/collections_service_test.dart
```

### Run with coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Utilities

### test_helpers.dart
- `setupHiveForTesting()` - Setup Hive với temporary directory
- `tearDownHiveForTesting()` - Cleanup sau tests
- `resetHiveBoxes()` - Reset tất cả Hive boxes

### test_data.dart
- `createMockHistoricalLocation()` - Tạo mock location
- `createMockCollection()` - Tạo mock collection
- `createMockTour()` - Tạo mock tour
- `createMockFavoriteItem()` - Tạo mock favorite item
- `TestData` class - Sample data cho testing

## Test Coverage Goals

- **CollectionsService**: >80%
- **TourService**: >80%
- **FavoritesService**: >70%
- **SearchService**: >70%

## Notes

- Tests sử dụng temporary directory cho Hive để tránh ảnh hưởng đến data thật
- Mỗi test được isolate với setUp/tearDown
- Tests được viết theo Arrange-Act-Assert pattern
