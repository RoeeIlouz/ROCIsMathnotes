import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../sync/presentation/pages/sync_page.dart';


class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textDirection = ref.watch(textDirectionProvider);
    
    return Directionality(
      textDirection: textDirection,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    MdiIcons.mathCompass,
                    size: 48,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.quickActions,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text(l10n.newNote),
              onTap: () {
                Navigator.pop(context);
                // Navigate to new note
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: Text(l10n.newNotebook),
              onTap: () {
                Navigator.pop(context);
                // Navigate to new notebook
              },
            ),
            

            
            const Divider(),
            
            // Sync & Backup Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.syncAndBackup,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.cloud_sync),
              title: Text(l10n.cloudSync),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SyncPage(),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.backup),
              title: Text(l10n.backup),
              onTap: () {
                Navigator.pop(context);
                // Show backup options
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(l10n.restore),
              onTap: () {
                Navigator.pop(context);
                // Show restore options
              },
            ),
            
            const Divider(),
            
            // Statistics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.statistics,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: Text(l10n.viewStatistics),
              onTap: () {
                Navigator.pop(context);
                // Show statistics
              },
            ),
            
            const Divider(),
            
            // Settings
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(l10n.help),
              onTap: () {
                Navigator.pop(context);
                // Show help
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.about),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context, l10n);
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        MdiIcons.mathCompass,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        Text(l10n.aboutDescription),
      ],
    );
  }
}