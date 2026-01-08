import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/feature/map/presentation/bloc/map_state.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Draggable bottom sheet với haptic feedback và responsive snap sizes
class MapBottomSheet extends StatefulWidget {
  final MapState state;
  final String dataForNext;
  final Widget Function(MapState) buildContent;
  final Widget Function(MapState) buildChips;
  final VoidCallback? onRetry;

  const MapBottomSheet({
    super.key,
    required this.state,
    required this.dataForNext,
    required this.buildContent,
    required this.buildChips,
    this.onRetry,
  });

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {
  late DraggableScrollableController _controller;
  double _lastSnapSize = 0.25;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
    _controller.addListener(_onSheetChanged);
  }

  void _onSheetChanged() {
    final currentSize = _controller.size;
    
    // Haptic feedback khi snap
    if ((currentSize - 0.25).abs() < 0.01 || (currentSize - 0.65).abs() < 0.01) {
      if ((currentSize - _lastSnapSize).abs() > 0.1) {
        HapticFeedback.mediumImpact();
        _lastSnapSize = currentSize;
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onSheetChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Tính toán responsive snap sizes dựa trên screen height
  List<double> _getResponsiveSnapSizes(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Với màn hình nhỏ (< 700px), dùng snap sizes nhỏ hơn
    if (screenHeight < 700) {
      return [0.3, 0.7];
    }
    // Với màn hình trung bình (700-900px)
    else if (screenHeight < 900) {
      return [0.25, 0.65];
    }
    // Với màn hình lớn (> 900px), dùng snap sizes lớn hơn
    else {
      return [0.2, 0.6];
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapSizes = _getResponsiveSnapSizes(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Tính toán min/max sizes responsive
    final minSize = screenHeight < 700 ? 0.25 : 0.18;
    final maxSize = screenHeight < 700 ? 0.75 : 0.65;
    final initialSize = snapSizes.first;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: snapSizes,
      builder: (context, scrollController) {
        return Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).canvasColor,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: [
              BoxShadow(
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, -2),
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Drag handle với visual feedback
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      widget.buildContent(widget.state),
                      const Gap(8),
                      (widget.state.loadState == LoadState.loading)
                          ? LoadingWidget(
                              message: AppLocalizations.of(context)
                                      ?.searchingInfoAbout(widget.dataForNext) ??
                                  "Searching for information about ${widget.dataForNext}...",
                              style: LoadingStyle.inline,
                            )
                          : const SizedBox.shrink(),
                      widget.buildChips(widget.state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
