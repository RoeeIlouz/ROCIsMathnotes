import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/about_dialog.dart';
import '../../../auth/presentation/widgets/backup_settings_widget.dart';


class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final textDirection = ref.watch(textDirectionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Appearance Section
            SettingsSection(
              title: l10n.theme,
              icon: Icons.palette,
              children: [
                SettingsTile(
                  title: l10n.theme,
                  subtitle: _getThemeModeText(themeMode, l10n),
                  leading: const Icon(Icons.brightness_6),
                  onTap: () => _showThemeDialog(context),
                ),
                SettingsTile(
                  title: l10n.language,
                  subtitle: _getLanguageText(locale ?? const Locale('en'), l10n),
                  leading: const Icon(Icons.language),
                  onTap: () => _showLanguageDialog(context),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Backup Settings
            const BackupSettingsWidget(),
            
            const SizedBox(height: 16),
            
            // Data Management Section
            SettingsSection(
              title: 'Data Management',
              icon: Icons.storage,
              children: [
                SettingsTile(
                  title: l10n.exportData,
                  subtitle: l10n.exportAllNotesAndNotebooks,
                  leading: const Icon(Icons.download),
                  onTap: () => _exportData(),
                ),
                SettingsTile(
                  title: l10n.importData,
                  subtitle: l10n.importNotesFromFile,
                  leading: const Icon(Icons.upload),
                  onTap: () => _importData(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            

            
            // Editor Section
            SettingsSection(
              title: l10n.editor,
              icon: Icons.edit,
              children: [
                SettingsTile(
                  title: l10n.defaultFontSize,
                  subtitle: l10n.setDefaultFontSize,
                  leading: const Icon(Icons.format_size),
                  onTap: () => _showFontSizeDialog(),
                ),
                SettingsTile(
                  title: l10n.autoSave,
                  subtitle: l10n.automaticallySaveChanges,
                  leading: const Icon(Icons.save),
                  trailing: Switch(
                    value: true, // TODO: Get from provider
                    onChanged: (value) {
                      // TODO: Toggle auto save
                    },
                  ),
                ),
                SettingsTile(
                  title: l10n.spellCheck,
                  subtitle: l10n.enableSpellChecking,
                  leading: const Icon(Icons.spellcheck),
                  trailing: Switch(
                    value: true, // TODO: Get from provider
                    onChanged: (value) {
                      // TODO: Toggle spell check
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Storage Section
            SettingsSection(
              title: l10n.storage,
              icon: Icons.storage,
              children: [
                SettingsTile(
                  title: l10n.storageUsage,
                  subtitle: l10n.viewStorageUsage,
                  leading: const Icon(Icons.pie_chart),
                  onTap: () => _showStorageUsage(),
                ),
                SettingsTile(
                  title: l10n.clearCache,
                  subtitle: l10n.clearTemporaryFiles,
                  leading: const Icon(Icons.cleaning_services),
                  onTap: () => _clearCache(),
                ),
                SettingsTile(
                  title: l10n.deleteAllData,
                  subtitle: l10n.permanentlyDeleteAllData,
                  leading: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onTap: () => _showDeleteAllDataDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // About Section
            SettingsSection(
              title: l10n.about,
              icon: Icons.info,
              children: [
                SettingsTile(
                  title: l10n.appVersion,
                  subtitle: '1.0.0', // TODO: Get from package info
                  leading: const Icon(Icons.info_outline),
                  onTap: () => showAppAboutDialog(context),
                ),
                SettingsTile(
                  title: l10n.privacyPolicy,
                  subtitle: l10n.readPrivacyPolicy,
                  leading: const Icon(Icons.privacy_tip),
                  onTap: () => _openPrivacyPolicy(),
                ),
                SettingsTile(
                  title: l10n.termsOfService,
                  subtitle: l10n.readTermsOfService,
                  leading: const Icon(Icons.description),
                  onTap: () => _openTermsOfService(),
                ),
                SettingsTile(
                  title: l10n.licenses,
                  subtitle: l10n.viewOpenSourceLicenses,
                  leading: const Icon(Icons.code),
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode, AppLocalizations l10n) {
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  String _getLanguageText(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'en':
        return l10n.english;
      case 'he':
        return l10n.hebrew;
      default:
        return l10n.english;
    }
  }

  void _showThemeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.read(themeModeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.lightTheme),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.darkTheme),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemTheme),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: Text(l10n.english),
              value: const Locale('en'),
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<Locale>(
              title: Text(l10n.hebrew),
              value: const Locale('he'),
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.featureComingSoon),
      ),
    );
  }

  void _importData() {
    // TODO: Implement data import
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.featureComingSoon),
      ),
    );
  }



  void _showFontSizeDialog() {
    // TODO: Implement font size selection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.featureComingSoon),
      ),
    );
  }

  void _showStorageUsage() {
    // TODO: Implement storage usage display
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.featureComingSoon),
      ),
    );
  }

  void _clearCache() {
    // TODO: Implement cache clearing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.cacheCleared),
      ),
    );
  }

  void _showDeleteAllDataDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllData),
        content: Text(l10n.deleteAllDataWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllData();
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

  void _deleteAllData() {
    // TODO: Implement data deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.allDataDeleted),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _openPrivacyPolicy() {
    // TODO: Open privacy policy URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.featureComingSoon),
      ),
    );
  }

  void _openTermsOfService() {
    // TODO: Open terms of service URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.featureComingSoon),
      ),
    );
  }
}