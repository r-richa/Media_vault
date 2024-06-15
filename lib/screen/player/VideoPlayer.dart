import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../search/SearchPage.dart';


class VideoPlayerPage extends StatefulWidget {
  final Video vid;

  VideoPlayerPage({required this.vid});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  late StreamController<double> _progressController;
  late Stream<double> _progressStream;
  bool _isDownloadingVideo = false;
  bool _isDownloadingAudio = false;

  @override
  void initState() {
    super.initState();
    _progressController = StreamController<double>();
    _progressStream = _progressController.stream.asBroadcastStream();
    _controller = VideoPlayerController.networkUrl(Uri.parse('')); // Dummy URL
    _initializeVideoPlayer();
  }


  Future<void> _initializeVideoPlayer() async {
    try {
      var yt = YoutubeExplode();
      var manifest = await yt.videos.streamsClient.getManifest(widget.vid.videoId);
      var streamInfo = manifest.muxed.withHighestBitrate();

      if (streamInfo != null) {
        _controller = VideoPlayerController.networkUrl(streamInfo.url);
        await _controller.initialize();
        setState(() {});
      } else {
        throw Exception('Stream information is not available.');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> _downloadVideo() async {
    setState(() {
      _isDownloadingVideo = true;
    });

    String? filePath;


    try {
      var yt = YoutubeExplode();
      var manifest = await yt.videos.streamsClient.getManifest(widget.vid.videoId);
      var streamInfo = manifest.muxed.withHighestBitrate();
      print('1 check');

      if (streamInfo != null) {
        var stream = yt.videos.streamsClient.get(streamInfo);
        var directory = await getApplicationDocumentsDirectory();
        var filePath = '${directory.path}/${widget.vid.title}.mp4';
        var file = File(filePath);
        var fileStream = file.openWrite();
        var totalSize = streamInfo.size.totalBytes.toDouble();
        var downloadedBytes = 0.0;
        print(filePath);

        // await for (var data in stream) {
        //   print(filePath);
        //   downloadedBytes += data.length.toDouble();
        //   var progress = downloadedBytes / totalSize;
        //   print(filePath);
        //   _progressController.add(progress);
        //   print(filePath);
        //   fileStream.add(data);
        //   print(filePath);
        // }
        // print(filePath);
        //
        // await fileStream.flush();
        // await fileStream.close();

            final videoId = widget.vid.videoId; // Store videoId in a variable within the scope of listen



            stream.listen((data) {
              downloadedBytes += data.length.toDouble();
              var progress = downloadedBytes / totalSize;
              if (!_progressController.isClosed) {
                _progressController.add(progress);
              }
              fileStream.add(data);
            }, onDone: () async {
              await fileStream.flush();
              await fileStream.close();


            //thumbnail
            var video = await yt.videos.get(widget.vid.videoId);
            var thumbnailUrl = video.thumbnails.standardResUrl;
            var response = await http.get(Uri.parse(thumbnailUrl));
            var thumbnailFilePath = await _getFilePath('${widget.vid.title}.jpg');
            var thumbnailFile = File(thumbnailFilePath);
            await thumbnailFile.writeAsBytes(response.bodyBytes);

            print('Video downloaded to $filePath');

            // Show Snackbar or update button
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video downloaded')));

              setState(() {
                _isDownloadingVideo = false;
              });
            }, onError: (e) async {
              print('Error downloading video: $e');

              // Ensure filePath is not null before attempting to delete the file
              if (filePath != null) {
                try {
                  var file = File(filePath);
                  if (await file.exists()) {
                    await file.delete();
                    print('Deleted video file: $filePath');
                  }
                } catch (deleteError) {
                  print('Error deleting video file: $deleteError');
                }
              }

              // Delete thumbnail file if it was downloaded
              // var thumbnailFilePath = await _getFilePath('${widget.vid.title}.jpg');
              // var thumbnailFile = File(thumbnailFilePath);
              // if (thumbnailFilePath != null) {
              //   try {
              //     var thumbnailFile = File(thumbnailFilePath);
              //     if (await thumbnailFile.exists()) {
              //       await thumbnailFile.delete();
              //       print('Deleted thumbnail file: $thumbnailFilePath');
              //     }
              //   } catch (deleteError) {
              //     print('Error deleting thumbnail file: $deleteError');
              //   }
              // }
              setState(() {
                _isDownloadingVideo = false;
              });
          }, cancelOnError: true);
        } else {
        throw Exception('Stream information is not available.');
      }


      }catch (e) {
       print('Error downloading video: $e');
       print(filePath);

      // if (filePath != null) {
      //   try {
      //     var file = File(filePath);
      //     if (await file.exists()) {
      //       await file.delete();
      //       print('Deleted video file: $filePath');
      //     }
      //   } catch (deleteError) {
      //     print('Error deleting video file: $deleteError');
      //   }
      // }

      // Also delete thumbnail file
      try {
        var thumbnailFilePath = await _getFilePath('${widget.vid.title}.jpg');
        var thumbnailFile = File(thumbnailFilePath);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
          print('Deleted thumbnail file: $thumbnailFilePath');
        }
      } catch (deleteError) {
        print('Error deleting thumbnail file: $deleteError');
      }
    } finally {
      setState(() {
        _isDownloadingVideo = false;
      });
    }
  }

  Future<void> _downloadAudio() async {
    setState(() {
      _isDownloadingAudio = true;
    });

    String? audioFilePath;

    try {
      var yt = YoutubeExplode();
      //var videoId = _controller.dataSource; // Assuming _controller.dataSource is the video ID
      //print('Downloading audio for video ID: $videoId'); // Print the video ID
      //var video = await yt.videos.get(videoId);
      var manifest = await yt.videos.streamsClient.getManifest(widget.vid.videoId);
      var audioStream = manifest.audioOnly.withHighestBitrate();

      if (audioStream != null) {
        var audioStreamInfo = await yt.videos.streamsClient.get(audioStream);
        audioFilePath = await _getFilePath('${widget.vid.title}.mp3');
        var audioFile = File(audioFilePath);
        print(audioFile);
        var audioFileStream = audioFile.openWrite();
        print(audioFile);
        await audioStreamInfo.pipe(audioFileStream);
        print(audioFile);
        await audioFileStream.flush();
        print(audioFile);
        await audioFileStream.close();
        print(audioFile);

        //thumbnail
        var video = await yt.videos.get(widget.vid.videoId);
        var thumbnailUrl = video.thumbnails.standardResUrl;
        var response = await http.get(Uri.parse(thumbnailUrl));
        var thumbnailFilePath = await _getFilePath('${widget.vid.title}.jpg');
        var thumbnailFile = File(thumbnailFilePath);
        await thumbnailFile.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio downloaded'),
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        throw Exception('Audio stream not found');
      }
    } catch (e) {
      print('Error downloading audio: $e');
      print(audioFilePath);

      if (audioFilePath != null) {
        try {
          var file = File(audioFilePath);
          if (await file.exists()) {
            await file.delete();
            print('Deleted audio file: $audioFilePath');
          }
        } catch (deleteError) {
          print('Error deleting audio file: $deleteError');
        }
      }

      // Also delete thumbnail file
      try {
        var thumbnailFilePath = await _getFilePath('${widget.vid.title}.jpg');
        var thumbnailFile = File(thumbnailFilePath);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
          print('Deleted thumbnail file: $thumbnailFilePath');
        }
      } catch (deleteError) {
        print('Error deleting thumbnail file: $deleteError');
      }
    } finally {
      setState(() {
        _isDownloadingAudio = false;
      });
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }



  @override
  void dispose() {
    _controller.dispose();
    _progressController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Video Player'),
      body: Column(
        children: [
          if (_controller != null && _controller.value.isInitialized)
            Flexible(
              child: AspectRatio(

                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),

              ),
            )

          else
            Center(child: CircularProgressIndicator()),
          SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white10,

            ),
            alignment: Alignment.center,
            height: 60,

            child: IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,size: 30,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              color: Color(0xFFFFFFFF),


            ),
          ),
          SizedBox(height: 30),
          StreamBuilder<double>(
            stream: _progressStream,
            initialData: 0.0,
            builder: (context, snapshot) {
              var progress = snapshot.data!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isDownloadingVideo ? null : _downloadVideo,
                    child: _isDownloadingVideo
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2.0,
                      ),
                    )
                        : Text('Download Video'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isDownloadingAudio ? null : _downloadAudio,
                    child: _isDownloadingAudio
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2.0,
                      ),
                    )
                        : Text('Download Audio'),
                  ),
                ],
              );
            },
          ),
        ],
      ),


    );
  }



}



class Video {
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String videoId;
  //final int categoryId;

  Video({
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.videoId,
    //required this.categoryId,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final thumbnails = snippet['thumbnails'] ?? {};
    final defaultThumbnail = thumbnails['default'] ?? {};
    final id = json['id'];

    String videoId;
    if (id is Map<String, dynamic> && id.containsKey('videoId')) {
      videoId = id['videoId'];
    } else if (id is String) {
      videoId = id;
    } else {
      videoId = 'No Video ID';
    }

    return Video(
      title: snippet['title'] ?? 'No Title',
      channelTitle: snippet['channelTitle'] ?? 'No Channel',
      thumbnailUrl: defaultThumbnail['url'] ?? 'https://via.placeholder.com/150',
      videoId: videoId,
    );
  }
}
