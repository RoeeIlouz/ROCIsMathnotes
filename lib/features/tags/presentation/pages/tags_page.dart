import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../widgets/tag_chip.dart';
import '../widgets/create_tag_dialog.dart';
import '../../data/models/tag_model.dart';
import '../providers/tags_provider.dart';

class TagsPage extends ConsumerStatefulWidget {
  const TagsPage({super.key});

  @override
  ConsumerState<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends ConsumerState<TagsPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // name, usage, recent

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _createNewTag() {
    showDialog(
      context: context,
      builder: (context) => const CreateTagDialog(),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final textDirection = ref.watch(textDirectionProvider);
    
    return Directionality(
      textDirection: textDirection,
      child: Column(
        children: [
          // Search and action bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchInTags,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
                
                const SizedBox(height: 12),
                
                // Action bar
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.searchTipsDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    _buildSortMenu(),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _createNewTag,
                      tooltip: l10n.createTag,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tags content
          Expanded(
            child: _buildTagsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortMenu() {
    final l10n = AppLocalizations.of(context)!;
    
    final sortOptions = [
      {'value': 'name', 'label': l10n.tagName, 'icon': Icons.sort_by_alpha},
        {'value': 'usage', 'label': l10n.sortBy, 'icon': Icons.trending_up},
      {'value': 'recent', 'label': l10n.recent, 'icon': Icons.access_time},
    ];
    
    final selectedOption = sortOptions.firstWhere(
      (option) => option['value'] == _sortBy,
      orElse: () => sortOptions.first,
    );
    
    return PopupMenuButton<String>(
      onSelected: _onSortChanged,
      itemBuilder: (context) => sortOptions.map((option) {
        final isSelected = option['value'] == _sortBy;
        return PopupMenuItem<String>(
          value: option['value'] as String,
          child: Row(
            children: [
              Icon(
                option['icon'] as IconData,
                size: 20,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option['label'] as String,
                  style: TextStyle(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedOption['icon'] as IconData,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              selectedOption['label'] as String,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
      tooltip: l10n.sortBy,
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(tagsProvider.notifier).loadTags();
  }

  Widget _buildTagsContent() {
    final l10n = AppLocalizations.of(context)!;
    
    final tagsState = ref.watch(tagsProvider);
    
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: tagsState.when(
        data: (tags) => _buildTagsData(tags),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.error,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(tagsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTagsData(List<TagModel> tags) {
    final l10n = AppLocalizations.of(context)!;
    
    if (tags.isEmpty) {
      return _buildEmptyState();
    }
    
    // Filter tags based on search query
    final filteredTags = tags.where((tag) {
      if (_searchQuery.isEmpty) return true;
      return tag.name.toLowerCase().contains(_searchQuery);
    }).toList();
    
    // Sort tags
    filteredTags.sort((a, b) {
      switch (_sortBy) {
        case 'usage':
          return b.usageCount.compareTo(a.usageCount);
        case 'recent':
          return b.createdAt.compareTo(a.createdAt);
        case 'name':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });
    
    if (filteredTags.isEmpty) {
      return _buildNoResultsState();
    }
    
    return _buildTagsList(filteredTags);
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.label_outline,
                  size: 80,
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.noTags,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.createFirstTag,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _createNewTag,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createTag),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noTags,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '"$_searchQuery"',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsList(List<TagModel> tags) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tags.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return TagChipWidget(
          tag: tags[index],
          onTap: () => _onTagTapped(tags[index]),
          onEdit: () => _editTag(tags[index]),
          onDelete: () => _deleteTag(tags[index]),
        );
      },
    );
  }

  void _onTagTapped(TagModel tag) {
    // TODO: Navigate to notes with this tag
  }

  void _editTag(TagModel tag) {
    showDialog(
      context: context,
      builder: (context) => CreateTagDialog(tag: tag),
    );
  }

  void _deleteTag(TagModel tag) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTag),
        content: Text(l10n.deleteTagConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(tagsProvider.notifier).deleteTag(tag.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}