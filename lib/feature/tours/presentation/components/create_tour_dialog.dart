import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_bloc.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_event.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Dialog để tạo tour mới
class CreateTourDialog extends StatefulWidget {
  final VoidCallback? onCreated;

  const CreateTourDialog({
    super.key,
    this.onCreated,
  });

  @override
  State<CreateTourDialog> createState() => _CreateTourDialogState();
}

class _CreateTourDialogState extends State<CreateTourDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#2196F3'; // Default blue
  String _selectedIcon = 'tour';
  String? _selectedTheme;
  final List<String> _selectedLocationIds = [];
  List<HistoricalLocation> _allLocations = [];
  bool _isLoadingLocations = true;

  final List<ColorOption> _colors = [
    ColorOption('#2196F3', 'Blue'),
    ColorOption('#4CAF50', 'Green'),
    ColorOption('#FF9800', 'Orange'),
    ColorOption('#F44336', 'Red'),
    ColorOption('#9C27B0', 'Purple'),
    ColorOption('#00BCD4', 'Cyan'),
    ColorOption('#E53935', 'Red Dark'),
  ];

  final List<IconOption> _icons = [
    IconOption('tour', Icons.tour),
    IconOption('flag', Icons.flag),
    IconOption('museum', Icons.museum),
    IconOption('location_city', Icons.location_city),
    IconOption('history', Icons.history),
    IconOption('explore', Icons.explore),
  ];

  final List<String> _themes = [
    'Kháng chiến',
    'Văn hóa',
    'Kiến trúc',
    'Địa phương',
    'Tôn giáo',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoadingLocations = true;
    });

    try {
      final locations = await HistoricalLocationService.instance.loadHistoricalLocations();
      setState(() {
        _allLocations = locations;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocations = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTour() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocationIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ít nhất một địa điểm')),
        );
        return;
      }

      context.read<ToursBloc>().add(
            CreateTour(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              locationIds: _selectedLocationIds,
              theme: _selectedTheme,
              color: _selectedColor,
              icon: _selectedIcon,
            ),
          );
      widget.onCreated?.call();
      Navigator.of(context).pop();
    }
  }

  void _toggleLocation(String locationId) {
    setState(() {
      if (_selectedLocationIds.contains(locationId)) {
        _selectedLocationIds.remove(locationId);
      } else {
        _selectedLocationIds.add(locationId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Tour', // TODO: Add to l10n
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            // Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tour Name', // TODO: Add to l10n
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required'; // TODO: Add to l10n
                          }
                          return null;
                        },
                        autofocus: true,
                      ),
                      const Gap(16),
                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n?.description ?? 'Description',
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const Gap(16),
                      // Theme selector
                      Text(
                        'Theme', // TODO: Add to l10n
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Gap(8),
                      Wrap(
                        spacing: 8,
                        children: _themes.map((theme) {
                          final isSelected = _selectedTheme == theme;
                          return FilterChip(
                            label: Text(theme),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTheme = selected ? theme : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const Gap(16),
                      // Color selector
                      Text(
                        l10n?.color ?? 'Color',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Gap(8),
                      Wrap(
                        spacing: 8,
                        children: _colors.map((colorOption) {
                          final isSelected = _selectedColor == colorOption.value;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = colorOption.value;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(int.parse(colorOption.value.replaceAll('#', '0xFF'))),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const Gap(16),
                      // Icon selector
                      Text(
                        l10n?.icon ?? 'Icon',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Gap(8),
                      Wrap(
                        spacing: 8,
                        children: _icons.map((iconOption) {
                          final isSelected = _selectedIcon == iconOption.value;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIcon = iconOption.value;
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(int.parse(_selectedColor.replaceAll('#', '0xFF')))
                                        .withOpacity(0.1)
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Color(int.parse(_selectedColor.replaceAll('#', '0xFF')))
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                iconOption.icon,
                                color: isSelected
                                    ? Color(int.parse(_selectedColor.replaceAll('#', '0xFF')))
                                    : Colors.grey.shade600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Gap(16),
                      // Location selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Locations (${_selectedLocationIds.length})', // TODO: Add to l10n
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (_selectedLocationIds.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLocationIds.clear();
                                });
                              },
                              child: const Text('Clear'), // TODO: Add to l10n
                            ),
                        ],
                      ),
                      const Gap(8),
                      // Location list
                      if (_isLoadingLocations)
                        const Center(child: CircularProgressIndicator())
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _allLocations.length,
                            itemBuilder: (context, index) {
                              final location = _allLocations[index];
                              final isSelected = _selectedLocationIds.contains(location.id);
                              return CheckboxListTile(
                                title: Text(location.name),
                                subtitle: Text(location.period),
                                value: isSelected,
                                onChanged: (value) => _toggleLocation(location.id),
                                dense: true,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n?.cancel ?? 'Cancel'),
                ),
                const Gap(8),
                ElevatedButton(
                  onPressed: _createTour,
                  child: Text(l10n?.create ?? 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class cho color options
class ColorOption {
  final String value;
  final String label;

  ColorOption(this.value, this.label);
}

/// Helper class cho icon options
class IconOption {
  final String value;
  final IconData icon;

  IconOption(this.value, this.icon);
}
