import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';

/// Model cho Tour
class Tour {
  final String id;
  final String name;
  final String? description;
  final List<String> locationIds; // IDs của các địa điểm trong tour
  final List<HistoricalLocation>? locations; // Full location objects (optional, for convenience)
  final String? theme; // Chủ đề: "Kháng chiến", "Văn hóa", "Kiến trúc", etc.
  final String? color; // Hex color code
  final String? icon; // Icon name
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPremade; // Tour có sẵn hay user tạo
  final double? estimatedTime; // Thời gian ước tính (giờ)
  final double? estimatedDistance; // Khoảng cách ước tính (km)
  final List<TourStop>? stops; // Chi tiết từng điểm dừng

  Tour({
    required this.id,
    required this.name,
    this.description,
    required this.locationIds,
    this.locations,
    this.theme,
    this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.isPremade = false,
    this.estimatedTime,
    this.estimatedDistance,
    this.stops,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'locationIds': locationIds,
        'theme': theme,
        'color': color,
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isPremade': isPremade,
        'estimatedTime': estimatedTime,
        'estimatedDistance': estimatedDistance,
        'stops': stops?.map((s) => s.toJson()).toList(),
      };

  factory Tour.fromJson(Map<String, dynamic> json) {
    // Helper để convert Map<dynamic, dynamic> thành Map<String, dynamic>
    Map<String, dynamic>? _convertMap(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    return Tour(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      locationIds: List<String>.from(json['locationIds'] as List),
      theme: json['theme'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPremade: json['isPremade'] as bool? ?? false,
      estimatedTime: (json['estimatedTime'] as num?)?.toDouble(),
      estimatedDistance: (json['estimatedDistance'] as num?)?.toDouble(),
      stops: json['stops'] != null
          ? (json['stops'] as List)
              .map((s) => TourStop.fromJson(_convertMap(s)!))
              .toList()
          : null,
    );
  }

  Tour copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? locationIds,
    List<HistoricalLocation>? locations,
    String? theme,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPremade,
    double? estimatedTime,
    double? estimatedDistance,
    List<TourStop>? stops,
  }) {
    return Tour(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      locationIds: locationIds ?? this.locationIds,
      locations: locations ?? this.locations,
      theme: theme ?? this.theme,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPremade: isPremade ?? this.isPremade,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      stops: stops ?? this.stops,
    );
  }
}

/// Model cho Tour Stop (điểm dừng trong tour)
class TourStop {
  final String locationId;
  final int order; // Thứ tự trong tour
  final String? note; // Ghi chú cho điểm dừng này
  final double? estimatedDuration; // Thời gian ước tính tại điểm này (phút)

  TourStop({
    required this.locationId,
    required this.order,
    this.note,
    this.estimatedDuration,
  });

  Map<String, dynamic> toJson() => {
        'locationId': locationId,
        'order': order,
        'note': note,
        'estimatedDuration': estimatedDuration,
      };

  factory TourStop.fromJson(Map<String, dynamic> json) => TourStop(
        locationId: json['locationId'] as String,
        order: json['order'] as int,
        note: json['note'] as String?,
        estimatedDuration: (json['estimatedDuration'] as num?)?.toDouble(),
      );

  TourStop copyWith({
    String? locationId,
    int? order,
    String? note,
    double? estimatedDuration,
  }) {
    return TourStop(
      locationId: locationId ?? this.locationId,
      order: order ?? this.order,
      note: note ?? this.note,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }
}
