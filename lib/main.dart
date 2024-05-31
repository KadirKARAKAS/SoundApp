import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration _position = Duration.zero;
  String? _downloadURL;

  Future<void> _initializeAndPlayMusic() async {
    try {
      _downloadURL = await FirebaseStorage.instance
          .ref('musics/Onur Akın - İnadına (Official Audio).mp3')
          .getDownloadURL();
      await _audioPlayer.play(UrlSource(_downloadURL!));
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Failed to play music: $e');
    }
  }

  Future<void> _playOrPauseMusic() async {
    if (isPlaying) {
      _position = await _audioPlayer.getCurrentPosition() ?? Duration.zero;
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (_downloadURL == null) {
        await _initializeAndPlayMusic();
      } else {
        await _audioPlayer.play(UrlSource(_downloadURL!), position: _position);
        setState(() {
          isPlaying = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Play Music from Firebase'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _playOrPauseMusic,
          child: Text(isPlaying ? 'Pause Music' : 'Play Music'),
        ),
      ),
    );
  }
}
