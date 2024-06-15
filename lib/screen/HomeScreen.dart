import 'package:flutter/material.dart';
import 'package:media_vault/screen/trending/TrendingAll.dart';
import 'package:media_vault/screen/trending/TrendingGame.dart';
import 'package:media_vault/screen/trending/TrendingMusic.dart';
import 'package:media_vault/screen/trending/TrendingNews.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: GradientAppBar(title : 'Media'),


        body: TabBarView(
          children: [
            TrendingAll(),
            TrendingNews(),
            TrendingGaming(),
            TrendingMusic(),
          ],
        ),
      ),
    );
  }
}



class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  GradientAppBar({required this.title});

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
        title: Row(
          children: [
            Icon(Icons.play_arrow_outlined,size: 50, color: Colors.redAccent,shadows: [Shadow(color: Colors.yellow,offset: Offset(3,3),blurRadius: 6)]),
            SizedBox(width: 10,),
            Text(title,
              style: TextStyle(

                color: Color(0xF1F2F2D5),
                fontWeight: FontWeight.w500,
                fontSize: 30,

              ),
            ),
            Text('Vault',
              style: GoogleFonts.bellota(
                color: Color(0xD3DCB937),
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),

          ],
        ),

        bottom: TabBar(
          tabs: [
            Tab(text: 'Trending', icon: FaIcon(FontAwesomeIcons.fire)),
            Tab(text: 'News', icon: Icon(Icons.newspaper)),
            Tab(text: 'Gaming', icon: Icon(Icons.games)),
            Tab(text: 'Music', icon: Icon(Icons.music_note)),
          ],
          indicatorColor: Color(0xD3DCB937),
        ),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        elevation: 0, // Remove shadow
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + kTextTabBarHeight + 25);
}



