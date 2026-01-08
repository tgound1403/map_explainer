# Changelog

## [Unreleased]

### Added
- ✅ **Map View Refactoring**: Tách map_view.dart thành components để dễ maintain
  - MapInformationBox: Component hiển thị thông tin địa điểm ở top
  - MapBottomSheet: Draggable bottom sheet với haptic feedback và responsive snap sizes
  - HistoricalLocationCard: Card hiển thị thông tin địa điểm lịch sử
  - AIResponseCard: Card hiển thị AI response với expand/collapse
  - MapChipsList: Horizontal list của chips để chọn topic
  - Responsive snap sizes dựa trên screen height
  - Haptic feedback khi snap bottom sheet
  - Giảm file size từ 711 lines xuống ~400 lines
- ✅ **Voice Output (Text-to-Speech)**: Đọc AI responses và thông tin địa điểm
  - TextToSpeechService để đọc text thành giọng nói
  - TTSButton widget để play/pause đọc nội dung
  - Tự động set language dựa trên locale (Vietnamese/English)
  - Clean text: remove markdown, URLs, special formatting
  - Tích hợp vào MapView (AI responses), ChatView (AI messages), HistoricalLocationInfo
  - Stop/Play controls với visual feedback
  - Hỗ trợ cả tiếng Việt và tiếng Anh
- ✅ **Offline Mode**: Hỗ trợ hoạt động khi không có internet
  - NetworkConnectivityService để detect trạng thái kết nối mạng
  - ConnectivityProvider để quản lý và broadcast trạng thái connectivity
  - OfflineIndicator và OfflineBanner widgets để hiển thị trạng thái offline
  - Repository tự động fallback về cache khi offline
  - Background cache update khi có internet trở lại
  - User-friendly messages khi offline
  - Tự động sử dụng cached data khi không có internet
  - Hiển thị banner ở top khi offline với message "Using cached data"
- ✅ **Custom Marker Icons**: Icons tùy chỉnh cho các loại địa điểm khác nhau
  - MarkerIconService để tạo custom icons từ Material Icons
  - Icons khác nhau cho Di tích, Bảo tàng, Đền, Chùa, v.v.
  - Màu sắc phân biệt theo loại địa điểm
  - Selected marker có border đậm và background khác
  - Cluster markers hiển thị số lượng với custom design
  - Icon caching để tối ưu performance

- ✅ **Unit Tests**: Viết unit tests cho core services
  - Tests cho MarkerClusterService (clustering algorithm)
  - Tests cho ErrorConverter (error type conversion)
  - Tests cho MarkerIconService (icon generation và caching)
  - Test coverage cho các business logic quan trọng

- ✅ **Animations & Transitions**: Cải thiện animations và transitions
  - AppAnimations utility với các animation helpers (fade, slide, scale, bounce)
  - Custom page route transitions (SlidePageRoute, FadePageRoute, ScalePageRoute)
  - Smooth tab switching với AnimatedSwitcher
  - Fade-slide animations cho information boxes
  - Improved bottom sheet animations
  - Material transitions cho navigation

- ✅ **Historical Locations Expansion**: Mở rộng danh sách địa điểm lịch sử
  - Thêm 13 địa điểm mới ở khu vực TP.HCM và các tỉnh lân cận
  - Tập trung vào các địa điểm liên quan đến kháng chiến chống Mỹ
  - Bao gồm: Nhà tù Côn Đảo, Căn cứ Rừng Sác, Địa đạo Bến Dược, Khu di tích Ngã Ba Giồng
  - Các chiến trường: Long Tân, Bình Giã, Đồng Xoài, Ấp Bắc, Bến Cát, Phước Long
  - Căn cứ cách mạng: Tà Thiết, Nhà Bè
  - Tổng cộng 27 địa điểm lịch sử trong database

- ✅ **Edge Zoom Gesture**: Zoom bằng cách vuốt ở cạnh màn hình
  - EdgeZoomGestureDetector widget để detect swipe gestures ở cạnh màn hình
  - Vuốt lên/xuống ở cạnh trái/phải để zoom
  - Vuốt trái/phải ở cạnh trên/dưới để zoom
  - Swipe down/right = zoom in, swipe up/left = zoom out
  - Zoom indicator hiển thị level hiện tại khi đang zoom
  - Throttle mechanism để tránh zoom quá nhanh
  - Tích hợp mượt mà với Google Maps controller
  
- ✅ **Localization Support**: Hỗ trợ đa ngôn ngữ (Tiếng Việt & Tiếng Anh)
  - Setup Flutter localization với ARB files
  - LocaleProvider để quản lý ngôn ngữ
  - Language switcher trong General View
  - Tất cả strings trong app đã được localize
  - Lưu language preference vào SharedPreferences
  
- ✅ **Marker Clustering**: Tự động nhóm markers khi zoom out
  - Cluster markers có màu tím
  - Tap vào cluster để zoom in
  - Hiển thị số lượng địa điểm trong cluster
  - Cải thiện performance khi có nhiều markers
  
- ✅ **Error Handling Standardization**: Chuẩn hóa error handling với Either pattern
  - `AppError` model với các loại: Network, Location, API, Cache, Unknown
  - `ErrorConverter` để chuyển đổi exceptions thành AppError
  - Repository methods trả về `Either<AppError, T>`
  - UseCase và BLoC xử lý Either results
  - User-friendly error messages tự động
- ✅ **Reusable Loading & Error Widgets**: Tạo các widget tái sử dụng cho loading và error states
  - `LoadingWidget` với 4 styles: centered, inline, minimal, fullScreen
  - `ErrorDisplayWidget` với 4 styles: centered, inline, banner, fullScreen
  - Hỗ trợ retry button và custom messages
  
- ✅ **User-Friendly Error Messages**: Cải thiện error messages
  - `ErrorMessageHelper` để chuyển đổi technical errors thành messages thân thiện
  - Phân loại errors: network, location, API, timeout, etc.
  - Tự động hiển thị retry button khi phù hợp
  
- ✅ **Improved UX**: Cải thiện trải nghiệm người dùng
  - Loading states nhất quán trong toàn bộ app
  - Error states với retry functionality
  - Snackbar notifications cho errors
- ✅ **Historical Markers**: Thêm 14 địa điểm lịch sử Việt Nam hiển thị trên bản đồ
  - Markers có màu đỏ để phân biệt với user location (màu xanh)
  - Tap vào marker để xem thông tin chi tiết
  - Tự động load khi mở bản đồ
  
- ✅ **Caching System**: Implement caching strategy với Hive
  - Cache historical locations (24 giờ)
  - Cache AI responses (7 ngày)
  - Cache Wikipedia data (30 ngày)
  - Tự động xóa cache đã hết hạn
  
- ✅ **Dark Mode**: Hỗ trợ dark theme
  - Light và Dark theme với Material 3
  - Toggle button trong General View
  - Lưu preference vào SharedPreferences
  - Theme colors được tối ưu cho cả hai chế độ

### Changed
- Cải thiện performance với caching
- Tối ưu loading historical locations

### Fixed
- ✅ **Bug Fix: Provider Initialization**: Sửa lỗi khởi tạo async của ThemeProvider và LocaleProvider
  - Providers được khởi tạo và await trước khi được thêm vào widget tree
  - Sử dụng `ChangeNotifierProvider.value` thay vì `create` với cascade operator
  - Đảm bảo theme và locale preferences được load đúng từ SharedPreferences
  - Tránh việc app sử dụng giá trị mặc định ban đầu thay vì user preferences
- ✅ **Bug Fix: Edge Zoom Gesture Performance & Center Gestures**: Sửa lỗi performance và gestures ở giữa màn hình
  - Loại bỏ `await` trong `_performZoom` để không block UI thread
  - Tăng `_minZoomInterval` từ 150ms lên 250ms để giảm lag
  - Tăng threshold từ 30px lên 50px để tránh zoom nhạy cảm
  - Chỉ cho phép zoom ở cạnh phải màn hình (thay vì tất cả các cạnh)
  - Sử dụng `Positioned` với width = edgeWidth để chỉ đặt overlay ở cạnh phải
  - Đảm bảo GoogleMap có thể xử lý gestures ở giữa và các cạnh khác bình thường
  - Vuốt lên/xuống ở cạnh phải = zoom out/in

### Technical
- Setup Hive cho local storage
- Tạo CacheService để quản lý caching
- Tạo AppTheme và ThemeProvider
- Cập nhật MapRepository để sử dụng cache

## Next Steps
- [ ] Cải thiện animations và transitions
- [ ] Offline mode hoàn chỉnh
- [ ] Voice input/output
- [ ] Social features (favorites, collections, share)
- [ ] Gamification (achievements, quizzes)
- [ ] Analytics integration
