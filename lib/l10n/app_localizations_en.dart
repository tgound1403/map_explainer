// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Map Explainer';

  @override
  String get youAreSelecting => 'You are selecting';

  @override
  String get city => 'City';

  @override
  String get province => 'Province';

  @override
  String get country => 'Country';

  @override
  String get selectInformationToLearn => 'Select information you want to learn';

  @override
  String get loading => 'Loading...';

  @override
  String searchingInfoAbout(String query) {
    return 'Searching for information about $query...';
  }

  @override
  String get learnMore => 'Learn more';

  @override
  String get currentLocation => 'Your location';

  @override
  String get historicalLocation => 'Historical Location';

  @override
  String get type => 'Type';

  @override
  String get period => 'Period';

  @override
  String get address => 'Address';

  @override
  String get relatedInfo => 'Related information:';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get noData => 'No data';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get locationError => 'Location Error';

  @override
  String get serviceError => 'Service Error';

  @override
  String get storageError => 'Storage Error';

  @override
  String get cannotConnectToInternet =>
      'Cannot connect to the internet. Please check your network connection.';

  @override
  String get cannotGetLocation =>
      'Cannot get your location. Please check location permissions in settings.';

  @override
  String get informationNotFound =>
      'Information not found. Please try with different keywords.';

  @override
  String get authenticationError =>
      'Authentication error. Please try again later.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get dataLoadError => 'Error loading data. Please try again later.';

  @override
  String get cacheError => 'Error accessing saved data. Please try again.';

  @override
  String get unknownError =>
      'An unknown error occurred. Please try again later.';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String clusterOfLocations(int count) {
    return 'Cluster of $count locations';
  }

  @override
  String get tapToSeeDetails => 'Tap to see details';

  @override
  String get loadingHistoricalLocations => 'Loading historical locations...';

  @override
  String get loadingHistory => 'Loading history...';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get doYouHaveYourOwnQuestion => 'Do you have your own question?';

  @override
  String get send => 'Send';

  @override
  String get vietnameseHistory => 'Vietnamese History';

  @override
  String get about => 'about';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get youAreOffline => 'You are offline';

  @override
  String get usingCachedData => 'Using cached data';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get checkingConnection => 'Checking connection...';

  @override
  String get backOnline => 'Back online';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get stopReading => 'Stop reading';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String get scrollToBottom => 'Scroll to bottom';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get titleAZ => 'Title A-Z';

  @override
  String get titleZA => 'Title Z-A';

  @override
  String get deleteChatConfirm => 'Are you sure you want to delete this chat?';

  @override
  String get cancel => 'Cancel';
}
