import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget để detect swipe gestures ở cạnh màn hình để zoom map
///
/// Cách sử dụng:
/// - Vuốt lên/xuống ở cạnh trái/phải màn hình để zoom
/// - Vuốt trái/phải ở cạnh trên/dưới màn hình để zoom
/// - Swipe down/right = zoom in
/// - Swipe up/left = zoom out
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

  bool _isInEdgeZone(Offset position, Size screenSize) {
    final edgeWidth = widget.edgeWidth;

    // Check left edge
    if (position.dx < edgeWidth) return true;

    // Check right edge
    if (position.dx > screenSize.width - edgeWidth) return true;

    return false;
  }

  bool _isInVerticalEdgeZone(Offset position, Size screenSize) {
    final edgeWidth = widget.edgeWidth;

    // Check top edge
    if (position.dy < edgeWidth) return true;

    // Check bottom edge
    if (position.dy > screenSize.height - edgeWidth) return true;

    return false;
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

  void _onPanUpdate(Offset currentPosition, Size screenSize) {
    if (_startPosition == null) return;

    final delta = currentPosition - _startPosition!;
    final threshold = 50.0; // Tăng threshold để tránh zoom nhạy cảm

    final isInHorizontalEdge = _isInEdgeZone(_startPosition!, screenSize);
    final isInVerticalEdge = _isInVerticalEdgeZone(_startPosition!, screenSize);

    // Nếu ở cạnh dọc (trái/phải), detect vertical swipe
    if (isInHorizontalEdge &&
        delta.dy.abs() > threshold &&
        delta.dy.abs() > delta.dx.abs() * 1.5) {
      // Swipe down = zoom in, swipe up = zoom out
      final zoomIn = delta.dy > 0;
      _performZoom(zoomIn);
      _startPosition = currentPosition; // Reset để tiếp tục detect
    }
    // Nếu ở cạnh ngang (trên/dưới), detect horizontal swipe
    else if (isInVerticalEdge &&
        delta.dx.abs() > threshold &&
        delta.dx.abs() > delta.dy.abs() * 1.5) {
      // Swipe right = zoom in, swipe left = zoom out
      final zoomIn = delta.dx > 0;
      _performZoom(zoomIn);
      _startPosition = currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Overlay chỉ ở edge zones để detect gestures
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              final screenSize = MediaQuery.of(context).size;
              // Chỉ capture nếu ở edge zone
              if (_isInEdgeZone(details.localPosition, screenSize) ||
                  _isInVerticalEdgeZone(details.localPosition, screenSize)) {
                _startPosition = details.localPosition;
              }
            },
            onPanUpdate: (details) {
              if (_startPosition == null) return;

              final screenSize = MediaQuery.of(context).size;
              // Chỉ xử lý nếu vẫn ở trong edge zone
              if (_isInEdgeZone(details.localPosition, screenSize) ||
                  _isInVerticalEdgeZone(details.localPosition, screenSize)) {
                _onPanUpdate(details.localPosition, screenSize);
              } else {
                // Nếu ra khỏi edge zone, reset ngay để không block gestures
                _startPosition = null;
              }
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
