# Hướng Dẫn Build

Sau khi thêm các tính năng mới, bạn cần chạy các lệnh sau để generate code:

## 1. Generate Code

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Lệnh này sẽ tạo các file:

### JSON Serialization:
- `lib/core/services/map/historical_location_model.g.dart`

### Freezed Code:
- `lib/feature/map/presentation/bloc/map_state.freezed.dart`
- `lib/feature/map/presentation/bloc/map_event.freezed.dart`
- `lib/core/common/models/app_error.freezed.dart`

## 3. Chạy App

Sau khi generate code xong, bạn có thể chạy app:

```bash
flutter run
```

## Lưu ý

- Đảm bảo file `assets/historical_locations.json` đã được thêm vào `pubspec.yaml`
- Nếu gặp lỗi, thử xóa thư mục `.dart_tool` và chạy lại:
  ```bash
  rm -rf .dart_tool
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

## Tính Năng Đã Thêm

### Historical Markers
✅ Historical markers hiển thị trên bản đồ
✅ Tap vào marker để xem thông tin chi tiết
✅ Tự động load khi mở bản đồ
✅ Markers có màu đỏ để phân biệt với user location (màu xanh)
✅ Marker được chọn sẽ có màu cam

### Marker Clustering
✅ Tự động nhóm markers khi zoom out
✅ Cluster markers có màu tím
✅ Tap vào cluster để zoom in
✅ Hiển thị số lượng địa điểm trong cluster

### Error Handling
✅ Standardized error handling với Either pattern
✅ AppError model với các loại errors: Network, Location, API, Cache, Unknown
✅ User-friendly error messages
✅ Retry functionality dựa trên loại error
