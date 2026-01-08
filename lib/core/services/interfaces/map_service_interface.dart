import 'package:geolocator/geolocator.dart';

/// Interface cho Map service
abstract class MapServiceInterface {
  /// Lấy vị trí hiện tại
  Future<Position> getCurrentPosition();

  /// Lấy historical locations
  Future<List<dynamic>> getHistoricalLocations();

  /// Lấy thông tin địa điểm từ coordinates
  Future<Map<String, dynamic>> getLocationInfo(double lat, double lng);
}
