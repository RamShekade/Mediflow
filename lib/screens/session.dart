// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:record/record.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AudioRecorderPage extends StatefulWidget {
//   @override
//   _AudioRecorderPageState createState() => _AudioRecorderPageState();
// }

// class _AudioRecorderPageState extends State<AudioRecorderPage> {
//   final Record _record = Record();
//   final AudioPlayer _player = AudioPlayer();
//   String? _filePath;
//   bool _isRecording = false;

//   Future<void> _startRecording() async {
//     final status = await Permission.microphone.request();
//     if (status != PermissionStatus.granted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Microphone permission denied')),
//       );
//       return;
//     }

//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

//     await _record.start(
//       path: filePath,
//       encoder: AudioEncoder.aacLc,
//       bitRate: 128000,
//       samplingRate: 44100,
//     );

//     setState(() {
//       _filePath = filePath;
//       _isRecording = true;
//     });
//   }

//   Future<void> _stopRecording() async {
//     await _record.stop();
//     setState(() {
//       _isRecording = false;
//     });
//   }

//   Future<void> _playRecording() async {
//     if (_filePath != null && File(_filePath!).existsSync()) {
//       await _player.setFilePath(_filePath!);
//       _player.play();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Recording file not found')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     _record.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Audio Recorder'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               ElevatedButton.icon(
//                 icon: Icon(_isRecording ? Icons.stop : Icons.mic),
//                 label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
//                 onPressed: _isRecording ? _stopRecording : _startRecording,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 icon: Icon(Icons.play_arrow),
//                 label: Text('Play Recording'),
//                 onPressed: _playRecording,
//               ),
//             ],
//           ),
//         ));
//   }
// }
