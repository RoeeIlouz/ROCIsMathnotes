import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mathnotes/core/theme/font_awesome4_icons.dart';
import '../../../../core/theme/font_awesome5_icons.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../../../notebooks/presentation/pages/notebooks_page.dart';
import '../../../tags/presentation/pages/tags_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../note_editor/presentation/pages/note_editor_page.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_drawer.dart';
import '../widgets/search_delegate.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const NotesPage(),
    const NotebooksPage(),
    const TagsPage(),
    const SettingsPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: NotesSearchDelegate(),
    );
  }

  void _createNewNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoteEditorPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = ref.watch(isRTLProvider);
    final textDirection = ref.watch(textDirectionProvider);
    
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: HomeAppBar(
          currentIndex: _currentIndex,
          onSearchPressed: _openSearch,
        ),
        drawer: const HomeDrawer(),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(FontAwesome4.sticky_note_o),
              selectedIcon: Icon(FontAwesome4.sticky_note),
              label: l10n.notes,
            ),
            NavigationDestination(
              icon: const Icon(Icons.book_outlined),
              selectedIcon: const Icon(Icons.book),
              label: l10n.notebooks,
            ),
            NavigationDestination(
              icon: const Icon(Icons.label_outline),
              selectedIcon: const Icon(Icons.label),
              label: l10n.tags,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 0 || _currentIndex == 1
            ? FloatingActionButton.extended(
                heroTag: "home_fab",
                onPressed: _createNewNote,
                icon: const Icon(Icons.add),
                label: Text(l10n.newNote),
                tooltip: l10n.newNote,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}