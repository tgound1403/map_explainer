import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/voice/text_to_speech_service.dart';
// TODO: Uncomment after running flutter gen-l10n
// import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// Button để play/pause Text-to-Speech
class TTSButton extends StatefulWidget {
  final String text;
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;

  const TTSButton({
    super.key,
    required this.text,
    this.iconColor,
    this.iconSize,
    this.tooltip,
  });

  @override
  State<TTSButton> createState() => _TTSButtonState();
}

class _TTSButtonState extends State<TTSButton> {
  final _ttsService = TextToSpeechService.instance;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _checkSpeakingStatus();
  }

  void _checkSpeakingStatus() {
    // Check status periodically
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isSpeaking = _ttsService.isSpeaking;
        });
        if (_isSpeaking) {
          _checkSpeakingStatus();
        }
      }
    });
  }

  Future<void> _toggleTTS() async {
    if (_isSpeaking) {
      await _ttsService.stop();
    } else {
      await _ttsService.speak(widget.text);
    }
    if (mounted) {
      setState(() {
        _isSpeaking = _ttsService.isSpeaking;
      });
      if (_isSpeaking) {
        _checkSpeakingStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Uncomment after running flutter gen-l10n
    // final l10n = AppLocalizations.of(context);
    final tooltipText = widget.tooltip ?? 
        (_isSpeaking 
            ? 'Dừng đọc' // l10n?.stopReading ?? 'Dừng đọc'
            : 'Đọc to'); // l10n?.readAloud ?? 'Đọc to'

    return IconButton(
      icon: Icon(
        _isSpeaking ? Icons.stop_circle : Icons.volume_up,
        color: widget.iconColor ?? Theme.of(context).iconTheme.color,
        size: widget.iconSize ?? 24,
      ),
      tooltip: tooltipText,
      onPressed: _toggleTTS,
    );
  }

  @override
  void dispose() {
    // Don't stop TTS on dispose, let user control it
    super.dispose();
  }
}
