import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'MathNotes'**
  String get appTitle;

  /// Notes page title
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Notebooks page title
  ///
  /// In en, this message translates to:
  /// **'Notebooks'**
  String get notebooks;

  /// Tags page title
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Create new note action
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// Create new notebook action
  ///
  /// In en, this message translates to:
  /// **'New Notebook'**
  String get newNotebook;

  /// Search action
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Start typing to search notes...'**
  String get startTypingToSearch;

  /// No description provided for @drawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get drawing;

  /// No description provided for @handwriting.
  ///
  /// In en, this message translates to:
  /// **'Handwriting'**
  String get handwriting;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @math.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get math;

  /// No description provided for @formula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// No description provided for @graph.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get graph;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Export data option title
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Export data option description
  ///
  /// In en, this message translates to:
  /// **'Export all notes and notebooks'**
  String get exportAllNotesAndNotebooks;

  /// Import data option title
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// Import data option description
  ///
  /// In en, this message translates to:
  /// **'Import notes from file'**
  String get importNotesFromFile;

  /// Sync page title
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Backup action
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// Restore action
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get hebrew;

  /// No description provided for @recognizeHandwriting.
  ///
  /// In en, this message translates to:
  /// **'Recognize Handwriting'**
  String get recognizeHandwriting;

  /// No description provided for @generateGraph.
  ///
  /// In en, this message translates to:
  /// **'Generate Graph'**
  String get generateGraph;

  /// No description provided for @summarizeNote.
  ///
  /// In en, this message translates to:
  /// **'Summarize Note'**
  String get summarizeNote;

  /// AI Features page title
  ///
  /// In en, this message translates to:
  /// **'AI Features'**
  String get aiFeatures;

  /// Cloud synchronization feature
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notebook.
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get notebook;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// Sort by title option
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @thickness.
  ///
  /// In en, this message translates to:
  /// **'Thickness'**
  String get thickness;

  /// No description provided for @opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get opacity;

  /// No description provided for @tool.
  ///
  /// In en, this message translates to:
  /// **'Tool'**
  String get tool;

  /// No description provided for @pen.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get pen;

  /// No description provided for @pencil.
  ///
  /// In en, this message translates to:
  /// **'Pencil'**
  String get pencil;

  /// No description provided for @marker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get marker;

  /// No description provided for @eraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get eraser;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @underline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font Family'**
  String get fontFamily;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColor;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @alignment.
  ///
  /// In en, this message translates to:
  /// **'Alignment'**
  String get alignment;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @justify.
  ///
  /// In en, this message translates to:
  /// **'Justify'**
  String get justify;

  /// No description provided for @bulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet List'**
  String get bulletList;

  /// No description provided for @numberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered List'**
  String get numberedList;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @insertImage.
  ///
  /// In en, this message translates to:
  /// **'Insert Image'**
  String get insertImage;

  /// No description provided for @insertTable.
  ///
  /// In en, this message translates to:
  /// **'Insert Table'**
  String get insertTable;

  /// No description provided for @insertLink.
  ///
  /// In en, this message translates to:
  /// **'Insert Link'**
  String get insertLink;

  /// No description provided for @mathExpression.
  ///
  /// In en, this message translates to:
  /// **'Math Expression'**
  String get mathExpression;

  /// No description provided for @enterFormula.
  ///
  /// In en, this message translates to:
  /// **'Enter Formula'**
  String get enterFormula;

  /// No description provided for @invalidFormula.
  ///
  /// In en, this message translates to:
  /// **'Invalid Formula'**
  String get invalidFormula;

  /// No description provided for @processingAI.
  ///
  /// In en, this message translates to:
  /// **'Processing with AI...'**
  String get processingAI;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'AI processing failed'**
  String get aiError;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync successful'**
  String get syncSuccess;

  /// Sync error status
  ///
  /// In en, this message translates to:
  /// **'Sync Error'**
  String get syncError;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteConfirm;

  /// No description provided for @deleteNotebookConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notebook and all its notes?'**
  String get deleteNotebookConfirm;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to save them?'**
  String get unsavedChanges;

  /// Notebook name field
  ///
  /// In en, this message translates to:
  /// **'Notebook Name'**
  String get notebookName;

  /// Tag name field
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get tagName;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note Title'**
  String get noteTitle;

  /// Search placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get searchNotes;

  /// Message when no notes match search
  ///
  /// In en, this message translates to:
  /// **'No notes found'**
  String get noNotesFound;

  /// No description provided for @noNotebooksFound.
  ///
  /// In en, this message translates to:
  /// **'No notebooks found'**
  String get noNotebooksFound;

  /// No description provided for @createFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Create your first note'**
  String get createFirstNote;

  /// Create first notebook prompt
  ///
  /// In en, this message translates to:
  /// **'Create your first notebook'**
  String get createFirstNotebook;

  /// No description provided for @recentNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent Notes'**
  String get recentNotes;

  /// All notes filter option
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get allNotes;

  /// Favorites filter option
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @moveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get moveToTrash;

  /// No description provided for @restoreFromTrash.
  ///
  /// In en, this message translates to:
  /// **'Restore from Trash'**
  String get restoreFromTrash;

  /// No description provided for @permanentlyDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete'**
  String get permanentlyDelete;

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get emptyTrash;

  /// No description provided for @exportToPDF.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPDF;

  /// No description provided for @exportToImage.
  ///
  /// In en, this message translates to:
  /// **'Export to Image'**
  String get exportToImage;

  /// No description provided for @exportToText.
  ///
  /// In en, this message translates to:
  /// **'Export to Text'**
  String get exportToText;

  /// No description provided for @importFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get importFromFile;

  /// No description provided for @selectNotebook.
  ///
  /// In en, this message translates to:
  /// **'Select Notebook'**
  String get selectNotebook;

  /// No description provided for @selectTags.
  ///
  /// In en, this message translates to:
  /// **'Select Tags'**
  String get selectTags;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTag;

  /// No description provided for @removeTag.
  ///
  /// In en, this message translates to:
  /// **'Remove Tag'**
  String get removeTag;

  /// Edit tag action
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get editTag;

  /// Delete tag action
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get deleteTag;

  /// View notes action
  ///
  /// In en, this message translates to:
  /// **'View Notes'**
  String get viewNotes;

  /// Just now time indicator
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// One minute ago
  ///
  /// In en, this message translates to:
  /// **'1 minute ago'**
  String get minuteAgo;

  /// Multiple minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(int minutes);

  /// One hour ago
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get hourAgo;

  /// Multiple hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// One day ago
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get dayAgo;

  /// Multiple days ago
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// One month ago
  ///
  /// In en, this message translates to:
  /// **'1 month ago'**
  String get monthAgo;

  /// Multiple months ago
  ///
  /// In en, this message translates to:
  /// **'{months} months ago'**
  String monthsAgo(int months);

  /// No description provided for @yearAgo.
  ///
  /// In en, this message translates to:
  /// **'1 year ago'**
  String get yearAgo;

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} years ago'**
  String yearsAgo(int count);

  /// New tag filter
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_;

  /// Popular tag filter
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// Development framework
  ///
  /// In en, this message translates to:
  /// **'Framework'**
  String get framework;

  /// Supported platforms
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// Database technology
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// Cloud storage provider
  ///
  /// In en, this message translates to:
  /// **'Cloud Storage'**
  String get cloudStorage;

  /// AI service provider
  ///
  /// In en, this message translates to:
  /// **'AI Provider'**
  String get aiProvider;

  /// Software licenses
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Subtitle for licenses section
  ///
  /// In en, this message translates to:
  /// **'View open source licenses'**
  String get viewOpenSourceLicenses;

  /// Technical information section title
  ///
  /// In en, this message translates to:
  /// **'Technical Information'**
  String get technicalInfo;

  /// Description of the MathNotes application
  ///
  /// In en, this message translates to:
  /// **'MathNotes is a comprehensive note-taking application designed specifically for mathematics students and professionals. Create, organize, and manage your mathematical notes with ease.'**
  String get appDescription;

  /// Message shown when content is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Name of the application
  ///
  /// In en, this message translates to:
  /// **'MathNotes'**
  String get appName;

  /// Label for website link
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Label for source code link
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get sourceCode;

  /// Contact us section title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Key features section title
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// Handwriting recognition feature
  ///
  /// In en, this message translates to:
  /// **'Handwriting Recognition'**
  String get handwritingRecognition;

  /// Handwriting recognition setting description
  ///
  /// In en, this message translates to:
  /// **'Convert handwriting to text automatically'**
  String get convertHandwritingToText;

  /// Math graph generation feature
  ///
  /// In en, this message translates to:
  /// **'Math Graph Generation'**
  String get mathGraphGeneration;

  /// Note summarization feature
  ///
  /// In en, this message translates to:
  /// **'Note Summarization'**
  String get noteSummarization;

  /// Multi-language support feature
  ///
  /// In en, this message translates to:
  /// **'Multi-Language Support'**
  String get multiLanguageSupport;

  /// Dark and light themes feature
  ///
  /// In en, this message translates to:
  /// **'Dark and Light Themes'**
  String get darkAndLightThemes;

  /// Create new tag button text
  ///
  /// In en, this message translates to:
  /// **'Create New Tag'**
  String get createNewTag;

  /// Enter tag name placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter tag name'**
  String get enterTagName;

  /// Create action
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Error message when trying to create a tag that already exists
  ///
  /// In en, this message translates to:
  /// **'Tag already exists'**
  String get tagAlreadyExists;

  /// Validation message for empty tag name field
  ///
  /// In en, this message translates to:
  /// **'Please enter a tag name'**
  String get pleaseEnterTagName;

  /// Validation message for invalid tag name
  ///
  /// In en, this message translates to:
  /// **'Invalid tag name'**
  String get invalidTagName;

  /// Label for color selection in tag creation
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// Label for common tags section
  ///
  /// In en, this message translates to:
  /// **'Common Tags'**
  String get commonTags;

  /// Label for icon selection in notebook creation
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// Description for favorite notebook checkbox
  ///
  /// In en, this message translates to:
  /// **'Mark as favorite notebook'**
  String get favoriteNotebookDescription;

  /// Create tag action
  ///
  /// In en, this message translates to:
  /// **'Create Tag'**
  String get createTag;

  /// Validation message for empty notebook name field
  ///
  /// In en, this message translates to:
  /// **'Please enter a notebook name'**
  String get pleaseEnterNotebookName;

  /// Label for description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Placeholder text for optional description field
  ///
  /// In en, this message translates to:
  /// **'Optional description'**
  String get optionalDescription;

  /// Confirmation message for deleting a notebook
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notebook?'**
  String get deleteNotebookConfirmation;

  /// Edit notebook action
  ///
  /// In en, this message translates to:
  /// **'Edit Notebook'**
  String get editNotebook;

  /// Create notebook action
  ///
  /// In en, this message translates to:
  /// **'Create Notebook'**
  String get createNotebook;

  /// Enter notebook name placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter notebook name'**
  String get enterNotebookName;

  /// Application subtitle
  ///
  /// In en, this message translates to:
  /// **'Smart note-taking with AI'**
  String get appSubtitle;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Sync and backup section title
  ///
  /// In en, this message translates to:
  /// **'Sync & Backup'**
  String get syncAndBackup;

  /// Auto backup setting title
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackup;

  /// Auto backup setting description
  ///
  /// In en, this message translates to:
  /// **'Automatically backup notes to cloud'**
  String get automaticallyBackupNotes;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// View statistics action
  ///
  /// In en, this message translates to:
  /// **'View Statistics'**
  String get viewStatistics;

  /// Help action
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// About action
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// About dialog description
  ///
  /// In en, this message translates to:
  /// **'A powerful note-taking app with AI features'**
  String get aboutDescription;

  /// Search in notebooks option
  ///
  /// In en, this message translates to:
  /// **'Search in notebooks'**
  String get searchInNotebooks;

  /// Search in tags option
  ///
  /// In en, this message translates to:
  /// **'Search in tags'**
  String get searchInTags;

  /// Recent searches section
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// Clear search history action
  ///
  /// In en, this message translates to:
  /// **'Clear search history'**
  String get clearSearchHistory;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Recent filter option
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// Sort by menu title
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Sort by date created option
  ///
  /// In en, this message translates to:
  /// **'Date Created'**
  String get dateCreated;

  /// Sort by date modified option
  ///
  /// In en, this message translates to:
  /// **'Date Modified'**
  String get dateModified;

  /// Ascending sort order
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// Descending sort order
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// Delete note action
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// Delete note confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteConfirmation;

  /// Edit note action
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// Share note action
  ///
  /// In en, this message translates to:
  /// **'Share Note'**
  String get shareNote;

  /// Favorite note action
  ///
  /// In en, this message translates to:
  /// **'Favorite Note'**
  String get favoriteNote;

  /// Unfavorite note action
  ///
  /// In en, this message translates to:
  /// **'Unfavorite Note'**
  String get unfavoriteNote;

  /// Delete notebook action
  ///
  /// In en, this message translates to:
  /// **'Delete Notebook'**
  String get deleteNotebook;

  /// Favorite notebook action
  ///
  /// In en, this message translates to:
  /// **'Favorite Notebook'**
  String get favoriteNotebook;

  /// Unfavorite notebook action
  ///
  /// In en, this message translates to:
  /// **'Unfavorite Notebook'**
  String get unfavoriteNotebook;

  /// Notes count label
  ///
  /// In en, this message translates to:
  /// **'{count} notes'**
  String notesCount(int count);

  /// Delete tag confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this tag?'**
  String get deleteTagConfirmation;

  /// Message when no notebooks exist
  ///
  /// In en, this message translates to:
  /// **'No notebooks yet'**
  String get noNotebooks;

  /// Message when no tags exist
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTags;

  /// Create first tag prompt
  ///
  /// In en, this message translates to:
  /// **'Create your first tag'**
  String get createFirstTag;

  /// Message when notebook has no notes
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get noNotes;

  /// Message when notebook has one note
  ///
  /// In en, this message translates to:
  /// **'1 note'**
  String get oneNote;

  /// Duplicate action
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// Sync now action
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Last sync time
  ///
  /// In en, this message translates to:
  /// **'Last sync: {time}'**
  String lastSyncTime(String time);

  /// Sync status label
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatus;

  /// Connected status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Disconnected status
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Syncing status
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// AI summarization feature
  ///
  /// In en, this message translates to:
  /// **'AI Summarization'**
  String get aiSummarization;

  /// AI translation feature
  ///
  /// In en, this message translates to:
  /// **'AI Translation'**
  String get aiTranslation;

  /// AI question answering feature
  ///
  /// In en, this message translates to:
  /// **'AI Question Answering'**
  String get aiQuestionAnswering;

  /// AI math solver feature
  ///
  /// In en, this message translates to:
  /// **'AI Math Solver'**
  String get aiMathSolver;

  /// Enable AI features setting
  ///
  /// In en, this message translates to:
  /// **'Enable AI Features'**
  String get enableAI;

  /// AI API key setting
  ///
  /// In en, this message translates to:
  /// **'AI API Key'**
  String get aiApiKey;

  /// Enter API key placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter API Key'**
  String get enterApiKey;

  /// Search hint text
  ///
  /// In en, this message translates to:
  /// **'Search notes, notebooks, tags...'**
  String get searchHint;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get noSearchResults;

  /// List view option
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// Grid view option
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get gridView;

  /// No notes yet message
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesYet;

  /// Create note action
  ///
  /// In en, this message translates to:
  /// **'Create Note'**
  String get createNote;

  /// Notebooks description
  ///
  /// In en, this message translates to:
  /// **'Organize your notes into notebooks'**
  String get notebooksDesc;

  /// Notebooks description text
  ///
  /// In en, this message translates to:
  /// **'Organize your notes into notebooks'**
  String get notebooksDescription;

  /// Archived filter option
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// Last modified sort option
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get lastModified;

  /// Archive action
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Message when there are no recent searches
  ///
  /// In en, this message translates to:
  /// **'No recent searches'**
  String get noRecentSearches;

  /// Search filters title
  ///
  /// In en, this message translates to:
  /// **'Search Filters'**
  String get searchFilters;

  /// Description for search tips
  ///
  /// In en, this message translates to:
  /// **'Search through your notes, notebooks, and tags'**
  String get searchTipsDescription;

  /// Search tips title
  ///
  /// In en, this message translates to:
  /// **'Search Tips'**
  String get searchTips;

  /// Handwriting notes filter
  ///
  /// In en, this message translates to:
  /// **'Handwriting Notes'**
  String get handwritingNotes;

  /// No description provided for @stylus.
  ///
  /// In en, this message translates to:
  /// **'Stylus'**
  String get stylus;

  /// No description provided for @touch.
  ///
  /// In en, this message translates to:
  /// **'Touch'**
  String get touch;

  /// No description provided for @inputMethod.
  ///
  /// In en, this message translates to:
  /// **'Input Method'**
  String get inputMethod;

  /// No description provided for @pressureSensitive.
  ///
  /// In en, this message translates to:
  /// **'Pressure Sensitive'**
  String get pressureSensitive;

  /// No description provided for @smoothing.
  ///
  /// In en, this message translates to:
  /// **'Smoothing'**
  String get smoothing;

  /// No description provided for @stabilization.
  ///
  /// In en, this message translates to:
  /// **'Stabilization'**
  String get stabilization;

  /// No description provided for @drawingSettings.
  ///
  /// In en, this message translates to:
  /// **'Drawing Settings'**
  String get drawingSettings;

  /// No description provided for @handwritingSettings.
  ///
  /// In en, this message translates to:
  /// **'Handwriting Settings'**
  String get handwritingSettings;

  /// No description provided for @recognitionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Recognition Language'**
  String get recognitionLanguage;

  /// No description provided for @autoRecognize.
  ///
  /// In en, this message translates to:
  /// **'Auto Recognize'**
  String get autoRecognize;

  /// No description provided for @manualRecognize.
  ///
  /// In en, this message translates to:
  /// **'Manual Recognize'**
  String get manualRecognize;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @alternatives.
  ///
  /// In en, this message translates to:
  /// **'Alternatives'**
  String get alternatives;

  /// No description provided for @acceptSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Accept Suggestion'**
  String get acceptSuggestion;

  /// No description provided for @rejectSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Reject Suggestion'**
  String get rejectSuggestion;

  /// No description provided for @mathMode.
  ///
  /// In en, this message translates to:
  /// **'Math Mode'**
  String get mathMode;

  /// No description provided for @textMode.
  ///
  /// In en, this message translates to:
  /// **'Text Mode'**
  String get textMode;

  /// No description provided for @mixedMode.
  ///
  /// In en, this message translates to:
  /// **'Mixed Mode'**
  String get mixedMode;

  /// No description provided for @graphType.
  ///
  /// In en, this message translates to:
  /// **'Graph Type'**
  String get graphType;

  /// No description provided for @lineGraph.
  ///
  /// In en, this message translates to:
  /// **'Line Graph'**
  String get lineGraph;

  /// No description provided for @barGraph.
  ///
  /// In en, this message translates to:
  /// **'Bar Graph'**
  String get barGraph;

  /// No description provided for @pieChart.
  ///
  /// In en, this message translates to:
  /// **'Pie Chart'**
  String get pieChart;

  /// No description provided for @scatterPlot.
  ///
  /// In en, this message translates to:
  /// **'Scatter Plot'**
  String get scatterPlot;

  /// No description provided for @histogram.
  ///
  /// In en, this message translates to:
  /// **'Histogram'**
  String get histogram;

  /// No description provided for @functionPlot.
  ///
  /// In en, this message translates to:
  /// **'Function Plot'**
  String get functionPlot;

  /// No description provided for @parametricPlot.
  ///
  /// In en, this message translates to:
  /// **'Parametric Plot'**
  String get parametricPlot;

  /// No description provided for @polarPlot.
  ///
  /// In en, this message translates to:
  /// **'Polar Plot'**
  String get polarPlot;

  /// No description provided for @xAxis.
  ///
  /// In en, this message translates to:
  /// **'X Axis'**
  String get xAxis;

  /// No description provided for @yAxis.
  ///
  /// In en, this message translates to:
  /// **'Y Axis'**
  String get yAxis;

  /// No description provided for @zAxis.
  ///
  /// In en, this message translates to:
  /// **'Z Axis'**
  String get zAxis;

  /// No description provided for @domain.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get domain;

  /// No description provided for @range.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get range;

  /// No description provided for @gridLines.
  ///
  /// In en, this message translates to:
  /// **'Grid Lines'**
  String get gridLines;

  /// No description provided for @axisLabels.
  ///
  /// In en, this message translates to:
  /// **'Axis Labels'**
  String get axisLabels;

  /// No description provided for @legend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// No description provided for @graphTitle.
  ///
  /// In en, this message translates to:
  /// **'Graph Title'**
  String get graphTitle;

  /// No description provided for @generateFromFormula.
  ///
  /// In en, this message translates to:
  /// **'Generate from Formula'**
  String get generateFromFormula;

  /// No description provided for @customizeGraph.
  ///
  /// In en, this message translates to:
  /// **'Customize Graph'**
  String get customizeGraph;

  /// No description provided for @saveGraph.
  ///
  /// In en, this message translates to:
  /// **'Save Graph'**
  String get saveGraph;

  /// No description provided for @insertGraph.
  ///
  /// In en, this message translates to:
  /// **'Insert Graph'**
  String get insertGraph;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummary;

  /// No description provided for @keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get keyPoints;

  /// No description provided for @mainTopics.
  ///
  /// In en, this message translates to:
  /// **'Main Topics'**
  String get mainTopics;

  /// No description provided for @actionItems.
  ///
  /// In en, this message translates to:
  /// **'Action Items'**
  String get actionItems;

  /// No description provided for @summaryLength.
  ///
  /// In en, this message translates to:
  /// **'Summary Length'**
  String get summaryLength;

  /// No description provided for @short.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get short;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @long.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get long;

  /// No description provided for @detailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get detailed;

  /// No description provided for @generateSummary.
  ///
  /// In en, this message translates to:
  /// **'Generate Summary'**
  String get generateSummary;

  /// No description provided for @saveSummary.
  ///
  /// In en, this message translates to:
  /// **'Save Summary'**
  String get saveSummary;

  /// No description provided for @appendSummary.
  ///
  /// In en, this message translates to:
  /// **'Append Summary'**
  String get appendSummary;

  /// No description provided for @replaceSummary.
  ///
  /// In en, this message translates to:
  /// **'Replace Summary'**
  String get replaceSummary;

  /// Message for features that are not yet implemented
  ///
  /// In en, this message translates to:
  /// **'Feature Coming Soon'**
  String get featureComingSoon;

  /// Delete all data option
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// Description for delete all data option
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all notes, notebooks, and tags'**
  String get permanentlyDeleteAllData;

  /// Warning message for delete all data
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get deleteAllDataWarning;

  /// Confirmation message after deleting all data
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted successfully'**
  String get allDataDeleted;

  /// Confirmation message after clearing cache
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// Theme settings section title
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Title for theme selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// Description for cloud sync feature
  ///
  /// In en, this message translates to:
  /// **'Sync notes across devices'**
  String get syncNotesAcrossDevices;

  /// Title for language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Label for terms of service
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Subtitle for terms of service section
  ///
  /// In en, this message translates to:
  /// **'Read terms of service'**
  String get readTermsOfService;

  /// Label for privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Subtitle for privacy policy section
  ///
  /// In en, this message translates to:
  /// **'Read privacy policy'**
  String get readPrivacyPolicy;

  /// Label for app version
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Label for clear cache button
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Subtitle for clear cache section
  ///
  /// In en, this message translates to:
  /// **'Clear temporary files and cached data'**
  String get clearTemporaryFiles;

  /// Label for storage usage
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get storageUsage;

  /// Subtitle for storage usage section
  ///
  /// In en, this message translates to:
  /// **'View detailed storage usage information'**
  String get viewStorageUsage;

  /// Label for storage section
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// Subtitle for spell check setting
  ///
  /// In en, this message translates to:
  /// **'Enable automatic spell checking while typing'**
  String get enableSpellChecking;

  /// Label for spell check setting
  ///
  /// In en, this message translates to:
  /// **'Spell Check'**
  String get spellCheck;

  /// Subtitle for auto save setting
  ///
  /// In en, this message translates to:
  /// **'Automatically save changes while typing'**
  String get automaticallySaveChanges;

  /// Label for auto save setting
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get autoSave;

  /// Subtitle for font size setting
  ///
  /// In en, this message translates to:
  /// **'Set the default font size for new notes'**
  String get setDefaultFontSize;

  /// Label for default font size setting
  ///
  /// In en, this message translates to:
  /// **'Default Font Size'**
  String get defaultFontSize;

  /// Label for editor section
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get editor;

  /// Subtitle for AI API key setting
  ///
  /// In en, this message translates to:
  /// **'Configure your AI API key for enhanced features'**
  String get configureAiApiKey;

  /// Subtitle for note summarization setting
  ///
  /// In en, this message translates to:
  /// **'AI-powered note summaries'**
  String get aiPoweredNoteSummaries;

  /// Subtitle for math graph generation setting
  ///
  /// In en, this message translates to:
  /// **'Automatically generate graphs from mathematical formulas'**
  String get autoGenerateGraphsFromFormulas;

  /// Success message when a notebook is deleted
  ///
  /// In en, this message translates to:
  /// **'Notebook deleted successfully'**
  String get notebookDeleted;

  /// Success message when a note is deleted
  ///
  /// In en, this message translates to:
  /// **'Note deleted successfully'**
  String get noteDeleted;

  /// Error message when notebook deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting notebook'**
  String get errorDeletingNotebook;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'he': return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
