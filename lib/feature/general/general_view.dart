import 'package:ai_map_explainer/core/common/style/border_radius_style.dart';
import 'package:ai_map_explainer/core/localization/locale_provider.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/theme/theme_provider.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/feature/detail/bloc/detail_bloc.dart';
import 'package:ai_map_explainer/feature/detail/bloc/detail_event.dart';
import 'package:ai_map_explainer/feature/detail/bloc/detail_state.dart';
import 'package:ai_map_explainer/feature/general/components/general_search_bar.dart';
import 'package:ai_map_explainer/feature/general/components/general_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class GeneralView extends StatelessWidget {
  const GeneralView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DetailViewContent();
  }
}

class _DetailViewContent extends StatefulWidget {
  const _DetailViewContent();

  @override
  State<_DetailViewContent> createState() => _DetailViewContentState();
}

class _DetailViewContentState extends State<_DetailViewContent> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: state.isLoading1
                ? LoadingWidget(
                    message:
                        AppLocalizations.of(context)?.loading ?? "Loading...",
                    style: LoadingStyle.centered,
                  )
                : Column(
                    children: [
                      // Header with title and toggles
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                state.query,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLanguageToggle(context),
                                const Gap(8),
                                _buildThemeToggle(context),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Search bar
                      GeneralSearchBar(
                        onSearchChanged: (query) {
                          setState(() {
                            _searchQuery = query.toLowerCase();
                          });
                        },
                      ),
                      // Related info with search filter
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          child: _buildRelatedInfo(context, _searchQuery),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRelatedInfo(BuildContext context, String searchQuery) {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        // Filter tags based on search query
        final filteredInfos = state.relatedInfos
            .where((info) =>
                info.isNotEmpty && info.toLowerCase().contains(searchQuery))
            .toList();

        // Show empty state if no results
        if (filteredInfos.isEmpty && !state.isLoading1) {
          return RefreshIndicator(
            onRefresh: () async {
              final l10n = AppLocalizations.of(context);
              context.read<DetailBloc>().add(
                    DetailEvent.initData(
                      l10n?.vietnameseHistory ?? "Vietnamese History",
                    ),
                  );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: GeneralEmptyState(
                onRefresh: searchQuery.isEmpty
                    ? () {
                        final l10n = AppLocalizations.of(context);
                        context.read<DetailBloc>().add(
                              DetailEvent.initData(
                                l10n?.vietnameseHistory ?? "Vietnamese History",
                              ),
                            );
                      }
                    : null,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final l10n = AppLocalizations.of(context);
            context.read<DetailBloc>().add(
                  DetailEvent.initData(
                    l10n?.vietnameseHistory ?? "Vietnamese History",
                  ),
                );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: filteredInfos
                    .map(
                      (info) => AnimatedOpacity(
                        key: ValueKey(info),
                        duration: const Duration(milliseconds: 200),
                        opacity: 1,
                        child: InkWell(
                          onTap: () => _goToDetail(info, context),
                          borderRadius: AppBorderRadius.styleSmall,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,
                              borderRadius: AppBorderRadius.styleSmall,
                              border: Border.all(
                                color: Colors.blueGrey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              info,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _goToDetail(String info, BuildContext context) {
    Routes.router.navigateTo(context, RoutePath.detail,
        routeSettings: RouteSettings(arguments: info));
  }

  Widget _buildThemeToggle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          tooltip: themeProvider.isDarkMode ? l10n.lightMode : l10n.darkMode,
          onPressed: () => themeProvider.toggleTheme(),
        );
      },
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          tooltip: 'Change language',
          onSelected: (String value) {
            if (value == 'vi') {
              localeProvider.setVietnamese();
            } else {
              localeProvider.setEnglish();
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'vi',
              child: Row(
                children: [
                  Text('🇻🇳 Tiếng Việt'),
                  if (localeProvider.isVietnamese) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check, size: 16),
                  ],
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  Text('🇬🇧 English'),
                  if (localeProvider.isEnglish) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check, size: 16),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
