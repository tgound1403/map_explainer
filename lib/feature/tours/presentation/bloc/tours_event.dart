import 'package:ai_map_explainer/core/services/tours/tour_model.dart';

/// Events cho ToursBloc
abstract class ToursEvent {}

/// Load tất cả tours
class LoadTours extends ToursEvent {
  final bool? premadeOnly;

  LoadTours({this.premadeOnly});
}

/// Load tour theo ID
class LoadTourById extends ToursEvent {
  final String id;

  LoadTourById(this.id);
}

/// Tạo tour mới
class CreateTour extends ToursEvent {
  final String name;
  final String? description;
  final List<String> locationIds;
  final String? theme;
  final String? color;
  final String? icon;
  final List<TourStop>? stops;

  CreateTour({
    required this.name,
    this.description,
    required this.locationIds,
    this.theme,
    this.color,
    this.icon,
    this.stops,
  });
}

/// Cập nhật tour
class UpdateTour extends ToursEvent {
  final Tour tour;

  UpdateTour(this.tour);
}

/// Xóa tour
class DeleteTour extends ToursEvent {
  final String id;

  DeleteTour(this.id);
}
