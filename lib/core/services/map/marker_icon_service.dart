import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';

/// Service để tạo custom marker icons dựa trên loại địa điểm
class MarkerIconService {
  static final Map<String, IconData> _typeIconMap = {
    'Di tích': Icons.place,
    'Di tích lịch sử': Icons.place,
    'Bảo tàng': Icons.museum,
    'Địa danh lịch sử': Icons.history_edu,
    'Đền': Icons.temple_buddhist,
    'Chùa': Icons.temple_hindu,
    'Nhà thờ': Icons.church,
    'Lăng mộ': Icons.account_tree,
    'Phố cổ': Icons.location_city,
    'Cổng thành': Icons.castle,
    'Cung điện': Icons.business,
    'Thành cổ': Icons.fort,
    'Đài tưởng niệm': Icons.flag,
    'Công viên lịch sử': Icons.park,
    'Khu di tích': Icons.place,
  };

  static final Map<String, Color> _typeColorMap = {
    'Di tích': Colors.amber.shade700,
    'Bảo tàng': Colors.blue.shade700,
    'Địa danh lịch sử': Colors.red.shade700,
    'Đền': Colors.orange.shade700,
    'Chùa': Colors.purple.shade700,
    'Nhà thờ': Colors.cyan.shade700,
    'Lăng mộ': Colors.brown.shade700,
    'Phố cổ': Colors.teal.shade700,
    'Cổng thành': Colors.grey.shade700,
    'Cung điện': Colors.indigo.shade700,
    'Thành cổ': Colors.deepOrange.shade700,
    'Đài tưởng niệm': Colors.pink.shade700,
    'Công viên lịch sử': Colors.green.shade700,
    'Khu di tích': Colors.amber.shade800,
  };

  /// Cache cho các icons đã tạo
  static final Map<String, BitmapDescriptor> _iconCache = {};

  /// Lấy icon cho loại địa điểm
  static IconData? getIconForType(String type) {
    return _typeIconMap[type] ?? Icons.place;
  }

  /// Lấy màu cho loại địa điểm
  static Color getColorForType(String type) {
    return _typeColorMap[type] ?? Colors.red.shade700;
  }

  /// Tạo custom marker icon từ IconData
  static Future<BitmapDescriptor> createCustomIcon({
    required IconData iconData,
    required Color color,
    double size = 48.0,
    Color? backgroundColor,
    bool isSelected = false,
  }) async {
    final cacheKey = '${iconData.codePoint}_${color.value}_${size}_${isSelected}';
    
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final sizeWithPadding = size + 8;

    // Vẽ background circle
    final bgColor = backgroundColor ?? (isSelected ? Colors.orange : Colors.white);
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(sizeWithPadding / 2, sizeWithPadding / 2),
      sizeWithPadding / 2,
      bgPaint,
    );

    // Vẽ border
    final borderPaint = Paint()
      ..color = isSelected ? Colors.orange.shade800 : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 2.0;
    canvas.drawCircle(
      Offset(sizeWithPadding / 2, sizeWithPadding / 2),
      sizeWithPadding / 2 - 1,
      borderPaint,
    );

    // Vẽ icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: size * 0.6,
          fontFamily: iconData.fontFamily,
          color: color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (sizeWithPadding - textPainter.width) / 2,
        (sizeWithPadding - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      sizeWithPadding.toInt(),
      sizeWithPadding.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }

    final bitmapDescriptor = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
    _iconCache[cacheKey] = bitmapDescriptor;
    return bitmapDescriptor;
  }

  /// Tạo marker icon cho historical location
  static Future<BitmapDescriptor> getMarkerIconForLocation(
    HistoricalLocation location, {
    bool isSelected = false,
  }) async {
    final iconData = getIconForType(location.type) ?? Icons.place;
    final color = getColorForType(location.type);
    
    return createCustomIcon(
      iconData: iconData,
      color: color,
      isSelected: isSelected,
    );
  }

  /// Tạo cluster marker icon
  static Future<BitmapDescriptor> getClusterIcon(int count) async {
    final cacheKey = 'cluster_$count';
    
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    const size = 56.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Vẽ background circle với gradient effect
    final bgPaint = Paint()
      ..color = Colors.purple.shade600
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      bgPaint,
    );

    // Vẽ border
    final borderPaint = Paint()
      ..color = Colors.purple.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 1.5,
      borderPaint,
    );

    // Vẽ số lượng
    final textPainter = TextPainter(
      text: TextSpan(
        text: count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }

    final bitmapDescriptor = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
    _iconCache[cacheKey] = bitmapDescriptor;
    return bitmapDescriptor;
  }

  /// Clear icon cache
  static void clearCache() {
    _iconCache.clear();
  }
}
