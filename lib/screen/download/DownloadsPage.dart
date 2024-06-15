import 'package:flutter/material.dart';
import 'DownloadMusic.dart';
import 'DownloadVideo.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  _DownloadsPageState createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: GradientAppbar(),
        body: TabBarView(
          children: [
            DownloadsVideo(),
            DownloadsMusic()
          ],
        ),
      ),
    );
  }
}


class GradientAppbar extends StatelessWidget implements PreferredSizeWidget {
  //final String title;

  //GradientAppbar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x84061E78), Color(0x97232324)], // Define your gradient colors here
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          tabs: [
            Tab(text: 'Video', icon: Icon(Icons.video_call)),
            Tab(text: 'Audio', icon: Icon(Icons.music_note)),

          ],
          indicatorColor: Color(0xD3DCB937),
        ),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        elevation: 0, // Remove shadow
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + kTextTabBarHeight - 20);
}

