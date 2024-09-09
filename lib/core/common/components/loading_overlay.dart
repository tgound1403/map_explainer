import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingOverlay {
  static OverlayEntry? _overlay;

  static void show(BuildContext context, {String? message}) {
    if (_overlay != null) return;

    _overlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 48,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballBeat,
                  colors: [Colors.white],
                ),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  static void hide() {
    _overlay?.remove();
    _overlay = null;
  }
}
