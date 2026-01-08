# Core Widgets Library

Thư viện các widgets tái sử dụng cho ứng dụng.

## Cấu trúc

### State Widgets
- **LoadingWidget**: Hiển thị loading state với nhiều styles (centered, inline, minimal, fullScreen)
- **ErrorDisplayWidget**: Hiển thị error state với retry functionality
- **RetryErrorWidget**: Error widget với retry và exponential backoff
- **EnhancedEmptyState**: Empty state widget với contextual messages và illustrations

### Action Widgets
- **TTSButton**: Button để play/pause Text-to-Speech
- **ToggleButton**: Toggle button với animation
- **EdgeZoomGestureDetector**: Custom gesture detector cho edge zoom

### Indicator Widgets
- **OfflineIndicator**: Hiển thị trạng thái offline
- **OfflineBanner**: Banner hiển thị ở top khi offline

## Usage

### Loading Widget
```dart
LoadingWidget(
  message: 'Loading...',
  style: LoadingStyle.centered,
)
```

### Error Widget
```dart
ErrorDisplayWidget(
  message: 'Something went wrong',
  title: 'Error',
  onRetry: () => _retry(),
  style: ErrorStyle.banner,
)
```

### Empty State
```dart
EnhancedEmptyState.noData(
  title: 'No data',
  message: 'There is no data to display',
  onRefresh: () => _refresh(),
)
```

### TTS Button
```dart
TTSButton(
  text: 'Text to read',
  iconSize: 24,
)
```

## Best Practices

1. **Consistent Styling**: Sử dụng các widgets này để đảm bảo UI nhất quán
2. **Localization**: Tất cả widgets đều hỗ trợ localization
3. **Error Handling**: Luôn cung cấp retry callback khi có thể
4. **Accessibility**: Các widgets đều có semantic labels và tooltips
