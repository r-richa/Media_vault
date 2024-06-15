import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//import '../HomeScreen.dart';
import '../player/VideoPlayer.dart';
import 'SearchPage.dart';



class SearchResult extends StatefulWidget {
  final String query;

  SearchResult({required this.query});

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final YoutubeDataApi youtubeDataApi = YoutubeDataApi();
  List<Video> videos = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    //fetchVideos(widget.query);
    _loadMoreVideos(); // Initial load
    _scrollController.addListener(_onScroll);
  }


  Future<void> _loadMoreVideos() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Video> newVideos = await youtubeDataApi.fetchSearchVideo(widget.query);
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
      appBar: GradientAppBar(title: 'Search Results'),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: videos.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == videos.length) {
            return Center(child: CircularProgressIndicator());
          }

          var video = videos[index];
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

  Future<List<Video>> fetchSearchVideo(String query) async {
    String url = '$baseUrl/search?part=snippet&type=video&q=$query&maxResults=10&key=$apiKey';
    if (nextPageToken != null) {
      url += '&pageToken=$nextPageToken';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      nextPageToken = data['nextPageToken'];
      final items = data['items'] as List;

      return items.map((item) => Video.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
  void resetNextPageToken() {
    nextPageToken = null;
  }
}

