/// Interface cho Voice/Text-to-Speech service
abstract class VoiceServiceInterface {
  /// Đọc text thành giọng nói
  Future<void> speak(String text);

  /// Dừng đọc
  Future<void> stop();

  /// Tạm dừng đọc
  Future<void> pause();

  /// Tiếp tục đọc
  Future<void> resume();

  /// Kiểm tra xem đang đọc không
  bool get isSpeaking;

  /// Set language
  Future<void> setLanguage(String languageCode);
}
