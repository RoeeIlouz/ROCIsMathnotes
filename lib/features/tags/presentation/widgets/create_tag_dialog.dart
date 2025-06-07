import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/tag_model.dart';
import '../providers/tags_provider.dart';

class CreateTagDialog extends ConsumerStatefulWidget {
  final TagModel? tag; // For editing existing tag

  const CreateTagDialog({
    super.key,
    this.tag,
  });

  @override
  ConsumerState<CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends ConsumerState<CreateTagDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.tag != null) {
      _nameController.text = widget.tag!.name;
      _selectedColor = widget.tag!.colorValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = ref.watch(textDirectionProvider);
    final isEditing = widget.tag != null;
    
    return Directionality(
      textDirection: textDirection,
      child: AlertDialog(
        title: Text(isEditing ? l10n.editTag : l10n.createTag),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
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
                    labelText: l10n.tagName,
                    hintText: l10n.enterTagName,
                    prefixIcon: const Icon(Icons.label),
                    errorText: _errorMessage,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterTagName;
                    }
                    if (!TagModel.isValidTagName(value)) {
                      return l10n.invalidTagName;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveTag(),
                ),
                
                const SizedBox(height: 24),
                
                // Color selection
                Text(
                  l10n.selectColor,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                _buildColorSelector(),
                
                const SizedBox(height: 16),
                
                // Common tags suggestions (only for new tags)
                if (!isEditing) ...[
                  Text(
                    l10n.commonTags,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _buildCommonTagsSuggestions(),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _saveTag,
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

  Widget _buildColorSelector() {
    final colors = TagModel.availableColors;
    
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

  Widget _buildCommonTagsSuggestions() {
    final commonTags = TagModel.commonTags;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: commonTags.map((tagName) {
        return ActionChip(
          label: Text(
            tagName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            _nameController.text = tagName;
            setState(() {
              _errorMessage = null;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  void _saveTag() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final l10n = AppLocalizations.of(context)!;
      final tagsNotifier = ref.read(tagsProvider.notifier);
      final tagName = TagModel.sanitizeTagName(_nameController.text);
      
      // Check if tag name already exists (for new tags)
      if (widget.tag == null) {
        final existingTagsAsync = ref.read(tagsProvider);
        final tagExists = existingTagsAsync.when(
          data: (tags) => tags.any(
            (tag) => tag.name.toLowerCase() == tagName.toLowerCase(),
          ),
          loading: () => false,
          error: (_, __) => false,
        );
        
        if (tagExists) {
          setState(() {
            _errorMessage = l10n.tagAlreadyExists;
            _isLoading = false;
          });
          return;
        }
      }
      
      if (widget.tag == null) {
        // Create new tag
        final tagId = await tagsNotifier.createTag(
          name: tagName,
          color: _selectedColor.value,
        );
        
        if (tagId != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.success),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        // Update existing tag
        final updatedTag = widget.tag!.copyWith(
          name: tagName,
          color: _selectedColor.value,
        );
        
        final success = await tagsNotifier.updateTag(updatedTag);
        
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.success),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving tag: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Quick tag creation widget for use in note editor
class QuickTagCreator extends ConsumerStatefulWidget {
  final ValueChanged<TagModel> onTagCreated;
  final List<String> existingTagNames;

  const QuickTagCreator({
    super.key,
    required this.onTagCreated,
    this.existingTagNames = const [],
  });

  @override
  ConsumerState<QuickTagCreator> createState() => _QuickTagCreatorState();
}

class _QuickTagCreatorState extends ConsumerState<QuickTagCreator> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isCreating = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = ref.watch(textDirectionProvider);
    
    return Directionality(
      textDirection: textDirection,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createNewTag,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: l10n.enterTagName,
                      prefixIcon: const Icon(Icons.label),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _createTag(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isCreating ? null : _createTag,
                  child: _isCreating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.create),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createTag() async {
    final tagName = _controller.text.trim();
    if (tagName.isEmpty || !TagModel.isValidTagName(tagName)) return;
    
    final sanitizedName = TagModel.sanitizeTagName(tagName);
    if (widget.existingTagNames.contains(sanitizedName.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.tagAlreadyExists),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    setState(() {
      _isCreating = true;
    });
    
    try {
      final tagsNotifier = ref.read(tagsProvider.notifier);
      final tagId = await tagsNotifier.createTag(
        name: sanitizedName,
        color: Colors.blue.value, // Default color
      );
      
      if (tagId != null) {
        // Get the created tag from the provider
        final tagsAsyncValue = ref.read(tagsProvider);
        tagsAsyncValue.whenData((tags) {
          final createdTag = tags.firstWhere(
            (tag) => tag.id == tagId,
          );
          widget.onTagCreated(createdTag);
        });
        _controller.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating tag: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}