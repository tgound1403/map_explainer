import 'package:json_annotation/json_annotation.dart';

part 'historical_location_model.g.dart';

@JsonSerializable()
class HistoricalLocation {
  const HistoricalLocation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.description,
    required this.period,
    required this.type,
    this.address,
    this.imageUrl,
    this.relatedEvents,
    this.relatedFigures,
    this.year, // Năm lịch sử (để sort timeline)
    this.images, // Danh sách ảnh
    this.videos, // Danh sách video URLs
  });

  factory HistoricalLocation.fromJson(Map<String, dynamic> json) =>
      _$HistoricalLocationFromJson(json);
  
  Map<String, dynamic> toJson() => _$HistoricalLocationToJson(this);

  final String id;
  final String name;
  final double lat;
  final double lng;
  final String description;
  final String period; // Thời kỳ lịch sử (VD: "Thời kỳ phong kiến", "Thời kỳ kháng chiến")
  final String type; // Loại địa điểm (VD: "Di tích", "Bảo tàng", "Địa danh lịch sử")
  final String? address;
  final String? imageUrl; // Ảnh chính (backward compatibility)
  final List<String>? relatedEvents; // Các sự kiện liên quan
  final List<String>? relatedFigures; // Các nhân vật lịch sử liên quan
  final int? year; // Năm lịch sử (để sort timeline)
  final List<String>? images; // Danh sách ảnh
  final List<String>? videos; // Danh sách video URLs
}

@JsonSerializable()
class HistoricalLocations {
  const HistoricalLocations({
    required this.locations,
  });

  factory HistoricalLocations.fromJson(Map<String, dynamic> json) =>
      _$HistoricalLocationsFromJson(json);
  
  Map<String, dynamic> toJson() => _$HistoricalLocationsToJson(this);

  final List<HistoricalLocation> locations;
}
