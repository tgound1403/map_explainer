import 'dart:async';
import 'dart:math';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Service để retry operations với exponential backoff
class RetryService {
  static final RetryService instance = RetryService._internal();
  RetryService._internal();

  /// Retry một operation với exponential backoff
  /// 
  /// [operation]: Function cần retry
  /// [maxRetries]: Số lần retry tối đa (default: 3)
  /// [initialDelay]: Delay ban đầu (default: 1 second)
  /// [maxDelay]: Delay tối đa (default: 30 seconds)
  /// [onRetry]: Callback được gọi mỗi lần retry
  Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    void Function(int attempt, Duration delay)? onRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        if (attempt >= maxRetries) {
          Logger.e('Retry failed after $maxRetries attempts: $e',
              stackTrace: stackTrace);
          rethrow;
        }

        attempt++;
        Logger.w('Retry attempt $attempt/$maxRetries after ${delay.inSeconds}s');

        // Call onRetry callback if provided
        onRetry?.call(attempt, delay);

        // Wait before retrying
        await Future.delayed(delay);

        // Exponential backoff: delay = initialDelay * 2^(attempt-1)
        // Capped at maxDelay
        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * 2),
            maxDelay.inMilliseconds,
          ),
        );
      }
    }

    // Should never reach here, but just in case
    throw Exception('Retry service: Unexpected error');
  }

  /// Retry với jitter (random delay) để tránh thundering herd
  Future<T> retryWithJitter<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    void Function(int attempt, Duration delay)? onRetry,
  }) async {
    final random = Random();
    int attempt = 0;
    Duration baseDelay = initialDelay;

    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        if (attempt >= maxRetries) {
          Logger.e('Retry with jitter failed after $maxRetries attempts: $e',
              stackTrace: stackTrace);
          rethrow;
        }

        attempt++;
        
        // Add jitter: random delay between 0.5x and 1.5x of base delay
        final jitter = baseDelay.inMilliseconds * 0.5 * (1 + random.nextDouble());
        final delay = Duration(milliseconds: jitter.toInt());
        
        Logger.w('Retry with jitter attempt $attempt/$maxRetries after ${delay.inSeconds}s');

        onRetry?.call(attempt, delay);

        await Future.delayed(delay);

        // Exponential backoff
        baseDelay = Duration(
          milliseconds: min(
            (baseDelay.inMilliseconds * 2),
            maxDelay.inMilliseconds,
          ),
        );
      }
    }

    throw Exception('Retry service: Unexpected error');
  }
}
