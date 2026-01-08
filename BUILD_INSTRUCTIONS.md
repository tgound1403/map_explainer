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
✅ 27 địa điểm lịch sử (14 địa điểm miền Bắc + 13 địa điểm miền Nam)
✅ Tập trung vào khu vực TP.HCM và các tỉnh lân cận
✅ Các địa điểm liên quan đến kháng chiến chống Mỹ

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

### Custom Marker Icons
✅ Custom icons cho các loại địa điểm khác nhau
✅ MarkerIconService để quản lý và cache icons
✅ Icons phân biệt theo type (Di tích, Bảo tàng, Đền, Chùa, etc.)
✅ Selected markers có visual feedback
✅ Cluster markers với số lượng hiển thị

### Animations & Transitions
✅ AppAnimations utility với các animation helpers
✅ Smooth tab switching với AnimatedSwitcher
✅ Fade-slide animations cho information boxes
✅ Improved bottom sheet animations
✅ Material transitions cho navigation

### Edge Zoom Gesture
✅ Zoom bằng cách vuốt ở cạnh màn hình
✅ EdgeZoomGestureDetector widget
✅ Vuốt lên/xuống ở cạnh trái/phải để zoom
✅ Vuốt trái/phải ở cạnh trên/dưới để zoom
✅ Zoom indicator hiển thị level hiện tại
✅ Throttle mechanism để tránh zoom quá nhanh
