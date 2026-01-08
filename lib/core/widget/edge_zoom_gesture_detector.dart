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
  State<EdgeZoomGestureDetector> createState() => _EdgeZoomGestureDetectorState();
}

class _EdgeZoomGestureDetectorState extends State<EdgeZoomGestureDetector> {
  double _currentZoom = 10.0;
  bool _isZooming = false;
  Offset? _startPosition;
  DateTime? _lastZoomTime;
  static const Duration _minZoomInterval = Duration(milliseconds: 150);

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

  Future<void> _performZoom(bool zoomIn) async {
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
    
    try {
      await widget.mapController!.animateCamera(
        CameraUpdate.zoomTo(clampedZoom),
      );
      
      setState(() {
        _currentZoom = clampedZoom;
        _isZooming = true;
      });
      
      // Notify zoom change
      widget.onZoomChanged?.call(clampedZoom);
      
      // Reset zoom indicator sau animation
      Future.delayed(widget.animationDuration, () {
        if (mounted) {
          setState(() {
            _isZooming = false;
          });
        }
      });
    } catch (e) {
      // Ignore errors
    }
  }

  void _onPanStart(DragStartDetails details, Size screenSize) {
    if (_isInEdgeZone(details.localPosition, screenSize) ||
        _isInVerticalEdgeZone(details.localPosition, screenSize)) {
      _startPosition = details.localPosition;
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size screenSize) {
    if (_startPosition == null) return;
    
    // Check if still in edge zone
    if (!_isInEdgeZone(details.localPosition, screenSize) &&
        !_isInVerticalEdgeZone(details.localPosition, screenSize)) {
      _startPosition = null; // Reset nếu ra khỏi edge zone
      return;
    }
    
    final delta = details.localPosition - _startPosition!;
    final threshold = 30.0; // Minimum distance để trigger zoom
    
    final isInHorizontalEdge = _isInEdgeZone(_startPosition!, screenSize);
    final isInVerticalEdge = _isInVerticalEdgeZone(_startPosition!, screenSize);
    
    // Nếu ở cạnh dọc (trái/phải), detect vertical swipe
    if (isInHorizontalEdge && 
        delta.dy.abs() > threshold && 
        delta.dy.abs() > delta.dx.abs() * 1.5) {
      // Swipe down = zoom in, swipe up = zoom out
      final zoomIn = delta.dy > 0;
      _performZoom(zoomIn);
      _startPosition = details.localPosition; // Reset để tiếp tục detect
    }
    // Nếu ở cạnh ngang (trên/dưới), detect horizontal swipe
    else if (isInVerticalEdge &&
             delta.dx.abs() > threshold && 
             delta.dx.abs() > delta.dy.abs() * 1.5) {
      // Swipe right = zoom in, swipe left = zoom out
      final zoomIn = delta.dx > 0;
      _performZoom(zoomIn);
      _startPosition = details.localPosition;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _startPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final screenSize = MediaQuery.of(context).size;
        _onPanStart(details, screenSize);
      },
      onPanUpdate: (details) {
        final screenSize = MediaQuery.of(context).size;
        _onPanUpdate(details, screenSize);
      },
      onPanEnd: _onPanEnd,
      child: Stack(
        children: [
          widget.child,
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
      ),
    );
  }
}
