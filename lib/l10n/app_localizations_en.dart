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

  @override
  String get favorites => 'Favorites';

  @override
  String get all => 'All';

  @override
  String get locations => 'Locations';

  @override
  String get chats => 'Chats';

  @override
  String get clearAll => 'Clear all';

  @override
  String get clearAllFavoritesConfirm =>
      'Are you sure you want to clear all favorites?';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get noFavoritesMessage =>
      'Start favoriting locations and chats to see them here.';

  @override
  String get search => 'Search';

  @override
  String get searchLocations => 'Search locations...';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get noSearchResults => 'No results found';

  @override
  String get noSearchResultsMessage =>
      'Try different keywords or check your spelling.';

  @override
  String get results => 'results';

  @override
  String get result => 'result';

  @override
  String get collections => 'Collections';

  @override
  String get createCollection => 'Create Collection';

  @override
  String get collectionName => 'Collection Name';

  @override
  String get collectionNameRequired => 'Name is required';

  @override
  String get noCollections => 'No collections yet';

  @override
  String get noCollectionsMessage =>
      'Create your first collection to organize locations and chats.';

  @override
  String get item => 'item';

  @override
  String get items => 'items';

  @override
  String get addToCollection => 'Add to Collection';

  @override
  String get itemAddedToCollection => 'Item added to collection';

  @override
  String get createNew => 'Create New';

  @override
  String get noItems => 'No items in collection';

  @override
  String get noItemsMessage => 'Add locations or chats to this collection.';

  @override
  String get deleteCollection => 'Delete Collection';

  @override
  String get deleteCollectionConfirm =>
      'Are you sure you want to delete this collection? All items will be removed.';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get color => 'Color';

  @override
  String get icon => 'Icon';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get close => 'Close';

  @override
  String get description => 'Description';

  @override
  String get beforeChrist => 'BC';

  @override
  String get unknownPeriod => 'Unknown Period';
}
