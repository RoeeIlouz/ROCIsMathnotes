import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/notebook_model.dart';
import '../providers/notebooks_provider.dart';

class CreateNotebookDialog extends ConsumerStatefulWidget {
  final NotebookModel? notebook; // For editing existing notebook

  const CreateNotebookDialog({
    super.key,
    this.notebook,
  });

  @override
  ConsumerState<CreateNotebookDialog> createState() => _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends ConsumerState<CreateNotebookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Color _selectedColor = Colors.blue;
  String _selectedIcon = 'book';
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.notebook != null) {
      _nameController.text = widget.notebook!.name;
      _descriptionController.text = widget.notebook!.description ?? '';
      _selectedColor = widget.notebook!.colorValue;
      _selectedIcon = widget.notebook!.iconName ?? 'book';
      _isFavorite = widget.notebook!.isFavorite;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final textDirection = ref.watch(textDirectionProvider);
    final isEditing = widget.notebook != null;
    
    return Directionality(
      textDirection: textDirection,
      child: AlertDialog(
        title: Text(isEditing ? l10n.editNotebook : l10n.createNotebook),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.notebookName,
                      hintText: l10n.enterNotebookName,
                      prefixIcon: const Icon(Icons.book),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterNotebookName;
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      hintText: l10n.optionalDescription,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Icon selection
                  Text(
                    l10n.selectIcon,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _buildIconSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Color selection
                  Text(
                    l10n.selectColor,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _buildColorSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // Favorite toggle
                  CheckboxListTile(
                    title: Text(l10n.addToFavorites),
                    subtitle: Text(l10n.favoriteNotebookDescription),
                    value: _isFavorite,
                    onChanged: (value) {
                      setState(() {
                        _isFavorite = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _saveNotebook,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isEditing ? l10n.save : l10n.create),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    final icons = _getAvailableIcons();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: icons.map((iconData) {
        final iconName = iconData['name'] as String;
        final icon = iconData['icon'] as IconData;
        final isSelected = _selectedIcon == iconName;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIcon = iconName;
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected 
                  ? _selectedColor.withOpacity(0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected 
                    ? _selectedColor
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isSelected 
                  ? _selectedColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    final colors = NotebookModel.availableColors;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = _selectedColor.value == color.value;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).colorScheme.outline
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: color.computeLuminance() > 0.5 
                        ? Colors.black
                        : Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _getAvailableIcons() {
    return [
      {'name': 'book', 'icon': Icons.book},
      {'name': 'work', 'icon': Icons.work},
      {'name': 'school', 'icon': Icons.school},
      {'name': 'home', 'icon': Icons.home},
      {'name': 'science', 'icon': Icons.science},
      {'name': 'math', 'icon': MdiIcons.mathCompass},
      {'name': 'art', 'icon': Icons.palette},
      {'name': 'music', 'icon': Icons.music_note},
      {'name': 'sports', 'icon': Icons.sports},
      {'name': 'travel', 'icon': Icons.flight},
      {'name': 'food', 'icon': Icons.restaurant},
      {'name': 'health', 'icon': Icons.favorite},
      {'name': 'finance', 'icon': Icons.attach_money},
      {'name': 'code', 'icon': Icons.code},
      {'name': 'camera', 'icon': Icons.camera_alt},
      {'name': 'star', 'icon': Icons.star},
    ];
  }

  void _saveNotebook() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final notebooksNotifier = ref.read(notebooksProvider.notifier);
      String? notebookId;
      bool success = false;
      
      if (widget.notebook == null) {
        // Create new notebook
        notebookId = await notebooksNotifier.createNotebook(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          color: _selectedColor.value,
          iconName: _selectedIcon,
          isFavorite: _isFavorite,
        );
        success = notebookId != null;
      } else {
        // Update existing notebook
        final updatedNotebook = widget.notebook!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          color: _selectedColor.value,
          iconName: _selectedIcon,
          isFavorite: _isFavorite,
          updatedAt: DateTime.now(),
        );
        
        success = await notebooksNotifier.updateNotebook(updatedNotebook);
      }
      
      // Only proceed if the widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success && context.mounted) {
          final successL10n = AppLocalizations.of(context);
          // Use Future.delayed to ensure the state update is complete before showing the snackbar and popping
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(successL10n?.success ?? 'Success'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
              Navigator.of(context).pop(true);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving notebook: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}