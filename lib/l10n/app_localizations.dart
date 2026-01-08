import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'AI Map Explainer'**
  String get appTitle;

  /// Label shown when user selects a location
  ///
  /// In en, this message translates to:
  /// **'You are selecting'**
  String get youAreSelecting;

  /// City label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Province label
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// Country label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Prompt to select information
  ///
  /// In en, this message translates to:
  /// **'Select information you want to learn'**
  String get selectInformationToLearn;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Loading message when searching
  ///
  /// In en, this message translates to:
  /// **'Searching for information about {query}...'**
  String searchingInfoAbout(String query);

  /// Button to learn more
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// Label for current location
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get currentLocation;

  /// Label for historical location
  ///
  /// In en, this message translates to:
  /// **'Historical Location'**
  String get historicalLocation;

  /// Type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Period label
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// Address label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Label for related information
  ///
  /// In en, this message translates to:
  /// **'Related information:'**
  String get relatedInfo;

  /// Title for chat history screen
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// Message when there is no data
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Connection error title
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// Location error title
  ///
  /// In en, this message translates to:
  /// **'Location Error'**
  String get locationError;

  /// Service error title
  ///
  /// In en, this message translates to:
  /// **'Service Error'**
  String get serviceError;

  /// Storage error title
  ///
  /// In en, this message translates to:
  /// **'Storage Error'**
  String get storageError;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the internet. Please check your network connection.'**
  String get cannotConnectToInternet;

  /// Location error message
  ///
  /// In en, this message translates to:
  /// **'Cannot get your location. Please check location permissions in settings.'**
  String get cannotGetLocation;

  /// 404 error message
  ///
  /// In en, this message translates to:
  /// **'Information not found. Please try with different keywords.'**
  String get informationNotFound;

  /// 401/403 error message
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please try again later.'**
  String get authenticationError;

  /// 500+ error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// Generic API error message
  ///
  /// In en, this message translates to:
  /// **'Error loading data. Please try again later.'**
  String get dataLoadError;

  /// Cache error message
  ///
  /// In en, this message translates to:
  /// **'Error accessing saved data. Please try again.'**
  String get cacheError;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Please try again later.'**
  String get unknownError;

  /// Light mode label
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Dark mode label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Cluster marker info window title
  ///
  /// In en, this message translates to:
  /// **'Cluster of {count} locations'**
  String clusterOfLocations(int count);

  /// Cluster marker info window snippet
  ///
  /// In en, this message translates to:
  /// **'Tap to see details'**
  String get tapToSeeDetails;

  /// Loading message for historical locations
  ///
  /// In en, this message translates to:
  /// **'Loading historical locations...'**
  String get loadingHistoricalLocations;

  /// Loading message for history
  ///
  /// In en, this message translates to:
  /// **'Loading history...'**
  String get loadingHistory;

  /// Pull to refresh message
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// Chat input hint
  ///
  /// In en, this message translates to:
  /// **'Do you have your own question?'**
  String get doYouHaveYourOwnQuestion;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Default query for history
  ///
  /// In en, this message translates to:
  /// **'Vietnamese History'**
  String get vietnameseHistory;

  /// Preposition 'about'
  ///
  /// In en, this message translates to:
  /// **'about'**
  String get about;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
