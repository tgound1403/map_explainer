import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/retry/retry_service.dart';
import 'package:ai_map_explainer/core/widget/error_widget.dart';
import 'package:gap/gap.dart';

/// Error widget với retry functionality và exponential backoff
class RetryErrorWidget extends StatefulWidget {
  final String message;
  final String? title;
  final Future<void> Function() onRetry;
  final ErrorStyle style;
  final IconData? icon;
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;

  const RetryErrorWidget({
    super.key,
    required this.message,
    this.title,
    required this.onRetry,
    this.style = ErrorStyle.centered,
    this.icon,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
  });

  @override
  State<RetryErrorWidget> createState() => _RetryErrorWidgetState();
}

class _RetryErrorWidgetState extends State<RetryErrorWidget> {
  bool _isRetrying = false;
  String? _retryStatusMessage;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
      _retryStatusMessage = null;
    });

    try {
      await RetryService.instance.retry(
        operation: widget.onRetry,
        maxRetries: widget.maxRetries,
        initialDelay: widget.initialDelay,
        maxDelay: widget.maxDelay,
        onRetry: (attempt, delay) {
          if (mounted) {
            setState(() {
              _retryStatusMessage =
                  'Retrying... (Attempt $attempt/${widget.maxRetries})';
            });
          }
        },
      );

      // Success - widget will be rebuilt by parent
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _retryStatusMessage = null;
        });
      }
    } catch (e) {
      // Failed after all retries
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _retryStatusMessage = 'Failed after ${widget.maxRetries} attempts';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ErrorDisplayWidget(
          message: widget.message,
          title: widget.title,
          onRetry: _isRetrying ? null : _handleRetry,
          style: widget.style,
          icon: widget.icon,
        ),
        if (_isRetrying || _retryStatusMessage != null) ...[
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRetrying) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const Gap(8),
              ],
              if (_retryStatusMessage != null)
                Text(
                  _retryStatusMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
