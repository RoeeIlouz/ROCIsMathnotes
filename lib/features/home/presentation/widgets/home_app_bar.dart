import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final int currentIndex;
  final VoidCallback onSearchPressed;

  const HomeAppBar({
    super.key,
    required this.currentIndex,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    
    String getTitle() {
      switch (currentIndex) {
        case 0:
          return l10n.notes;
        case 1:
          return l10n.notebooks;
        case 2:
          return l10n.tags;
        case 3:
          return l10n.settings;
        default:
          return l10n.appTitle;
      }
    }

    return AppBar(
      title: Text(
        getTitle(),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        // Search button (only show on notes and notebooks pages)
        if (currentIndex == 0 || currentIndex == 1)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchPressed,
            tooltip: l10n.search,
          ),
        
        // Theme toggle button
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
          tooltip: isDark ? l10n.lightTheme : l10n.darkTheme,
        ),
        
        // Language toggle button
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () {
            ref.read(localeProvider.notifier).toggleLanguage();
          },
          tooltip: l10n.language,
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}