/*
 * Copyright 2023 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TtsPage extends StatefulWidget {
  const TtsPage({super.key});

  @override
  State<TtsPage> createState() => _TtsPageState();
}

class _TtsPageState extends State<TtsPage> {
  final FlutterTts flutterTts = FlutterTts();
  String ttsState = "stopped";
  String sttState = "done";

  final SpeechToText speechToText = SpeechToText();
  bool? speechAvailable;

  late Future<void> init;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: "Hello, I am ChatGPT!");
    init = () async {
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.autoStopSharedSession(true);
      await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.interruptSpokenAudioAndMixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }();
  }

  Future<void> initSpeechToText() async {
    speechAvailable = await speechToText.initialize(
      options: [
        SpeechToText.androidNoBluetooth,
        SpeechToText.iosNoBluetooth,
      ],
      onStatus: (status) {
        setState(() => sttState = status);
      },
    );
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      controller.text = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: init,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Text("TTS State: $ttsState"),
              Text("STT Available: ${speechAvailable == null ? "Unknown" : speechAvailable! ? "Yes" : "No"}"),
              Text("STT State: $sttState"),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clear(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => ttsState = "playing");
                      await flutterTts.speak(controller.value.text);
                      if (mounted) setState(() => ttsState = "stopped");
                    },
                    child: const Text("Speech"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      var result = await flutterTts.stop();
                      if (mounted && result == 1) {
                        setState(() => ttsState = "stopped");
                      }
                    },
                    child: const Text("Stop"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await initSpeechToText();
                      await speechToText.cancel();
                      var s = await speechToText.listen(
                        onResult: _onSpeechResult,
                        cancelOnError: true,
                        listenFor: const Duration(seconds: 60),
                        pauseFor: const Duration(seconds: 10),
                        listenMode: ListenMode.dictation,
                      );
                      print(s);
                    },
                    child: const Text("Listen"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await speechToText.stop();
                    },
                    child: const Text("Stop"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    speechToText.cancel();
    super.dispose();
  }
}
