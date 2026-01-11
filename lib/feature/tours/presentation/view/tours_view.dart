import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/core/theme/modern_design_system.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_bloc.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_event.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_state.dart';
import 'package:ai_map_explainer/feature/tours/presentation/components/tour_card.dart';
import 'package:ai_map_explainer/feature/tours/presentation/components/create_tour_dialog.dart';
import 'package:ai_map_explainer/core/router/router.dart';

/// View để quản lý tours
class ToursView extends StatefulWidget {
  const ToursView({super.key});

  @override
  State<ToursView> createState() => _ToursViewState();
}

class _ToursViewState extends State<ToursView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPremadeOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load tours khi mở view - đảm bảo context đã có provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ToursBloc>().add(LoadTours());
      }
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _showPremadeOnly = _tabController.index == 0;
      });
      context.read<ToursBloc>().add(LoadTours(premadeOnly: _showPremadeOnly));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateTourDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateTourDialog(
        onCreated: () {
          // Tours sẽ tự reload sau khi tạo
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Tours', // TODO: Add to l10n
          style: ModernDesignSystem.modernTitle(context).copyWith(
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ModernDesignSystem.accent,
                width: 2,
              ),
            ),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: isDark ? Colors.white : Colors.grey.shade800,
          unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Premade'), // TODO: Add to l10n
            Tab(text: 'My Tours'), // TODO: Add to l10n
          ],
        ),
        actions: [
          if (_tabController.index == 1)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ModernDesignSystem.success.withOpacity(0.1),
                border: Border.all(
                  color: ModernDesignSystem.success.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: ModernDesignSystem.success,
                ),
                tooltip: 'Create tour', // TODO: Add to l10n
                onPressed: _showCreateTourDialog,
              ),
            ),
        ],
      ),
      body: BlocBuilder<ToursBloc, ToursState>(
        builder: (context, state) {
          if (state is ToursLoading) {
            return const LoadingWidget(
              message: 'Loading tours...',
              style: LoadingStyle.centered,
            );
          }

          if (state is ToursError) {
            return EnhancedEmptyState.networkError(
              onRetry: () {
                context.read<ToursBloc>().add(LoadTours(premadeOnly: _showPremadeOnly));
              },
            );
          }

          if (state is ToursLoaded) {
            if (state.tours.isEmpty) {
              return EnhancedEmptyState.noData(
                title: 'No tours yet', // TODO: Add to l10n
                message: _showPremadeOnly
                    ? 'No premade tours available.' // TODO: Add to l10n
                    : 'Create your first tour to explore historical locations.', // TODO: Add to l10n
                onRefresh: () {
                  context.read<ToursBloc>().add(LoadTours(premadeOnly: _showPremadeOnly));
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ToursBloc>().add(LoadTours(premadeOnly: _showPremadeOnly));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(ModernDesignSystem.spacingM),
                itemCount: state.tours.length,
                itemBuilder: (context, index) {
                  final tour = state.tours[index];
                  return TourCard(
                    tour: tour,
                    onTap: () {
                      Routes.router.navigateTo(
                        context,
                        '/tour/${tour.id}',
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
