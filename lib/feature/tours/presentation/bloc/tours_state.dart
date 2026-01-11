import 'package:ai_map_explainer/core/services/tours/tour_model.dart';

/// States cho ToursBloc
abstract class ToursState {}

/// Initial state
class ToursInitial extends ToursState {}

/// Loading state
class ToursLoading extends ToursState {}

/// Tours loaded successfully
class ToursLoaded extends ToursState {
  final List<Tour> tours;

  ToursLoaded(this.tours);
}

/// Single tour loaded
class TourLoaded extends ToursState {
  final Tour tour;

  TourLoaded(this.tour);
}

/// Error state
class ToursError extends ToursState {
  final String message;

  ToursError(this.message);
}
