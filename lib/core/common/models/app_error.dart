import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

/// Standardized error model cho ứng dụng
///
/// Lưu ý: Cần chạy `flutter pub run build_runner build --delete-conflicting-outputs`
/// để generate file `app_error.freezed.dart` trước khi sử dụng.
@freezed
sealed class AppError with _$AppError {
  const factory AppError.network({
    required String message,
    String? code,
  }) = NetworkError;

  const factory AppError.location({
    required String message,
    String? code,
  }) = LocationError;

  const factory AppError.api({
    required String message,
    String? code,
    int? statusCode,
  }) = ApiError;

  const factory AppError.cache({
    required String message,
  }) = CacheError;

  const factory AppError.unknown({
    required String message,
    Object? originalError,
  }) = UnknownError;
}

/// Extension để chuyển đổi AppError thành user-friendly message
extension AppErrorExtension on AppError {
  String get userMessage {
    return switch (this) {
      NetworkError() =>
        'Không thể kết nối đến internet. Vui lòng kiểm tra kết nối mạng của bạn.',
      LocationError() =>
        'Không thể lấy vị trí của bạn. Vui lòng kiểm tra quyền truy cập vị trí trong cài đặt.',
      ApiError(:final statusCode) => statusCode == 404
          ? 'Không tìm thấy thông tin. Vui lòng thử với từ khóa khác.'
          : statusCode == 401 || statusCode == 403
              ? 'Lỗi xác thực. Vui lòng thử lại sau.'
              : statusCode != null && statusCode >= 500
                  ? 'Lỗi máy chủ. Vui lòng thử lại sau.'
                  : 'Lỗi khi tải dữ liệu. Vui lòng thử lại sau.',
      CacheError() => 'Lỗi khi truy cập dữ liệu đã lưu. Vui lòng thử lại.',
      UnknownError() => 'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.',
    };
  }

  String get title {
    return switch (this) {
      NetworkError() => 'Lỗi kết nối',
      LocationError() => 'Lỗi vị trí',
      ApiError() => 'Lỗi dịch vụ',
      CacheError() => 'Lỗi lưu trữ',
      UnknownError() => 'Đã xảy ra lỗi',
    };
  }

  bool get canRetry {
    return switch (this) {
      NetworkError() => true,
      LocationError() => false, // Permission errors không nên retry
      ApiError(:final statusCode) => statusCode == null || statusCode >= 500,
      CacheError() => true,
      UnknownError() => true,
    };
  }
}
