import 'package:ai_map_explainer/core/common/style/border_radius_style.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/feature/detail/bloc/detail_bloc.dart';
import 'package:ai_map_explainer/feature/detail/bloc/detail_event.dart';
import 'package:ai_map_explainer/feature/detail/bloc/detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';

class GeneralView extends StatelessWidget {
  const GeneralView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DetailBloc()..add(const DetailEvent.initData("Lịch sử Việt Nam")),
      child: const _DetailViewContent(),
    );
  }
}

class _DetailViewContent extends StatelessWidget {
  const _DetailViewContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              state.query,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          body: state.isLoading1
              ? const Center(
                child: SizedBox(
                  height: 100,
                  child: LoadingIndicator(
                      indicatorType: Indicator.ballPulseSync,
                      colors: [Colors.blue, Colors.green, Colors.red],
                    ),
                ),
              )
              : _buildRelatedInfo(context),
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
              context.read<DetailBloc>().add(const DetailEvent.initData("Lịch sử Việt Nam"));
            },
            child: SingleChildScrollView(
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
          ),
        );
      },
    );
  }

  void _goToDetail(String info, BuildContext context) {
    Routes.router.navigateTo(context, RoutePath.detail,
        routeSettings: RouteSettings(arguments: info));
  }
}
