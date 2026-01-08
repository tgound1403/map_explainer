# Core Services

Thư viện các services cho ứng dụng, được tổ chức theo domain.

## Cấu trúc

### Interfaces
Tất cả services đều có interfaces trong `interfaces/` để dễ dàng test và mock:
- `AIServiceInterface`: Interface cho AI service
- `CacheServiceInterface`: Interface cho Cache service
- `MapServiceInterface`: Interface cho Map service
- `NetworkServiceInterface`: Interface cho Network service
- `VoiceServiceInterface`: Interface cho Voice/Text-to-Speech service

### Services

#### AI Services (`gemini_ai/`)
- **GeminiAI**: Service để tương tác với Google Gemini AI
  - `summary()`: Tạo summary từ input
  - `findRelated()`: Tìm thông tin liên quan
  - `generateResponse()`: Tạo response từ prompt

#### Cache Services (`cache/`)
- **CacheService**: Service để quản lý caching với Hive
  - `cacheHistoricalLocations()`: Cache historical locations
  - `getCachedHistoricalLocations()`: Lấy cached locations
  - `cacheAIResponse()`: Cache AI responses
  - `getCachedAIResponse()`: Lấy cached AI response

#### Map Services (`map/`)
- **LocationService**: Service để lấy vị trí hiện tại
- **MapService**: Service để làm việc với maps
- **HistoricalLocationService**: Service để quản lý historical locations
- **MarkerClusterService**: Service để cluster markers
- **MarkerIconService**: Service để tạo custom marker icons

#### Network Services (`network/`)
- **NetworkConnectivityService**: Service để kiểm tra trạng thái kết nối mạng
  - `checkConnectivity()`: Kiểm tra trạng thái hiện tại
  - `connectivityStream`: Stream để lắng nghe thay đổi

#### Retry Services (`retry/`)
- **RetryService**: Service để retry operations với exponential backoff
  - `retry()`: Retry với exponential backoff
  - `retryWithJitter()`: Retry với jitter để tránh thundering herd

#### Offline & Sync Services (`offline/`, `sync/`)
- **OfflineFirstService**: Service để implement offline-first pattern
  - `getDataOfflineFirst()`: Lấy data với strategy cache-first, network-fallback
  - Background cache updates khi online
  - Automatic fallback khi offline
- **SyncService**: Service để quản lý background sync
  - `initialize()`: Khởi tạo và lắng nghe connectivity changes
  - `queueSyncOperation()`: Thêm operation vào sync queue
  - Auto sync khi connection restored
  - Historical locations sync

#### Voice Services (`voice/`)
- **TextToSpeechService**: Service để đọc text thành giọng nói
  - `speak()`: Đọc text
  - `stop()`: Dừng đọc
  - `setLanguage()`: Set language

#### Firebase Services (`firebase/`)
- **Firestore**: Service để làm việc với Firestore
  - `addData()`: Thêm data
  - `readAllData()`: Đọc tất cả data
  - `readSpecificData()`: Đọc data cụ thể
  - `modifyData()`: Sửa data
  - `deleteSpecificData()`: Xóa data

#### Wikipedia Services (`wikipedia/`)
- **WikipediaService**: Service để lấy thông tin từ Wikipedia

## Usage

### Dependency Injection
Tất cả services đều được đăng ký trong `ServiceLocator` (GetIt):

```dart
// Register service
getIt.registerLazySingleton<AIServiceInterface>(() => GeminiAI.instance);

// Use service
final aiService = getIt<AIServiceInterface>();
final response = await aiService.generateResponse('prompt');
```

### Error Handling
Tất cả services đều throw exceptions khi có lỗi. Sử dụng `ErrorConverter` để chuyển đổi thành `AppError`:

```dart
try {
  final result = await service.doSomething();
} catch (e, st) {
  final appError = ErrorConverter.fromException(e, st);
  // Handle error
}
```

### Retry Logic
Sử dụng `RetryService` cho các operations có thể retry:

```dart
await RetryService.instance.retry(
  operation: () => service.doSomething(),
  maxRetries: 3,
  onRetry: (attempt, delay) {
    // Handle retry attempt
  },
);
```

## Best Practices

1. **Use Interfaces**: Luôn sử dụng interfaces thay vì concrete implementations
2. **Error Handling**: Luôn handle errors và convert thành `AppError`
3. **Retry Logic**: Sử dụng `RetryService` cho network operations
4. **Caching**: Cache data khi có thể để giảm API calls
5. **Logging**: Sử dụng `Logger` để log errors và important events
