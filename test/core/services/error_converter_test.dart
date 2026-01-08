import 'package:flutter_test/flutter_test.dart';
import 'package:ai_map_explainer/core/utils/error_converter.dart';
import 'package:ai_map_explainer/core/common/models/app_error.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group('ErrorConverter', () {
    test('should convert network errors correctly', () {
      final exception = Exception('SocketException: Failed host lookup');
      final error = ErrorConverter.fromException(exception);

      expect(error, isA<NetworkError>());
      expect(error.message, contains('SocketException'));
    });

    test('should convert timeout errors correctly', () {
      final exception = Exception('TimeoutException: Connection timeout');
      final error = ErrorConverter.fromException(exception);

      expect(error, isA<NetworkError>());
      final networkError = error as NetworkError;
      expect(networkError.code, 'TIMEOUT');
    });

    test('should convert location permission errors correctly', () {
      final exception = PermissionDeniedException('Location permission denied');
      final error = ErrorConverter.fromException(exception);

      expect(error, isA<LocationError>());
      final locationError = error as LocationError;
      expect(locationError.code, 'PERMISSION_DENIED');
    });

    test('should convert location service disabled errors correctly', () {
      final exception = LocationServiceDisabledException();
      final error = ErrorConverter.fromException(exception);

      expect(error, isA<LocationError>());
      final locationError = error as LocationError;
      expect(locationError.code, 'LOCATION_DISABLED');
    });

    test('should convert 404 API errors correctly', () {
      final exception = Exception('404 Not Found');
      final error = ErrorConverter.fromException(exception);

      expect(error, isA<ApiError>());
      final apiError = error as ApiError;
      expect(apiError.statusCode, 404);
      expect(apiError.code, 'NOT_FOUND');
    });

    test('should convert 401 API errors correctly', () {
      final exception = Exception('401 Unauthorized');
      final error = ErrorConverter.fromException(exception);

      expect(error, isA<ApiError>());
      final apiError = error as ApiError;
      expect(apiError.statusCode, 401);
      expect(apiError.code, 'UNAUTHORIZED');
    });

    test('should convert 500 server errors correctly', () {
      final exception = Exception('500 Internal Server Error');
      final error = ErrorConverter.fromException(exception);

      expect(error, isA<ApiError>());
      final apiError = error as ApiError;
      expect(apiError.statusCode, 500);
      expect(apiError.code, 'SERVER_ERROR');
    });

    test('should convert cache errors correctly', () {
      final exception = Exception('HiveError: Box not found');
      final error = ErrorConverter.fromException(exception);

      expect(error, isA<CacheError>());
    });

    test('should convert unknown errors correctly', () {
      final exception = Exception('Some random error');
      final error = ErrorConverter.fromException(exception);

      expect(error, isA<UnknownError>());
      final unknownError = error as UnknownError;
      expect(unknownError.originalError, exception);
    });
  });
}
