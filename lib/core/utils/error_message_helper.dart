/// Helper để chuyển đổi technical errors thành user-friendly messages
class ErrorMessageHelper {
  /// Chuyển đổi error thành message thân thiện với user
  static String getUserFriendlyMessage(dynamic error, [StackTrace? stackTrace]) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Không thể kết nối đến internet. Vui lòng kiểm tra kết nối mạng của bạn.';
    }

    if (errorString.contains('timeout')) {
      return 'Yêu cầu mất quá nhiều thời gian. Vui lòng thử lại sau.';
    }

    // Location errors
    if (errorString.contains('location') ||
        errorString.contains('permission') ||
        errorString.contains('geolocator')) {
      return 'Không thể lấy vị trí của bạn. Vui lòng kiểm tra quyền truy cập vị trí trong cài đặt.';
    }

    // API errors
    if (errorString.contains('api') ||
        errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Lỗi xác thực. Vui lòng thử lại sau.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Không tìm thấy thông tin. Vui lòng thử với từ khóa khác.';
    }

    if (errorString.contains('500') ||
        errorString.contains('server') ||
        errorString.contains('internal')) {
      return 'Lỗi máy chủ. Vui lòng thử lại sau.';
    }

    // AI/API specific errors
    if (errorString.contains('gemini') ||
        errorString.contains('generative') ||
        errorString.contains('ai')) {
      return 'Không thể tạo phản hồi từ AI. Vui lòng thử lại sau.';
    }

    if (errorString.contains('wikipedia')) {
      return 'Không thể tải thông tin từ Wikipedia. Vui lòng thử lại sau.';
    }

    // Cache errors
    if (errorString.contains('cache') || errorString.contains('hive')) {
      return 'Lỗi khi truy cập dữ liệu đã lưu. Vui lòng thử lại.';
    }

    // Generic errors
    if (errorString.contains('exception') || errorString.contains('error')) {
      return 'Đã xảy ra lỗi. Vui lòng thử lại sau.';
    }

    // Default: return original error if it's short enough, otherwise generic message
    final originalError = error.toString();
    if (originalError.length < 100) {
      return originalError;
    }

    return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.';
  }

  /// Lấy title phù hợp cho error
  static String getErrorTitle(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Lỗi kết nối';
    }

    if (errorString.contains('location') || errorString.contains('permission')) {
      return 'Lỗi vị trí';
    }

    if (errorString.contains('timeout')) {
      return 'Hết thời gian chờ';
    }

    if (errorString.contains('api') || errorString.contains('server')) {
      return 'Lỗi dịch vụ';
    }

    return 'Đã xảy ra lỗi';
  }

  /// Kiểm tra xem có nên hiển thị retry button không
  static bool shouldShowRetry(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Không hiển thị retry cho permission errors
    if (errorString.contains('permission') && errorString.contains('denied')) {
      return false;
    }

    // Hiển thị retry cho network, timeout, server errors
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('server') ||
        errorString.contains('api');
  }
}
