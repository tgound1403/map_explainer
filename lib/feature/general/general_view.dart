import 'package:ai_map_explainer/core/common/style/border_radius_style.dart';
import 'package:ai_map_explainer/core/localization/locale_provider.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/theme/theme_provider.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/feature/detail/bloc/detail_bloc.dart';
import 'package:ai_map_explainer/feature/detail/bloc/detail_event.dart';
import 'package:ai_map_explainer/feature/detail/bloc/detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class GeneralView extends StatelessWidget {
  const GeneralView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DetailViewContent();
  }
}

class _DetailViewContent extends StatelessWidget {
  const _DetailViewContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: state.isLoading1
                ? LoadingWidget(
                    message: AppLocalizations.of(context)?.loading ?? "Loading...",
                    style: LoadingStyle.centered,
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0).copyWith(bottom: 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  state.query,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500, fontSize: 24),
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
                          const Gap(16),
                          _buildRelatedInfo(context),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRelatedInfo(BuildContext context) {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: () async {
              final l10n = AppLocalizations.of(context);
              context
                  .read<DetailBloc>()
                  .add(DetailEvent.initData(l10n?.vietnameseHistory ?? "Vietnamese History"));
            },
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: state.relatedInfos
                  .where((info) => info.isNotEmpty)
                  .map((info) => InkWell(
                        onTap: () => _goToDetail(info, context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,
                              borderRadius: AppBorderRadius.styleSmall),
                          child: Text(info),
                        ),
                      ))
                  .toList(),
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
    final l10n = AppLocalizations.of(context)!;
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
