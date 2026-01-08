# Changelog

## [Unreleased]

### Added
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
