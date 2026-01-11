# 🧪 Kế Hoạch Chi Tiết: Testing Infrastructure

**Task**: Setup Testing Infrastructure & Unit Tests cho Core Services  
**Thời gian**: Tuần 1, Day 1-2 (Jan 9-10, 2026)  
**Mục tiêu**: Test coverage >50% cho core services

---

## 📋 TỔNG QUAN

### Mục tiêu
- Setup test environment và utilities
- Viết unit tests cho các core services quan trọng
- Đạt test coverage >50% cho services layer

### Services cần test (Priority Order)
1. **CollectionsService** - High priority (feature mới)
2. **TourService** - High priority (feature mới)
3. **FavoritesService** - High priority (feature quan trọng)
4. **SearchService** - Medium priority (đã có một phần)
5. **ShareService** - Medium priority
6. **HistoricalLocationService** - Medium priority
7. **CacheService** - Low priority (đã có logic đơn giản)
8. **RetryService** - Low priority
9. **TextToSpeechService** - Low priority (platform-specific)

---

## 🎯 DAY 1: Setup Test Environment (Jan 9, 2026)

### Task 1.1: Kiểm tra và cài đặt Test Dependencies (30 phút)

#### Bước 1: Kiểm tra pubspec.yaml
- [ ] Kiểm tra `flutter_test` đã có trong dev_dependencies
- [ ] Thêm `mockito` và `build_runner` nếu chưa có
- [ ] Thêm `hive_test` cho Hive testing
- [ ] Thêm `fake_async` cho async testing

#### Bước 2: Cài đặt dependencies
```bash
flutter pub add --dev mockito build_runner
flutter pub add --dev hive_test
```

#### Bước 3: Verify setup
- [ ] Chạy `flutter pub get`
- [ ] Verify các packages đã được cài đặt

**Deliverable**: pubspec.yaml với đầy đủ test dependencies

---

### Task 1.2: Tạo Test Utilities & Helpers (1-2 giờ)

#### Bước 1: Tạo test helpers structure
```
test/
  core/
    services/
      (existing tests)
    helpers/
      test_helpers.dart
      mock_factories.dart
      test_data.dart
```

#### Bước 2: Tạo test_helpers.dart
- [ ] `setupHiveForTesting()` - Setup Hive cho tests
- [ ] `tearDownHiveForTesting()` - Cleanup Hive sau tests
- [ ] `createMockHistoricalLocation()` - Factory cho test data
- [ ] `createMockCollection()` - Factory cho collections
- [ ] `createMockTour()` - Factory cho tours

#### Bước 3: Tạo test_data.dart
- [ ] Sample historical locations data
- [ ] Sample collections data
- [ ] Sample tours data
- [ ] Sample favorites data

#### Bước 4: Tạo mock_factories.dart
- [ ] Mock classes cho dependencies (nếu cần)

**Deliverable**: Test utilities folder với helpers và test data

---

### Task 1.3: Setup Test Configuration (30 phút)

#### Bước 1: Tạo test configuration
- [ ] Tạo `test_setup.dart` với global setup/teardown
- [ ] Setup Hive initialization cho tests
- [ ] Setup mocks và fakes

#### Bước 2: Tạo test README
- [ ] Document test structure
- [ ] Document test utilities usage
- [ ] Document test conventions

**Deliverable**: Test setup configuration và documentation

---

## 🎯 DAY 2: Unit Tests cho Core Services (Jan 10, 2026)

### Task 2.1: CollectionsService Tests (2-3 giờ)

#### Test Cases cần cover:

##### 1. CRUD Operations
- [ ] `createCollection()` - Tạo collection mới
  - Test: Tạo collection thành công
  - Test: Tạo collection với name trùng → throw error
  - Test: Tạo collection với invalid data → throw error
  
- [ ] `getCollection()` - Lấy collection theo ID
  - Test: Lấy collection tồn tại
  - Test: Lấy collection không tồn tại → return null
  
- [ ] `getAllCollections()` - Lấy tất cả collections
  - Test: Lấy tất cả collections
  - Test: Return empty list khi chưa có collections
  
- [ ] `updateCollection()` - Cập nhật collection
  - Test: Update collection thành công
  - Test: Update collection không tồn tại → throw error
  
- [ ] `deleteCollection()` - Xóa collection
  - Test: Xóa collection thành công
  - Test: Xóa collection không tồn tại → throw error

##### 2. Item Management
- [ ] `addItemToCollection()` - Thêm item vào collection
  - Test: Thêm location vào collection
  - Test: Thêm chat vào collection
  - Test: Thêm item đã tồn tại → không duplicate
  - Test: Thêm vào collection không tồn tại → throw error
  
- [ ] `removeItemFromCollection()` - Xóa item khỏi collection
  - Test: Xóa item thành công
  - Test: Xóa item không tồn tại → no error
  
- [ ] `getCollectionItems()` - Lấy items trong collection
  - Test: Lấy items thành công
  - Test: Return empty list khi collection rỗng

##### 3. Edge Cases
- [ ] Test với empty/null inputs
- [ ] Test với invalid IDs
- [ ] Test với Hive errors
- [ ] Test concurrent operations

**File**: `test/core/services/social/collections_service_test.dart`

---

### Task 2.2: TourService Tests (2-3 giờ)

#### Test Cases cần cover:

##### 1. CRUD Operations
- [ ] `createTour()` - Tạo tour mới
  - Test: Tạo tour thành công
  - Test: Tạo tour với locationIds rỗng → throw error
  - Test: Tạo tour với invalid locationIds → throw error
  
- [ ] `getTour()` - Lấy tour theo ID
  - Test: Lấy tour tồn tại
  - Test: Lấy tour không tồn tại → return null
  
- [ ] `getAllTours()` - Lấy tất cả tours
  - Test: Lấy tất cả tours
  - Test: Filter premade tours
  - Test: Filter user tours
  
- [ ] `updateTour()` - Cập nhật tour
  - Test: Update tour thành công
  - Test: Update tour không tồn tại → throw error
  
- [ ] `deleteTour()` - Xóa tour
  - Test: Xóa tour thành công
  - Test: Không xóa được premade tours

##### 2. Tour Generation
- [ ] `generatePremadeTours()` - Tạo premade tours
  - Test: Tạo 3 premade tours
  - Test: Không tạo duplicate premade tours
  - Test: Premade tours có đúng locationIds

##### 3. Tour Metrics
- [ ] `calculateTourDistance()` - Tính khoảng cách tour
  - Test: Tính distance cho tour có locations
  - Test: Return 0 cho tour rỗng
  
- [ ] `calculateTourTime()` - Tính thời gian ước tính
  - Test: Tính time dựa trên distance
  - Test: Return 0 cho tour rỗng

##### 4. Edge Cases
- [ ] Test với empty/null inputs
- [ ] Test với invalid locationIds
- [ ] Test với Hive errors

**File**: `test/core/services/tours/tour_service_test.dart`

---

### Task 2.3: FavoritesService Tests (1-2 giờ)

#### Test Cases cần cover:

##### 1. Favorite Operations
- [ ] `addFavorite()` - Thêm favorite
  - Test: Thêm location favorite
  - Test: Thêm chat favorite
  - Test: Thêm favorite đã tồn tại → không duplicate
  
- [ ] `removeFavorite()` - Xóa favorite
  - Test: Xóa favorite thành công
  - Test: Xóa favorite không tồn tại → no error
  
- [ ] `isFavorite()` - Kiểm tra favorite
  - Test: Return true cho favorite tồn tại
  - Test: Return false cho favorite không tồn tại
  
- [ ] `getFavorites()` - Lấy tất cả favorites
  - Test: Lấy tất cả favorites
  - Test: Filter theo type (location/chat)
  - Test: Sort theo createdAt

##### 2. Edge Cases
- [ ] Test với empty/null inputs
- [ ] Test với invalid item types
- [ ] Test với Hive errors

**File**: `test/core/services/social/favorites_service_test.dart`

---

### Task 2.4: SearchService Tests (1-2 giờ)

#### Test Cases cần cover:

##### 1. Search Operations
- [ ] `search()` - Tìm kiếm locations
  - Test: Search theo name
  - Test: Search theo description
  - Test: Search theo type
  - Test: Search theo period
  - Test: Search với query rỗng → return all
  - Test: Search không có kết quả → return empty
  
- [ ] `searchRelevance()` - Relevance sorting
  - Test: Name matches có priority cao hơn
  - Test: Description matches có priority thấp hơn
  - Test: Multiple matches được sort đúng

##### 2. Search History
- [ ] `addToHistory()` - Thêm vào history
  - Test: Thêm search query
  - Test: Không duplicate recent searches
  - Test: Limit history to 20 items
  
- [ ] `getSearchHistory()` - Lấy search history
  - Test: Lấy history sorted by recent
  - Test: Return empty khi chưa có history
  
- [ ] `clearSearchHistory()` - Xóa history
  - Test: Xóa tất cả history

**File**: `test/core/services/search/search_service_test.dart`

---

## 📊 TEST COVERAGE TARGETS

### Services Coverage Goals
- **CollectionsService**: >80%
- **TourService**: >80%
- **FavoritesService**: >70%
- **SearchService**: >70%
- **ShareService**: >60%
- **HistoricalLocationService**: >60%

### Overall Target
- **Services Layer**: >50% coverage
- **Critical Paths**: 100% coverage

---

## 🛠️ TESTING TOOLS & SETUP

### Dependencies Needed
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.15
  hive_test: (if available) hoặc mock Hive
```

### Test Structure
```
test/
  core/
    services/
      social/
        collections_service_test.dart
        favorites_service_test.dart
        share_service_test.dart
      tours/
        tour_service_test.dart
      search/
        search_service_test.dart
      map/
        historical_location_service_test.dart
    helpers/
      test_helpers.dart
      mock_factories.dart
      test_data.dart
  test_setup.dart
```

---

## ✅ CHECKLIST HOÀN THÀNH

### Day 1 Checklist
- [ ] Test dependencies đã được cài đặt
- [ ] Test utilities và helpers đã được tạo
- [ ] Test data factories đã được tạo
- [ ] Test setup configuration đã được tạo
- [ ] Documentation đã được viết

### Day 2 Checklist
- [ ] CollectionsService tests đã được viết và pass
- [ ] TourService tests đã được viết và pass
- [ ] FavoritesService tests đã được viết và pass
- [ ] SearchService tests đã được viết và pass
- [ ] Test coverage >50% đã đạt được
- [ ] Tất cả tests đều pass

---

## 🚀 NEXT STEPS (Sau khi hoàn thành)

1. **Run Coverage Report**
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   ```

2. **Review Coverage**
   - Xem coverage report
   - Identify gaps
   - Plan additional tests nếu cần

3. **Documentation**
   - Update test README với results
   - Document test patterns và best practices

4. **CI/CD Integration** (sẽ làm sau)
   - Setup automated test runs
   - Setup coverage reporting

---

## 📝 NOTES

### Testing Best Practices
1. **Arrange-Act-Assert Pattern**: Mỗi test nên có 3 phần rõ ràng
2. **Test Isolation**: Mỗi test độc lập, không phụ thuộc vào test khác
3. **Mock External Dependencies**: Mock Hive, network calls, etc.
4. **Test Edge Cases**: Test với null, empty, invalid inputs
5. **Test Error Handling**: Test error scenarios

### Common Patterns
```dart
// Setup
setUp(() {
  // Initialize test data
});

// Test
test('should do something', () {
  // Arrange
  final service = CollectionsService.instance;
  
  // Act
  final result = service.createCollection(...);
  
  // Assert
  expect(result, isNotNull);
  expect(result.name, equals('Test Collection'));
});

// Teardown
tearDown(() {
  // Cleanup
});
```

---

**Tài liệu được tạo bởi**: AI Assistant  
**Ngày**: 2026-01-09  
**Version**: 1.0.0
