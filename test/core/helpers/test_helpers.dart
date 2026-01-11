import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:ai_map_explainer/core/services/cache/cache_service.dart';

/// Setup Hive cho testing
/// Sử dụng in-memory storage cho tests
Future<void> setupHiveForTesting() async {
  // Initialize Flutter binding
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Use in-memory storage for tests
  // Create a temporary directory in system temp
  final testPath = '${Directory.systemTemp.path}/test_hive_${DateTime.now().millisecondsSinceEpoch}';
  final dir = Directory(testPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  
  // Init Hive với test path
  Hive.init(testPath);
  
  // Open boxes that services need (before CacheService.init tries to use path_provider)
  try {
    await Hive.openBox('historical_locations');
    await Hive.openBox('ai_responses');
    await Hive.openBox('wikipedia_cache');
    await Hive.openBox('collections');
    await Hive.openBox('collection_items');
    await Hive.openBox('favorites');
    await Hive.openBox('tours');
  } catch (e) {
    // Boxes might already be open, ignore
  }
  
  // Note: CacheService.init() will fail because it uses path_provider,
  // but that's OK for tests since we've already opened the boxes
}

/// Cleanup Hive sau tests
Future<void> tearDownHiveForTesting() async {
  try {
    // Close all boxes
    await Hive.close();
    
    // Cleanup test directories (clean up all test_hive_* directories)
    final tempDir = Directory.systemTemp;
    final testDirs = tempDir.listSync()
        .whereType<Directory>()
        .where((dir) => dir.path.contains('test_hive_'));
    
    for (final dir in testDirs) {
      try {
        await dir.delete(recursive: true);
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  } catch (e) {
    // Ignore errors during cleanup
  }
}

/// Reset Hive boxes (xóa tất cả data)
Future<void> resetHiveBoxes() async {
  try {
    // Clear all boxes - this ensures clean state for each test
    final boxNames = [
      'collections',
      'collection_items',
      'favorites',
      'tours',
      'historical_locations',
      'ai_responses',
      'wikipedia_cache',
    ];
    
    for (final boxName in boxNames) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          await box.clear();
        }
      } catch (e) {
        // Box might not be open, try to open it first
        try {
          final box = await Hive.openBox(boxName);
          await box.clear();
        } catch (e2) {
          // Ignore if can't open/clear
        }
      }
    }
    
    // Small delay to ensure all clears are complete
    await Future.delayed(const Duration(milliseconds: 50));
  } catch (e) {
    // If clearing fails, try to reinitialize
    try {
      await Hive.close();
      await setupHiveForTesting();
    } catch (e2) {
      // Ignore errors
    }
  }
}
