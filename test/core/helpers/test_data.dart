import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/social/collections_service.dart';
import 'package:ai_map_explainer/core/services/tours/tour_model.dart';
import 'package:ai_map_explainer/core/services/social/favorites_service.dart';

/// Factory functions để tạo test data

/// Tạo mock HistoricalLocation
HistoricalLocation createMockHistoricalLocation({
  String? id,
  String? name,
  double? lat,
  double? lng,
  String? description,
  String? period,
  String? type,
}) {
  return HistoricalLocation(
    id: id ?? 'test_location_1',
    name: name ?? 'Test Location',
    lat: lat ?? 21.0285,
    lng: lng ?? 105.8542,
    description: description ?? 'Test description',
    period: period ?? 'Test period',
    type: type ?? 'Di tích',
  );
}

/// Tạo list mock HistoricalLocations
List<HistoricalLocation> createMockHistoricalLocations({int count = 3}) {
  return List.generate(count, (index) {
    return createMockHistoricalLocation(
      id: 'test_location_$index',
      name: 'Test Location $index',
      lat: 21.0 + (index * 0.01),
      lng: 105.0 + (index * 0.01),
    );
  });
}

/// Tạo mock Collection
Collection createMockCollection({
  String? id,
  String? name,
  String? description,
  String? color,
  String? icon,
  DateTime? createdAt,
  DateTime? updatedAt,
  int? itemCount,
}) {
  final now = DateTime.now();
  return Collection(
    id: id ?? 'test_collection_1',
    name: name ?? 'Test Collection',
    description: description,
    color: color ?? '#2196F3',
    icon: icon ?? 'folder',
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    itemCount: itemCount ?? 0,
  );
}

/// Tạo mock CollectionItem
CollectionItem createMockCollectionItem({
  String? id,
  String? collectionId,
  String? type,
  String? itemId,
  String? title,
  DateTime? addedAt,
  Map<String, dynamic>? metadata,
}) {
  return CollectionItem(
    id: id ?? 'test_item_1',
    collectionId: collectionId ?? 'test_collection_1',
    type: type ?? 'location',
    itemId: itemId ?? 'test_location_1',
    title: title,
    addedAt: addedAt ?? DateTime.now(),
    metadata: metadata,
  );
}

/// Tạo mock Tour
Tour createMockTour({
  String? id,
  String? name,
  String? description,
  List<String>? locationIds,
  String? theme,
  String? color,
  String? icon,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool? isPremade,
  double? estimatedTime,
  double? estimatedDistance,
}) {
  final now = DateTime.now();
  return Tour(
    id: id ?? 'test_tour_1',
    name: name ?? 'Test Tour',
    description: description,
    locationIds: locationIds ?? ['test_location_1', 'test_location_2'],
    theme: theme,
    color: color ?? '#2196F3',
    icon: icon ?? 'route',
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    isPremade: isPremade ?? false,
    estimatedTime: estimatedTime,
    estimatedDistance: estimatedDistance,
  );
}

/// Tạo mock FavoriteItem
FavoriteItem createMockFavoriteItem({
  String? id,
  String? type,
  String? itemId,
  String? title,
  DateTime? createdAt,
  Map<String, dynamic>? metadata,
}) {
  return FavoriteItem(
    id: id ?? 'test_favorite_1',
    type: type ?? 'location',
    itemId: itemId ?? 'test_location_1',
    title: title,
    createdAt: createdAt ?? DateTime.now(),
    metadata: metadata,
  );
}

/// Sample data cho testing
class TestData {
  static List<HistoricalLocation> get sampleLocations => [
        createMockHistoricalLocation(
          id: 'loc_1',
          name: 'Ho Chi Minh Mausoleum',
          lat: 21.0367,
          lng: 105.8342,
          period: 'Modern',
          type: 'Di tích',
        ),
        createMockHistoricalLocation(
          id: 'loc_2',
          name: 'Temple of Literature',
          lat: 21.0267,
          lng: 105.8356,
          period: 'Ancient',
          type: 'Di tích',
        ),
        createMockHistoricalLocation(
          id: 'loc_3',
          name: 'War Remnants Museum',
          lat: 10.7794,
          lng: 106.6927,
          period: 'Modern',
          type: 'Bảo tàng',
        ),
      ];

  static List<Collection> get sampleCollections => [
        createMockCollection(
          id: 'col_1',
          name: 'My Favorites',
          description: 'My favorite locations',
          color: '#2196F3',
        ),
        createMockCollection(
          id: 'col_2',
          name: 'To Visit',
          description: 'Places I want to visit',
          color: '#4CAF50',
        ),
      ];

  static List<Tour> get sampleTours => [
        createMockTour(
          id: 'tour_1',
          name: 'Historical Tour',
          description: 'A tour of historical sites',
          locationIds: ['loc_1', 'loc_2'],
          theme: 'History',
        ),
        createMockTour(
          id: 'tour_2',
          name: 'Cultural Tour',
          description: 'A tour of cultural sites',
          locationIds: ['loc_2', 'loc_3'],
          theme: 'Culture',
        ),
      ];
}
