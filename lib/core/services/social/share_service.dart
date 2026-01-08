import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Service để share content
class ShareService {
  static final ShareService instance = ShareService._internal();
  ShareService._internal();

  /// Share location
  Future<bool> shareLocation(HistoricalLocation location) async {
    try {
      final text = _buildLocationShareText(location);
      await Share.share(
        text,
        subject: location.name,
      );
      Logger.i('Location shared: ${location.name}');
      return true;
    } catch (e, st) {
      Logger.e('Error sharing location: $e', stackTrace: st);
      return false;
    }
  }

  /// Share location với Google Maps link
  Future<bool> shareLocationWithMap(HistoricalLocation location) async {
    try {
      final text = _buildLocationShareText(location);
      final mapUrl = 'https://www.google.com/maps?q=${location.lat},${location.lng}';
      final fullText = '$text\n\n📍 Xem trên bản đồ: $mapUrl';
      
      await Share.share(
        fullText,
        subject: location.name,
      );
      Logger.i('Location shared with map: ${location.name}');
      return true;
    } catch (e, st) {
      Logger.e('Error sharing location with map: $e', stackTrace: st);
      return false;
    }
  }

  /// Share chat
  Future<bool> shareChat({
    required String title,
    required String content,
    String? chatId,
  }) async {
    try {
      final text = _buildChatShareText(title, content);
      await Share.share(
        text,
        subject: title,
      );
      Logger.i('Chat shared: $title');
      return true;
    } catch (e, st) {
      Logger.e('Error sharing chat: $e', stackTrace: st);
      return false;
    }
  }

  /// Share text content
  Future<bool> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
      Logger.i('Text shared');
      return true;
    } catch (e, st) {
      Logger.e('Error sharing text: $e', stackTrace: st);
      return false;
    }
  }

  /// Mở Google Maps với location
  Future<bool> openInGoogleMaps({
    required double lat,
    required double lng,
    String? label,
  }) async {
    try {
      final url = Uri.parse(
        'https://www.google.com/maps?q=$lat,$lng${label != null ? '&label=$label' : ''}',
      );
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        Logger.i('Opened in Google Maps: $lat, $lng');
        return true;
      } else {
        Logger.w('Cannot launch Google Maps URL');
        return false;
      }
    } catch (e, st) {
      Logger.e('Error opening Google Maps: $e', stackTrace: st);
      return false;
    }
  }

  String _buildLocationShareText(HistoricalLocation location) {
    final buffer = StringBuffer();
    buffer.writeln('📍 ${location.name}');
    buffer.writeln();
    
    if (location.description.isNotEmpty) {
      buffer.writeln(location.description);
      buffer.writeln();
    }
    
    buffer.writeln('📅 Thời kỳ: ${location.period}');
    buffer.writeln('🏛️ Loại: ${location.type}');
    
    if (location.address != null && location.address!.isNotEmpty) {
      buffer.writeln('📍 Địa chỉ: ${location.address}');
    }
    
    buffer.writeln();
    buffer.writeln('Khám phá thêm với AI Map Explainer!');
    
    return buffer.toString();
  }

  String _buildChatShareText(String title, String content) {
    final buffer = StringBuffer();
    buffer.writeln('💬 $title');
    buffer.writeln();
    buffer.writeln(content);
    buffer.writeln();
    buffer.writeln('Từ AI Map Explainer');
    return buffer.toString();
  }
}
