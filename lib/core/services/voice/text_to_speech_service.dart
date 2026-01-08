import 'package:flutter_tts/flutter_tts.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Service để đọc text thành giọng nói (Text-to-Speech)
class TextToSpeechService {
  static final TextToSpeechService instance = TextToSpeechService._internal();
  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;

  /// Khởi tạo TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set language và voice
      await _flutterTts.setLanguage("vi-VN"); // Default Vietnamese
      
      // Set speech rate (0.0 - 1.0)
      await _flutterTts.setSpeechRate(0.5);
      
      // Set volume (0.0 - 1.0)
      await _flutterTts.setVolume(1.0);
      
      // Set pitch (0.5 - 2.0)
      await _flutterTts.setPitch(1.0);

      // Set completion handler
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
      });

      // Set error handler
      _flutterTts.setErrorHandler((msg) {
        Logger.e('TTS Error: $msg');
        _isSpeaking = false;
        _isPaused = false;
      });

      _isInitialized = true;
      Logger.i('TextToSpeechService initialized');
    } catch (e, st) {
      Logger.e('Error initializing TextToSpeechService: $e', stackTrace: st);
      _isInitialized = false;
    }
  }

  /// Set language dựa trên LocaleProvider
  Future<void> setLanguage(String languageCode) async {
    try {
      String ttsLanguage;
      switch (languageCode) {
        case 'vi':
          ttsLanguage = 'vi-VN';
          break;
        case 'en':
          ttsLanguage = 'en-US';
          break;
        default:
          ttsLanguage = 'vi-VN';
      }
      await _flutterTts.setLanguage(ttsLanguage);
      Logger.i('TTS language set to: $ttsLanguage');
    } catch (e) {
      Logger.e('Error setting TTS language: $e');
    }
  }

  /// Đọc text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) {
      Logger.w('TTS: Empty text provided');
      return;
    }

    try {
      // Clean text: remove markdown, special characters
      final cleanText = _cleanText(text);
      
      await _flutterTts.speak(cleanText);
      _isSpeaking = true;
      _isPaused = false;
      Logger.i('TTS: Speaking text (${cleanText.length} chars)');
    } catch (e, st) {
      Logger.e('Error speaking text: $e', stackTrace: st);
      _isSpeaking = false;
    }
  }

  /// Dừng đọc
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _isPaused = false;
      Logger.i('TTS: Stopped');
    } catch (e) {
      Logger.e('Error stopping TTS: $e');
    }
  }

  /// Tạm dừng đọc
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isPaused = true;
      Logger.i('TTS: Paused');
    } catch (e) {
      Logger.e('Error pausing TTS: $e');
    }
  }

  /// Tiếp tục đọc
  Future<void> resume() async {
    // FlutterTts không có resume, cần implement custom
    // Tạm thời không hỗ trợ resume
    Logger.w('TTS: Resume not supported, use speak() instead');
  }

  /// Clean text: remove markdown, URLs, special formatting
  String _cleanText(String text) {
    // Remove markdown links [text](url) -> text
    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');
    
    // Remove markdown bold/italic **text** -> text
    text = text.replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1');
    
    // Remove URLs
    text = text.replaceAll(RegExp(r'https?://[^\s]+'), '');
    
    // Remove markdown headers # ## ###
    text = text.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    
    // Remove extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    text = text.trim();
    
    return text;
  }

  /// Dispose resources
  void dispose() {
    _flutterTts.stop();
    _isSpeaking = false;
    _isPaused = false;
  }
}
