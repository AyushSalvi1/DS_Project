import 'package:customer_app/features/ai_assistant/presentation/cubit/assistant_cubit.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// شريط الإدخال في شاشة
/// المساعد — نص + زر
/// البحث الصوتي.
class AssistantInputBar extends StatefulWidget {
  const AssistantInputBar({super.key});

  @override
  State<AssistantInputBar> createState() => _AssistantInputBarState();
}

class _AssistantInputBarState extends State<AssistantInputBar> {
  final _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (_) => _setListening(false),
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            _setListening(false);
          }
        },
      );
      if (mounted) setState(() {});
    } catch (_) {
      _speechAvailable = false;
    }
  }

  void _setListening(bool value) {
    if (mounted) setState(() => _listening = value);
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      _showVoiceNotSupported();
      return;
    }

    if (_listening) {
      await _speech.stop();
      _setListening(false);
      return;
    }

    _setListening(true);
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _controller.text = result.recognizedWords;
          _submit(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      localeId: 'en-US',
      cancelOnError: true,
      partialResults: false,
    );
  }

  void _showVoiceNotSupported() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.strings.aiVoiceNotSupported),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submit([String? text]) {
    final query = (text ?? _controller.text).trim();
    if (query.isEmpty) return;

    _controller.clear();
    context.read<AssistantCubit>().ask(query);
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final strings = context.strings;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: brand.surface,
        border: Border(
          top: BorderSide(color: brand.textSecondary.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر الصوت.
            IconButton(
              onPressed: _toggleListening,
              icon: Icon(
                _listening ? Icons.mic : Icons.mic_none,
                color: _listening ? Colors.red : brand.accent,
              ),
              tooltip: _listening
                  ? strings.aiListening
                  : strings.aiTapToSpeak,
            ),

            // حقل النص.
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: strings.aiAssistantHint,
                  hintStyle: TextStyle(color: brand.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: brand.primaryBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
              ),
            ),

            const SizedBox(width: 4),

            // زر الإرسال.
            IconButton(
              onPressed: () => _submit(),
              icon: Icon(Icons.send, color: brand.accent),
              tooltip: strings.aiSend,
            ),
          ],
        ),
      ),
    );
  }
}
