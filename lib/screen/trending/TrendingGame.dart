import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../player/VideoPlayer.dart';


class TrendingGaming extends StatefulWidget {
  const TrendingGaming({super.key});

  @override
  _TrendingGamingstate createState() => _TrendingGamingstate();
}

class _TrendingGamingstate extends State<TrendingGaming> {
  final YoutubeDataApi youtubeDataApi = YoutubeDataApi();
  List<Video> videos = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    //fetchTrendingGaming();
    _loadMoreVideos(); // Initial load
    _scrollController.addListener(_onScroll);
  }


  Future<void> _loadMoreVideos() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Video> newVideos = await youtubeDataApi.fetchTrendingGaming();
      setState(() {
        videos.addAll(newVideos);
        if (newVideos.length < 10) {
          hasMore = false; // No more videos to load
        }
      });
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreVideos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        controller: _scrollController,
        itemCount: videos.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == videos.length) {
            return Center(child: CircularProgressIndicator());
          }
          Video video = videos[index];
          return ListTile(
            leading: Image.network(video.thumbnailUrl),
            title: Text(video.title),
            subtitle: Text(video.channelTitle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(vid: video),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class YoutubeDataApi {
  final String apiKey = 'AIzaSyDJtwOq_8EhpDYuGvgbvwR6LwoHzmYh-FU';
  final String baseUrl = 'https://www.googleapis.com/youtube/v3';
  String? nextPageToken;

  Future<List<Video>> fetchTrendingGaming() async {
    String url = '$baseUrl/videos?part=snippet&chart=mostPopular&maxResults=10&regionCode=US&videoCategoryId=20&key=$apiKey';
    if (nextPageToken != null) {
      url += '&pageToken=$nextPageToken';
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      nextPageToken = data['nextPageToken'];
      final items = data['items'] as List?;

      if (items != null) {
        List<Video> trendingVideos = [];
        for (var item in items) {
          final snippet = item['snippet'] as Map<String, dynamic>?;
          final videoId = item['id'] as String?;
          if (snippet != null && videoId != null) {
            final videoData = {
              'id': videoId,
              'snippet': snippet,
            };
            trendingVideos.add(Video.fromJson(videoData));
          }
        }
        return trendingVideos;
      } else {
        throw Exception('Items not found in response');
      }
    } else {
      throw Exception('Failed to load trending videos');
    }
  }
  void resetNextPageToken() {
    nextPageToken = null;
  }
}


