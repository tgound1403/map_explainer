/// Interface cho AI service
abstract class AIServiceInterface {
  /// Tạo summary từ input
  Future<String?> summary(String input);

  /// Tìm các thông tin liên quan
  Future<List<String>?> findRelated(String input);

  /// Tạo response từ prompt
  Future<String?> generateResponse(String prompt);
}
