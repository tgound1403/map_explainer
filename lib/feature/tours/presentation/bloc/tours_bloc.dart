import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:ai_map_explainer/feature/tours/domain/tours_usecase.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_event.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_state.dart';

/// BLoC để quản lý tours
class ToursBloc extends Bloc<ToursEvent, ToursState> {
  final ToursUseCase _toursUseCase;

  ToursBloc(this._toursUseCase) : super(ToursInitial()) {
    on<LoadTours>(_onLoadTours);
    on<LoadTourById>(_onLoadTourById);
    on<CreateTour>(_onCreateTour);
    on<UpdateTour>(_onUpdateTour);
    on<DeleteTour>(_onDeleteTour);
  }

  Future<void> _onLoadTours(LoadTours event, Emitter<ToursState> emit) async {
    emit(ToursLoading());
    try {
      final tours = await _toursUseCase.getAllTours(premadeOnly: event.premadeOnly);
      emit(ToursLoaded(tours));
    } catch (e, st) {
      Logger.e('Error loading tours: $e', stackTrace: st);
      emit(ToursError('Không thể tải danh sách tours'));
    }
  }

  Future<void> _onLoadTourById(LoadTourById event, Emitter<ToursState> emit) async {
    emit(ToursLoading());
    try {
      final tour = await _toursUseCase.getTourById(event.id);
      if (tour != null) {
        emit(TourLoaded(tour));
      } else {
        emit(ToursError('Không tìm thấy tour'));
      }
    } catch (e, st) {
      Logger.e('Error loading tour: $e', stackTrace: st);
      emit(ToursError('Không thể tải tour'));
    }
  }

  Future<void> _onCreateTour(CreateTour event, Emitter<ToursState> emit) async {
    try {
      final tour = await _toursUseCase.createTour(
        name: event.name,
        description: event.description,
        locationIds: event.locationIds,
        theme: event.theme,
        color: event.color,
        icon: event.icon,
        stops: event.stops,
      );

      if (tour != null) {
        // Reload tours
        final tours = await _toursUseCase.getAllTours();
        emit(ToursLoaded(tours));
      } else {
        emit(ToursError('Không thể tạo tour'));
      }
    } catch (e, st) {
      Logger.e('Error creating tour: $e', stackTrace: st);
      emit(ToursError('Không thể tạo tour'));
    }
  }

  Future<void> _onUpdateTour(UpdateTour event, Emitter<ToursState> emit) async {
    try {
      final success = await _toursUseCase.updateTour(event.tour);
      if (success) {
        // Reload tours
        final tours = await _toursUseCase.getAllTours();
        emit(ToursLoaded(tours));
      } else {
        emit(ToursError('Không thể cập nhật tour'));
      }
    } catch (e, st) {
      Logger.e('Error updating tour: $e', stackTrace: st);
      emit(ToursError('Không thể cập nhật tour'));
    }
  }

  Future<void> _onDeleteTour(DeleteTour event, Emitter<ToursState> emit) async {
    try {
      final success = await _toursUseCase.deleteTour(event.id);
      if (success) {
        // Reload tours
        final tours = await _toursUseCase.getAllTours();
        emit(ToursLoaded(tours));
      } else {
        emit(ToursError('Không thể xóa tour'));
      }
    } catch (e, st) {
      Logger.e('Error deleting tour: $e', stackTrace: st);
      emit(ToursError('Không thể xóa tour'));
    }
  }
}
