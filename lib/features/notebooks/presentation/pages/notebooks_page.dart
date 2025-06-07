// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/notebook_model.dart';
import '../widgets/notebook_card.dart';
import '../widgets/create_notebook_dialog.dart';
import '../providers/notebooks_provider.dart';

class NotebooksPage extends ConsumerStatefulWidget {
  const NotebooksPage({super.key});

  @override
  ConsumerState<NotebooksPage> createState() => _NotebooksPageState();
}

class _NotebooksPageState extends ConsumerState<NotebooksPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _createNewNotebook() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateNotebookDialog(),
    );
    
    // Refresh the notebooks list if a notebook was created
    if (result == true && mounted) {
      ref.read(notebooksProvider.notifier).loadNotebooks();
    }
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
          // Action bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.notebooksDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isGridView ? Icons.view_list : Icons.view_module,
                  ),
                  onPressed: _toggleViewMode,
                  tooltip: _isGridView ? l10n.listView : l10n.gridView,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createNewNotebook,
                  tooltip: l10n.newNotebook,
                ),
              ],
            ),
          ),
          
          // Notebooks content
          Expanded(
            child: _buildNotebooksContent(),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(notebooksProvider.notifier).loadNotebooks();
  }

  Widget _buildNotebooksContent() {
    final l10n = AppLocalizations.of(context)!;
    final notebooksState = ref.watch(notebooksProvider);
    
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: notebooksState.when(
        data: (notebooks) {
          if (notebooks.isEmpty) {
            return _buildEmptyState();
          }
          
          return _isGridView
              ? _buildGridView(notebooks)
              : _buildListView(notebooks);
        },
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
                onPressed: () => ref.refresh(notebooksProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
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
                  Icons.book_outlined,
                  size: 80,
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.noNotebooks,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.createFirstNotebook,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _createNewNotebook,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createNotebook),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(List<NotebookModel> notebooks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: _getCrossAxisCount(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: notebooks.length,
        itemBuilder: (context, index) {
          return NotebookCard(
            notebook: notebooks[index],
            isGridView: true,
          );
        },
      ),
    );
  }

  Widget _buildListView(List<NotebookModel> notebooks) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: notebooks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return NotebookCard(
          notebook: notebooks[index],
          isGridView: false,
        );
      },
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }
}