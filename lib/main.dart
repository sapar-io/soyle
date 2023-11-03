import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:soyle/services/gpt.dart';
import 'package:soyle/services/permission_service.dart';
import 'package:soyle/services/speech_recognize.dart';
import 'package:soyle/services/storage_service.dart';
import 'package:soyle/services/syntez_service.dart';

void main() {
  AudioLogger.logLevel = AudioLogLevel.info;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Record _record = Record();

  final TextEditingController textEditingController = TextEditingController();
  bool _isRecording = false;
  Timer? _timer;

  // Functions
  startRecording() async {
    // final isPermitted = (await PermissionManagement.recordingPermission()) && (await PermissionManagement.storagePermission());
    final isPermitted = await PermissionManagement.recordingPermission();
    if (!isPermitted) return;
    if (!(await _record.hasPermission())) return;

    final voiceDirPath = await StorageManagement.getAudioDir;
    final voiceFilePath = StorageManagement.createRecordAudioPath(
        dirPath: voiceDirPath, fileName: 'audio_message');

    await _record.start(
      path: voiceFilePath,
      encoder: AudioEncoder.pcm16bit,
      samplingRate: 48000,
    );
    setState(() => _isRecording = true);

    _timer = Timer(const Duration(seconds: 20), () {
      stopRecording();
    });
  }

  stopRecording() async {
    String? audioFilePath;

    if (await _record.isRecording()) {
      audioFilePath = await _record.stop();
      _timer?.cancel();
    }

    setState(() => _isRecording = false);
    if (audioFilePath != null) {
      final File audioFile = File(audioFilePath);
      final String speechText =
          await SpeechRecognize.getText(audioFile, 'ru-RU');
      final answer = await GPT.generateText(speechText);
      textEditingController.text = answer;
      final newAudio = await SyntezService.getAudio(answer, 'ru-RU', 'alena');
      _audioPlayer.play(DeviceFileSource(newAudio.path));
    }
  }

  _makeAudio() async {
    final newAudio = await SyntezService.getAudio(
        "Хвост у шмяка дрожал от восторга . Сегодня особенный день! - обьявил котенок своим одноклассникам. - Меня забирают из школы пораньше!",
        'ru-RU',
        'alena');
    _audioPlayer.play(DeviceFileSource(newAudio.path));
  }

  @override
  void initState() {
    super.initState();
    _makeAudio();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Recognition'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Результат распознавания речи',
                ),
                maxLines: null,
              ),
            ),
            ElevatedButton(
              onPressed: _isRecording ? stopRecording : startRecording,
              child: Text(_isRecording ? 'Остановить' : 'Начать запись'),
            ),
          ],
        ),
      ),
    );
  }
}
