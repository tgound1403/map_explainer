import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget để detect swipe gestures ở cạnh phải màn hình để zoom map
///
/// Cách sử dụng:
/// - Vuốt lên/xuống ở cạnh phải màn hình để zoom
/// - Swipe down = zoom in
/// - Swipe up = zoom out
class EdgeZoomGestureDetector extends StatefulWidget {
  final Widget child;
  final GoogleMapController? mapController;
  final double edgeWidth; // Độ rộng vùng cạnh để detect gesture (default: 50px)
  final double zoomStep; // Bước zoom mỗi lần swipe (default: 0.5)
  final Duration animationDuration; // Thời gian animation zoom
  final ValueChanged<double>? onZoomChanged; // Callback khi zoom thay đổi

  const EdgeZoomGestureDetector({
    super.key,
    required this.child,
    this.mapController,
    this.edgeWidth = 50.0,
    this.zoomStep = 0.5,
    this.animationDuration = const Duration(milliseconds: 200),
    this.onZoomChanged,
  });

  @override
  State<EdgeZoomGestureDetector> createState() =>
      _EdgeZoomGestureDetectorState();
}

class _EdgeZoomGestureDetectorState extends State<EdgeZoomGestureDetector> {
  double _currentZoom = 10.0;
  bool _isZooming = false;
  Offset? _startPosition;
  DateTime? _lastZoomTime;
  static const Duration _minZoomInterval =
      Duration(milliseconds: 250); // Tăng interval để giảm lag

  @override
  void initState() {
    super.initState();
    _updateCurrentZoom();
  }

  @override
  void didUpdateWidget(EdgeZoomGestureDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapController != widget.mapController) {
      _updateCurrentZoom();
    }
  }

  Future<void> _updateCurrentZoom() async {
    if (widget.mapController != null) {
      try {
        final zoom = await widget.mapController!.getZoomLevel();
        if (mounted) {
          setState(() {
            _currentZoom = zoom;
          });
        }
      } catch (e) {
        // Ignore errors
      }
    }
  }

  void _performZoom(bool zoomIn) {
    if (widget.mapController == null) return;

    final now = DateTime.now();
    if (_lastZoomTime != null &&
        now.difference(_lastZoomTime!) < _minZoomInterval) {
      return; // Throttle zoom để tránh zoom quá nhanh
    }

    _lastZoomTime = now;

    final newZoom = zoomIn
        ? _currentZoom + widget.zoomStep
        : _currentZoom - widget.zoomStep;

    // Giới hạn zoom level (thường là 2-20)
    final clampedZoom = newZoom.clamp(2.0, 20.0);

    if (clampedZoom == _currentZoom) return;

    // Update state trước để UI responsive hơn
    setState(() {
      _currentZoom = clampedZoom;
      _isZooming = true;
    });

    // Notify zoom change
    widget.onZoomChanged?.call(clampedZoom);

    // Perform zoom async (không await để không block UI)
    widget.mapController!
        .animateCamera(
      CameraUpdate.zoomTo(clampedZoom),
    )
        .catchError((e) {
      // Ignore errors, nhưng revert zoom nếu fail
      if (mounted) {
        _updateCurrentZoom();
      }
    });

    // Reset zoom indicator sau animation
    Future.delayed(widget.animationDuration, () {
      if (mounted) {
        setState(() {
          _isZooming = false;
        });
      }
    });
  }

  void _onPanUpdate(Offset currentPosition) {
    if (_startPosition == null) return;

    final delta = currentPosition - _startPosition!;
    final threshold = 50.0; // Tăng threshold để tránh zoom nhạy cảm

    // Chỉ xử lý nếu vuốt theo chiều dọc (lên/xuống)
    // Vì overlay đã ở cạnh phải rồi, nên không cần check lại
    if (delta.dy.abs() > threshold &&
        delta.dy.abs() > delta.dx.abs() * 1.5) {
      // Swipe down = zoom in, swipe up = zoom out
      final zoomIn = delta.dy > 0;
      _performZoom(zoomIn);
      _startPosition = currentPosition; // Reset để tiếp tục detect
    }
  }

  @override
  Widget build(BuildContext context) {
    final edgeWidth = widget.edgeWidth;

    return Stack(
      children: [
        widget.child,
        // Overlay chỉ ở cạnh phải để detect gestures, không chặn các vùng khác
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, // Intercept gestures ở vùng này
            onPanStart: (details) {
              // Vì overlay đã ở cạnh phải rồi, nên mọi gesture trong overlay đều ở cạnh phải
              _startPosition = details.localPosition;
            },
            onPanUpdate: (details) {
              if (_startPosition == null) return;
              // Xử lý gesture với local position (chỉ cần delta, không cần global)
              _onPanUpdate(details.localPosition);
            },
            onPanEnd: (_) {
              _startPosition = null;
            },
            onPanCancel: () {
              _startPosition = null;
            },
            // Transparent container để detect gestures
            child: Container(color: Colors.transparent),
          ),
        ),
        // Zoom indicator
        if (_isZooming)
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 40,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentZoom > 10 ? Icons.zoom_in : Icons.zoom_out,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentZoom.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
