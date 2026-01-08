import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:gap/gap.dart';

/// Reusable loading widget với nhiều styles
class LoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingStyle style;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.style = LoadingStyle.centered,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.colorScheme.primary;

    switch (style) {
      case LoadingStyle.centered:
        return _buildCentered(loadingColor);
      case LoadingStyle.inline:
        return _buildInline(loadingColor);
      case LoadingStyle.minimal:
        return _buildMinimal(loadingColor);
      case LoadingStyle.fullScreen:
        return _buildFullScreen(context, loadingColor);
    }
  }

  Widget _buildCentered(Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: LoadingIndicator(
              indicatorType: Indicator.ballPulseSync,
              colors: [color],
            ),
          ),
          if (message != null) ...[
            const Gap(16),
            Text(
              message!,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInline(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: LoadingIndicator(
            indicatorType: Indicator.ballBeat,
            colors: [color],
          ),
        ),
        if (message != null) ...[
          const Gap(12),
          Text(
            message!,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildMinimal(Color color) {
    return SizedBox(
      width: 24,
      height: 24,
      child: LoadingIndicator(
        indicatorType: Indicator.ballBeat,
        colors: [color],
      ),
    );
  }

  Widget _buildFullScreen(BuildContext context, Color color) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: LoadingIndicator(
                indicatorType: Indicator.ballPulseSync,
                colors: [color],
              ),
            ),
            if (message != null) ...[
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum LoadingStyle {
  centered,
  inline,
  minimal,
  fullScreen,
}
