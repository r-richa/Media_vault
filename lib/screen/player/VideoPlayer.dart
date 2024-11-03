import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

class VideoPlayerPage extends StatefulWidget {
  final Video vid;

  VideoPlayerPage({required this.vid});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _youtubeController;
  late StreamController<double> _progressController;
  late Stream<double> _progressStream;
  bool _isDownloadingVideo = false;
  bool _isDownloadingAudio = false;

  @override
  void initState() {
    super.initState();
    _progressController = StreamController<double>();
    _progressStream = _progressController.stream.asBroadcastStream();
    _initializeYoutubePlayer();
  }

  void _initializeYoutubePlayer() {
    _youtubeController = YoutubePlayerController(
      initialVideoId: widget.vid.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  //changed

  // Future<void> _downloadVideo() async {
  //   setState(() {
  //     _isDownloadingVideo = true;
  //   });
  //
  //   String? filePath;
  //
  //
  //   try {
  //     var yt = YoutubeExplode();
  //     var manifest = await yt.videos.streamsClient.getManifest(widget.vid.videoId);
  //     //var streamInfo = manifest.muxed.withHighestBitrate();
  //     print('1 check');
  //
  //     var streamInfo = manifest.video.first;
  //
  //
  //     if (streamInfo != null) {
  //       var stream = yt.videos.streamsClient.get(streamInfo);
  //       var directory = await getApplicationDocumentsDirectory();
  //       var filePath = '${directory.path}/${widget.vid.title}.mp4';
  //       var file = File(filePath);
  //       var fileStream = file.openWrite();
  //       var totalSize = streamInfo.size.totalBytes.toDouble();
  //       var downloadedBytes = 0.0;
  //       print(filePath);
  //
  //
  //
  //       final videoId = widget.vid.videoId; // Store videoId in a variable within the scope of listen
  //
  //
  //
  //       stream.listen((data) {
  //         downloadedBytes += data.length.toDouble();
  //         var progress = downloadedBytes / totalSize;
  //         if (!_progressController.isClosed) {
  //           _progressController.add(progress);
  //         }
  //         fileStream.add(data);
  //       }, onDone: () async {
  //         await fileStream.flush();
  //         await fileStream.close();
  //
  //
  //         //thumbnail
  //         var video = await yt.videos.get(widget.vid.videoId);
  //         var thumbnailUrl = video.thumbnails.standardResUrl;
  //         var response = await http.get(Uri.parse(thumbnailUrl));
  //         var thumbnailFilePath = await _getFilePath('${widget.vid.title}.jpg');
  //         var thumbnailFile = File(thumbnailFilePath);
  //         await thumbnailFile.writeAsBytes(response.bodyBytes);
  //
  //         print('Video downloaded to $filePath');
  //
  //         // Show Snackbar or update button
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video downloaded')));
  //
  //         setState(() {
  //           _isDownloadingVideo = false;
  //         });
  //       }, onError: (e) async {
  //         print('Error downloading video: $e');
  //
  //         // Ensure filePath is not null before attempting to delete the file
  //         if (filePath != null) {
  //           try {
  //             var file = File(filePath);
  //             if (await file.exists()) {
  //               await file.delete();
  //               print('Deleted video file: $filePath');
  //             }
  //           } catch (deleteError) {
  //             print('Error deleting video file: $deleteError');
  //           }
  //         }
  //
  //
  //         setState(() {
  //           _isDownloadingVideo = false;
  //         });
  //       }, cancelOnError: true);
  //     } else {
  //       throw Exception('Stream information is not available.');
  //     }
  //
  //
  //   }catch (e) {
  //     print('Error downloading video: $e');
  //     print(filePath);
  //
  //
  //
  //     // Also delete thumbnail file
  //     try {
  //       var thumbnailFilePath = await _getFilePath('${widget.vid.title}.jpg');
  //       var thumbnailFile = File(thumbnailFilePath);
  //       if (await thumbnailFile.exists()) {
  //         await thumbnailFile.delete();
  //         print('Deleted thumbnail file: $thumbnailFilePath');
  //       }
  //     } catch (deleteError) {
  //       print('Error deleting thumbnail file: $deleteError');
  //     }
  //   } finally {
  //     setState(() {
  //       _isDownloadingVideo = false;
  //     });
  //   }
  // }

  Future<void> _downloadVideo() async {
    setState(() {
      _isDownloadingVideo = true;
    });

    String? videoFilePath;
    String? audioFilePath;

    try {
      var yt = YoutubeExplode();
      var manifest = await yt.videos.streamsClient.getManifest(widget.vid.videoId);
      final directory = await getApplicationDocumentsDirectory();

      print("check 1");

      // Download Video
      var videoStreamInfo = manifest.video.first;
      videoFilePath = await _downloadStream(videoStreamInfo, 'video');

      print("video down check");

      // Download Audio
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      audioFilePath = await _downloadStream(audioStreamInfo, 'audio');

      // // Merge Audio and Video
      // if (videoFilePath != null && audioFilePath != null) {
      //   String outputFilePath = '${directory.path}/${widget.vid.title}_muxed.mp4';  // Define output path
      //   await mergeAudioVideo(videoFilePath, audioFilePath, outputFilePath);
      // }

      if (videoFilePath != null && audioFilePath != null) {
        String outputFilePath = '${directory.path}/${widget.vid.title}_merged.mp4';
        await mergeAudioVideo(videoFilePath, audioFilePath, outputFilePath);

        // Remove the standalone audio file after merging
        await File(audioFilePath).delete();

        // Download and save the thumbnail for the merged video
        var video = await yt.videos.get(widget.vid.videoId);
        var thumbnailUrl = video.thumbnails.standardResUrl;
        var response = await http.get(Uri.parse(thumbnailUrl));
        // String sanitizedTitle = widget.vid.title.replaceAll(' ', '_');
        // var thumbnailFilePath = '${directory.path}/${sanitizedTitle}_merged.jpg';
        var thumbnailFilePath = '${directory.path}/${widget.vid.title}_thumbnail.jpg';
        await File(thumbnailFilePath).writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video downloaded')),
          );
        }
      }

      // Handle thumbnail download, etc.
      //thumbnail
      // var video = await yt.videos.get(widget.vid.videoId);
      // var thumbnailUrl = video.thumbnails.standardResUrl;
      // var response = await http.get(Uri.parse(thumbnailUrl));
      // var thumbnailFilePath = await _getFilePath('${widget.vid.title}_muxed.jpg');
      // var thumbnailFile = File(thumbnailFilePath);
      // await thumbnailFile.writeAsBytes(response.bodyBytes);

      print('Video downloaded to ');



      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Video downloaded')),
      //   );
      // }

    } catch (e) {
      // Handle exceptions
      print('Error downloading video: $e');
      if (mounted) {
        setState(() {
          _isDownloadingVideo = false;
        });
      }

    }
  }

  Future<String> _downloadStream(StreamInfo streamInfo, String type) async {
    var yt = YoutubeExplode();
    var stream = yt.videos.streamsClient.get(streamInfo);
    var directory = await getApplicationDocumentsDirectory();

    //String sanitizedTitle = widget.vid.title.replaceAll(' ', '_');
    //var filePath = '${directory.path}/${sanitizedTitle}.${type == 'video' ? 'mp4' : 'mp3'}';
    var filePath = '${directory.path}/${widget.vid.title}.${type == 'video' ? 'mp4' : 'mp3'}';
    var file = File(filePath);
    var fileStream = file.openWrite();

    await for (var data in stream) {
      fileStream.add(data);
    }
    await fileStream.flush();
    await fileStream.close();

    return filePath;  // Return the file path of the downloaded stream
  }

  Future<void> mergeAudioVideo(String videoPath, String audioPath, String outputPath) async {
    if (!File(videoPath).existsSync() || !File(audioPath).existsSync()) {
      print('Error: One or both files do not exist');
      return;
    }
    String command = '-i $videoPath -i $audioPath -c:v copy -c:a aac -strict experimental $outputPath';
    final result = await FFmpegKit.execute(command);
    final returnCode = await result.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Merged video and audio successfully.');
    } else {
      print('Error merging video and audio: $returnCode');
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
        var audioFileStream = audioFile.openWrite();
        await audioStreamInfo.pipe(audioFileStream);
        await audioFileStream.flush();
        await audioFileStream.close();

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
    _youtubeController.dispose();
    _progressController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _youtubeController,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
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
                      child: CircularProgressIndicator(value: progress),
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
                      child: CircularProgressIndicator(value: progress),
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

  Video({
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.videoId,
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
