import 'dart:math' as math;
import 'package:hive/hive.dart';
import 'package:ai_map_explainer/core/services/cache/cache_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/tours/tour_model.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Service để quản lý tours
class TourService {
  static final TourService instance = TourService._internal();
  TourService._internal();

  static const String _toursBox = 'tours';
  bool _initialized = false;
  final HistoricalLocationService _locationService = HistoricalLocationService.instance;

  /// Khởi tạo tours box
  Future<void> _init() async {
    if (_initialized) return;
    try {
      await CacheService.instance.init();
      await Hive.openBox(_toursBox);
      _initialized = true;
      
      // Tạo premade tours nếu chưa có
      await _createPremadeToursIfNeeded();
    } catch (e, st) {
      Logger.e('Error initializing tour service: $e', stackTrace: st);
    }
  }

  /// Helper để convert Map từ Hive sang Map<String, dynamic>
  Map<String, dynamic> _convertHiveMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item;
    }
    if (item is Map) {
      return Map<String, dynamic>.from(item);
    }
    throw Exception('Invalid item type: ${item.runtimeType}');
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
    try {
      await _init();
      final box = Hive.box(_toursBox);

      final tour = Tour(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        locationIds: locationIds,
        theme: theme,
        color: color,
        icon: icon,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPremade: false,
        stops: stops ?? _createStopsFromLocationIds(locationIds),
      );

      // Calculate estimated time and distance
      final tourWithMetrics = await _calculateTourMetrics(tour);

      await box.put(tour.id, tourWithMetrics.toJson());
      Logger.i('Tour created: $name');
      return tourWithMetrics;
    } catch (e, st) {
      Logger.e('Error creating tour: $e', stackTrace: st);
      return null;
    }
  }

  /// Lấy tất cả tours
  Future<List<Tour>> getAllTours({bool? premadeOnly}) async {
    try {
      await _init();
      final box = Hive.box(_toursBox);

      final tours = <Tour>[];
      for (final item in box.values.cast<dynamic>()) {
        try {
          final tour = Tour.fromJson(_convertHiveMap(item));
          if (premadeOnly == null || tour.isPremade == premadeOnly) {
            tours.add(tour);
          }
        } catch (e) {
          Logger.e('Error parsing tour: $e');
          continue;
        }
      }

      // Sort: premade first, then by updatedAt
      tours.sort((a, b) {
        if (a.isPremade != b.isPremade) {
          return a.isPremade ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });

      return tours;
    } catch (e, st) {
      Logger.e('Error getting tours: $e', stackTrace: st);
      return [];
    }
  }

  /// Lấy tour theo ID
  Future<Tour?> getTourById(String id) async {
    try {
      await _init();
      final box = Hive.box(_toursBox);
      final item = box.get(id);
      if (item == null) return null;
      return Tour.fromJson(_convertHiveMap(item));
    } catch (e, st) {
      Logger.e('Error getting tour: $e', stackTrace: st);
      return null;
    }
  }

  /// Cập nhật tour
  Future<bool> updateTour(Tour tour) async {
    try {
      await _init();
      final box = Hive.box(_toursBox);

      final updatedTour = tour.copyWith(
        updatedAt: DateTime.now(),
      );

      // Recalculate metrics if locationIds changed
      final tourWithMetrics = await _calculateTourMetrics(updatedTour);

      await box.put(tour.id, tourWithMetrics.toJson());
      Logger.i('Tour updated: ${tour.name}');
      return true;
    } catch (e, st) {
      Logger.e('Error updating tour: $e', stackTrace: st);
      return false;
    }
  }

  /// Xóa tour
  Future<bool> deleteTour(String id) async {
    try {
      await _init();
      final box = Hive.box(_toursBox);
      await box.delete(id);
      Logger.i('Tour deleted: $id');
      return true;
    } catch (e, st) {
      Logger.e('Error deleting tour: $e', stackTrace: st);
      return false;
    }
  }

  /// Tính toán metrics cho tour (time, distance)
  Future<Tour> _calculateTourMetrics(Tour tour) async {
    try {
      final allLocations = await _locationService.loadHistoricalLocations();
      final tourLocations = tour.locationIds
          .map((id) => allLocations.firstWhere(
                (loc) => loc.id == id,
                orElse: () => throw Exception('Location not found: $id'),
              ))
          .toList();

      if (tourLocations.isEmpty) {
        return tour;
      }

      // Calculate total distance
      double totalDistance = 0.0;
      for (int i = 0; i < tourLocations.length - 1; i++) {
        final distance = _calculateDistance(
          tourLocations[i].lat,
          tourLocations[i].lng,
          tourLocations[i + 1].lat,
          tourLocations[i + 1].lng,
        );
        totalDistance += distance;
      }

      // Estimate time: 30 min per location + travel time (assuming 30 km/h average)
      final locationTime = tourLocations.length * 0.5; // 30 min per location
      final travelTime = totalDistance / 30.0; // hours
      final totalTime = locationTime + travelTime;

      return tour.copyWith(
        estimatedTime: totalTime,
        estimatedDistance: totalDistance,
        locations: tourLocations,
      );
    } catch (e, st) {
      Logger.e('Error calculating tour metrics: $e', stackTrace: st);
      return tour;
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  /// Tạo stops từ locationIds
  List<TourStop> _createStopsFromLocationIds(List<String> locationIds) {
    return locationIds
        .asMap()
        .entries
        .map((entry) => TourStop(
              locationId: entry.value,
              order: entry.key + 1,
            ))
        .toList();
  }

  /// Tạo premade tours nếu chưa có
  Future<void> _createPremadeToursIfNeeded() async {
    try {
      final box = Hive.box(_toursBox);
      
      // Check if premade tours already exist
      final hasPremade = box.values.any((item) {
        try {
          final tour = Tour.fromJson(_convertHiveMap(item));
          return tour.isPremade;
        } catch (e) {
          return false;
        }
      });

      if (hasPremade) {
        Logger.d('Premade tours already exist');
        return;
      }

      // Load all locations
      final allLocations = await _locationService.loadHistoricalLocations();
      if (allLocations.isEmpty) {
        Logger.w('No locations available for premade tours');
        return;
      }

      // Create premade tours
      final premadeTours = await _generatePremadeTours(allLocations);
      
      for (final tour in premadeTours) {
        final tourWithMetrics = await _calculateTourMetrics(tour);
        await box.put(tourWithMetrics.id, tourWithMetrics.toJson());
      }

      Logger.i('Created ${premadeTours.length} premade tours');
    } catch (e, st) {
      Logger.e('Error creating premade tours: $e', stackTrace: st);
    }
  }

  /// Generate premade tours based on themes
  Future<List<Tour>> _generatePremadeTours(List<HistoricalLocation> allLocations) async {
    final tours = <Tour>[];

    // Tour 1: Kháng chiến chống Mỹ
    final khangChienLocations = allLocations
        .where((loc) =>
            (loc.period.toLowerCase().contains('kháng chiến') ||
                loc.period.toLowerCase().contains('chống mỹ') ||
                loc.name.toLowerCase().contains('chiến') ||
                loc.name.toLowerCase().contains('kháng')))
        .take(5)
        .map((loc) => loc.id)
        .toList();

    if (khangChienLocations.isNotEmpty) {
      tours.add(Tour(
        id: 'premade_khang_chien',
        name: 'Cuộc Kháng Chiến Chống Mỹ',
        description: 'Khám phá các địa điểm lịch sử liên quan đến cuộc kháng chiến chống Mỹ cứu nước',
        locationIds: khangChienLocations,
        theme: 'Kháng chiến',
        color: '#E53935',
        icon: 'flag',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPremade: true,
      ));
    }

    // Tour 2: Di tích văn hóa
    final vanHoaLocations = allLocations
        .where((loc) =>
            (loc.type.toLowerCase().contains('di tích') ||
                loc.type.toLowerCase().contains('bảo tàng') ||
                loc.type.toLowerCase().contains('đền') ||
                loc.type.toLowerCase().contains('chùa')))
        .take(5)
        .map((loc) => loc.id)
        .toList();

    if (vanHoaLocations.isNotEmpty) {
      tours.add(Tour(
        id: 'premade_van_hoa',
        name: 'Di Tích Văn Hóa',
        description: 'Tham quan các di tích văn hóa, bảo tàng, đền chùa lịch sử',
        locationIds: vanHoaLocations,
        theme: 'Văn hóa',
        color: '#1976D2',
        icon: 'museum',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPremade: true,
      ));
    }

    // Tour 3: Thành phố Hồ Chí Minh
    final hcmcLocations = allLocations
        .where((loc) {
          final address = loc.address?.toLowerCase() ?? '';
          return address.contains('hồ chí minh') ||
              address.contains('sài gòn') ||
              address.contains('tp.hcm');
        })
        .take(5)
        .map((loc) => loc.id)
        .toList();

    if (hcmcLocations.isNotEmpty) {
      tours.add(Tour(
        id: 'premade_hcmc',
        name: 'Thành Phố Hồ Chí Minh',
        description: 'Khám phá các địa điểm lịch sử tại Thành phố Hồ Chí Minh',
        locationIds: hcmcLocations,
        theme: 'Địa phương',
        color: '#F57C00',
        icon: 'location_city',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPremade: true,
      ));
    }

    return tours;
  }
}
