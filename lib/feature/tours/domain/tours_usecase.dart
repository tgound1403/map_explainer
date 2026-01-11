import 'package:ai_map_explainer/core/services/tours/tour_model.dart';
import 'package:ai_map_explainer/core/services/tours/tour_service.dart';

/// Use case cho tours
class ToursUseCase {
  final TourService _tourService;

  ToursUseCase(this._tourService);

  /// Lấy tất cả tours
  Future<List<Tour>> getAllTours({bool? premadeOnly}) async {
    return await _tourService.getAllTours(premadeOnly: premadeOnly);
  }

  /// Lấy tour theo ID
  Future<Tour?> getTourById(String id) async {
    return await _tourService.getTourById(id);
  }

  /// Tạo tour mới
  Future<Tour?> createTour({
    required String name,
    String? description,
    required List<String> locationIds,
    String? theme,
    String? color,
    String? icon,
    List<TourStop>? stops,
  }) async {
    return await _tourService.createTour(
      name: name,
      description: description,
      locationIds: locationIds,
      theme: theme,
      color: color,
      icon: icon,
      stops: stops,
    );
  }

  /// Cập nhật tour
  Future<bool> updateTour(Tour tour) async {
    return await _tourService.updateTour(tour);
  }

  /// Xóa tour
  Future<bool> deleteTour(String id) async {
    return await _tourService.deleteTour(id);
  }
}
