import 'package:flutter/material.dart';
import 'package:ai_map_explainer/feature/map/presentation/bloc/map_bloc.dart';
import 'package:ai_map_explainer/feature/map/presentation/bloc/map_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Horizontal list of chips để chọn topic
class MapChipsList extends StatelessWidget {
  final MapState state;
  final String selectedChip;
  final Function(String) onChipTap;

  const MapChipsList({
    super.key,
    required this.state,
    required this.selectedChip,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, String> information = {};
    if (state is CurrentLocationObtained) {
      information = (state as CurrentLocationObtained).information;
    } else if (state is PlaceSelected) {
      information = (state as PlaceSelected).information;
    }

    final infos = information.values
        .map((e) => context.read<MapBloc>().removeMapPrefix(e))
        .where((info) => info.isNotEmpty)
        .toList();

    if (infos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: infos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, idx) => _buildChip(context, infos[idx]),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String name) {
    return InkWell(
      onTap: () => onChipTap(name),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          final isSelected = selectedChip == name;
          return Chip(
            backgroundColor: Colors.blueGrey.shade100,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(36),
            ),
            side: BorderSide(
              width: isSelected ? 1 : 0,
              color: isSelected ? Colors.blueGrey : Colors.transparent,
            ),
            label: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
