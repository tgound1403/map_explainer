import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_bloc.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_event.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Dialog để tạo collection mới
class CreateCollectionDialog extends StatefulWidget {
  final VoidCallback? onCreated;

  const CreateCollectionDialog({
    super.key,
    this.onCreated,
  });

  @override
  State<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#2196F3'; // Default blue
  String _selectedIcon = 'folder';

  final List<ColorOption> _colors = [
    ColorOption('#2196F3', 'Blue'),
    ColorOption('#4CAF50', 'Green'),
    ColorOption('#FF9800', 'Orange'),
    ColorOption('#F44336', 'Red'),
    ColorOption('#9C27B0', 'Purple'),
    ColorOption('#00BCD4', 'Cyan'),
  ];

  final List<IconOption> _icons = [
    IconOption('folder', Icons.folder),
    IconOption('star', Icons.star),
    IconOption('bookmark', Icons.bookmark),
    IconOption('favorite', Icons.favorite),
    IconOption('location', Icons.location_on),
    IconOption('history', Icons.history),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createCollection() {
    if (_formKey.currentState!.validate()) {
      context.read<CollectionsBloc>().add(
            CollectionsEvent.createCollection(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              color: _selectedColor,
              icon: _selectedIcon,
            ),
          );
      widget.onCreated?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.createCollection ?? 'Create Collection'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n?.collectionName ?? 'Collection Name',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n?.collectionNameRequired ?? 'Name is required';
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
                  labelText: 'Description (optional)',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const Gap(16),
              // Color selection
              Text(
                l10n?.color ?? 'Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Gap(8),
              Wrap(
                spacing: 8,
                children: _colors.map((colorOption) {
                  final isSelected = _selectedColor == colorOption.color;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorOption.color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                              colorOption.color.replaceFirst('#', '0xFF')),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const Gap(16),
              // Icon selection
              Text(
                l10n?.icon ?? 'Icon',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Gap(8),
              Wrap(
                spacing: 8,
                children: _icons.map((iconOption) {
                  final isSelected = _selectedIcon == iconOption.name;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconOption.name;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        iconOption.icon,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _createCollection,
          child: Text(l10n?.create ?? 'Create'),
        ),
      ],
    );
  }
}

class ColorOption {
  final String color;
  final String name;

  ColorOption(this.color, this.name);
}

class IconOption {
  final String name;
  final IconData icon;

  IconOption(this.name, this.icon);
}
