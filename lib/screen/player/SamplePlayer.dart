import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '../search/SearchPage.dart';



class SamplePlayer extends StatefulWidget {
  final File file;

  SamplePlayer({required this.file, Key? key}) : super(key: key);

  @override
  _SamplePlayerState createState() => _SamplePlayerState();
}

class _SamplePlayerState extends State<SamplePlayer> {
  late AudioPlayer audioPlayer;
  late VideoPlayerController videoPlayerController;
  bool _isFullScreen = true;
  bool _isPlayingAudio = true;
  String thumbnailPath = '';
  String vidtitle = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    if (widget.file.path.toLowerCase().endsWith('.mp4')) {
      // Initialize video player for MP4 files
      videoPlayerController = VideoPlayerController.file(widget.file);
      await videoPlayerController.initialize();
      await videoPlayerController.play();
      setState(() {});
    } else if (widget.file.path.toLowerCase().endsWith('.mp3')) {
      // Initialize audio player for MP3 files
      vidtitle = widget.file.path.split('/').last.replaceAll('.mp3', '');
      thumbnailPath = widget.file.path.replaceAll('.mp3', '.jpg');
      audioPlayer = AudioPlayer();
      await audioPlayer.setFilePath(widget.file.path);
      await audioPlayer.play();

      setState(() {});
    }
  }


  @override
  void dispose() {
    if (widget.file.path.toLowerCase().endsWith('.mp4')) {
      videoPlayerController.dispose();
    } else if (widget.file.path.toLowerCase().endsWith('.mp3')) {
      audioPlayer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Player'),
      body: widget.file.path.toLowerCase().endsWith('.mp4')
          ? _buildVideoPlayer(context)
          : _buildAudioPlayer(),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: videoPlayerController.value.aspectRatio,
          child: VideoPlayer(videoPlayerController),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.rotate_90_degrees_ccw),
                onPressed: () {
                  setState(() {
                    _isFullScreen = !_isFullScreen;
                    if (_isFullScreen) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft,
                      ]);
                    } else {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                    }
                  });
                },
              ),


              //}),
              IconButton(
                icon: Icon(
                    videoPlayerController.value.isPlaying ? Icons.pause : Icons
                        .play_arrow),
                onPressed: () {
                  setState(() {
                    if (videoPlayerController.value.isPlaying) {
                      videoPlayerController.pause();
                    } else {
                      videoPlayerController.play();
                    }
                  });
                },
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (thumbnailPath.isNotEmpty)
          Image.file(File(thumbnailPath)),

        // Text(vidtitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white10,

          ),
          alignment: Alignment.center,
          height: 60,
          child: IconButton(
            icon: Icon(_isPlayingAudio ? Icons.pause : Icons.play_arrow,size: 30,),
            onPressed: () {
              setState(() {
                _isPlayingAudio = !_isPlayingAudio;
                if (_isPlayingAudio) {
                  // Implement audio play functionality
                  audioPlayer.play();
                } else {
                  // Implement audio pause functionality
                  audioPlayer.pause();
                }
              });
            },
          ),
        ),
        SizedBox(height: 80),
        Text(vidtitle),
      ],
    );
  }

}
