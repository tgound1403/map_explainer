// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'AI Map Explainer';

  @override
  String get youAreSelecting => 'Bạn đang chọn';

  @override
  String get city => 'Thành phố';

  @override
  String get province => 'Tỉnh';

  @override
  String get country => 'Quốc gia';

  @override
  String get selectInformationToLearn => 'Hãy chọn thông tin bạn muốn tìm hiểu';

  @override
  String get loading => 'Đang tải...';

  @override
  String searchingInfoAbout(String query) {
    return 'Đang tìm kiếm thông tin về $query...';
  }

  @override
  String get learnMore => 'Tìm hiểu thêm';

  @override
  String get currentLocation => 'Vị trí của bạn';

  @override
  String get historicalLocation => 'Địa điểm lịch sử';

  @override
  String get type => 'Loại';

  @override
  String get period => 'Thời kỳ';

  @override
  String get address => 'Địa chỉ';

  @override
  String get relatedInfo => 'Thông tin liên quan:';

  @override
  String get chatHistory => 'Lịch sử trò chuyện';

  @override
  String get noData => 'Không có dữ liệu';

  @override
  String get delete => 'Xóa';

  @override
  String get retry => 'Thử lại';

  @override
  String get error => 'Đã xảy ra lỗi';

  @override
  String get connectionError => 'Lỗi kết nối';

  @override
  String get locationError => 'Lỗi vị trí';

  @override
  String get serviceError => 'Lỗi dịch vụ';

  @override
  String get storageError => 'Lỗi lưu trữ';

  @override
  String get cannotConnectToInternet =>
      'Không thể kết nối đến internet. Vui lòng kiểm tra kết nối mạng của bạn.';

  @override
  String get cannotGetLocation =>
      'Không thể lấy vị trí của bạn. Vui lòng kiểm tra quyền truy cập vị trí trong cài đặt.';

  @override
  String get informationNotFound =>
      'Không tìm thấy thông tin. Vui lòng thử với từ khóa khác.';

  @override
  String get authenticationError => 'Lỗi xác thực. Vui lòng thử lại sau.';

  @override
  String get serverError => 'Lỗi máy chủ. Vui lòng thử lại sau.';

  @override
  String get dataLoadError => 'Lỗi khi tải dữ liệu. Vui lòng thử lại sau.';

  @override
  String get cacheError => 'Lỗi khi truy cập dữ liệu đã lưu. Vui lòng thử lại.';

  @override
  String get unknownError =>
      'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.';

  @override
  String get lightMode => 'Chế độ sáng';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String clusterOfLocations(int count) {
    return 'Cụm $count địa điểm';
  }

  @override
  String get tapToSeeDetails => 'Tap để xem chi tiết';

  @override
  String get loadingHistoricalLocations => 'Đang tải địa điểm lịch sử...';

  @override
  String get loadingHistory => 'Đang tải lịch sử...';

  @override
  String get pullToRefresh => 'Kéo xuống để làm mới';

  @override
  String get doYouHaveYourOwnQuestion => 'Hay bạn có câu hỏi cho riêng mình';

  @override
  String get send => 'Gửi';

  @override
  String get vietnameseHistory => 'Lịch sử Việt Nam';

  @override
  String get about => 'về';

  @override
  String get offlineMode => 'Chế độ ngoại tuyến';

  @override
  String get youAreOffline => 'Bạn đang ngoại tuyến';

  @override
  String get usingCachedData => 'Đang sử dụng dữ liệu đã lưu';

  @override
  String get noInternetConnection => 'Không có kết nối internet';

  @override
  String get checkingConnection => 'Đang kiểm tra kết nối...';

  @override
  String get backOnline => 'Đã kết nối lại';

  @override
  String get readAloud => 'Đọc to';

  @override
  String get stopReading => 'Dừng đọc';

  @override
  String get justNow => 'Vừa xong';

  @override
  String minutesAgo(int count) {
    return '$count phút trước';
  }

  @override
  String hoursAgo(int count) {
    return '$count giờ trước';
  }

  @override
  String get scrollToBottom => 'Cuộn xuống dưới';

  @override
  String get newestFirst => 'Mới nhất trước';

  @override
  String get oldestFirst => 'Cũ nhất trước';

  @override
  String get titleAZ => 'Tiêu đề A-Z';

  @override
  String get titleZA => 'Tiêu đề Z-A';

  @override
  String get deleteChatConfirm =>
      'Bạn có chắc chắn muốn xóa cuộc trò chuyện này?';

  @override
  String get cancel => 'Hủy';

  @override
  String get favorites => 'Yêu thích';

  @override
  String get all => 'Tất cả';

  @override
  String get locations => 'Địa điểm';

  @override
  String get chats => 'Trò chuyện';

  @override
  String get clearAll => 'Xóa tất cả';

  @override
  String get clearAllFavoritesConfirm =>
      'Bạn có chắc chắn muốn xóa tất cả yêu thích?';

  @override
  String get noFavorites => 'Chưa có yêu thích';

  @override
  String get noFavoritesMessage =>
      'Bắt đầu yêu thích địa điểm và trò chuyện để xem chúng ở đây.';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get searchLocations => 'Tìm kiếm địa điểm...';

  @override
  String get recentSearches => 'Tìm kiếm gần đây';

  @override
  String get noSearchResults => 'Không tìm thấy kết quả';

  @override
  String get noSearchResultsMessage =>
      'Thử từ khóa khác hoặc kiểm tra chính tả.';

  @override
  String get results => 'kết quả';

  @override
  String get result => 'kết quả';

  @override
  String get collections => 'Bộ sưu tập';

  @override
  String get createCollection => 'Tạo bộ sưu tập';

  @override
  String get collectionName => 'Tên bộ sưu tập';

  @override
  String get collectionNameRequired => 'Tên là bắt buộc';

  @override
  String get noCollections => 'Chưa có bộ sưu tập';

  @override
  String get noCollectionsMessage =>
      'Tạo bộ sưu tập đầu tiên để tổ chức địa điểm và trò chuyện.';

  @override
  String get item => 'mục';

  @override
  String get items => 'mục';

  @override
  String get addToCollection => 'Thêm vào bộ sưu tập';

  @override
  String get itemAddedToCollection => 'Đã thêm vào bộ sưu tập';

  @override
  String get createNew => 'Tạo mới';

  @override
  String get noItems => 'Chưa có mục trong bộ sưu tập';

  @override
  String get noItemsMessage =>
      'Thêm địa điểm hoặc trò chuyện vào bộ sưu tập này.';

  @override
  String get deleteCollection => 'Xóa bộ sưu tập';

  @override
  String get deleteCollectionConfirm =>
      'Bạn có chắc chắn muốn xóa bộ sưu tập này? Tất cả các mục sẽ bị xóa.';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get create => 'Tạo';

  @override
  String get color => 'Màu sắc';

  @override
  String get icon => 'Biểu tượng';

  @override
  String get somethingWentWrong => 'Đã xảy ra lỗi';

  @override
  String get close => 'Đóng';

  @override
  String get description => 'Mô tả';

  @override
  String get beforeChrist => 'Trước Công Nguyên';

  @override
  String get unknownPeriod => 'Thời kỳ không xác định';
}
