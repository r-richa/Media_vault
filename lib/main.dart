import 'package:flutter/material.dart';
import 'package:media_vault/screen/HomeScreen.dart';
import 'package:media_vault/screen/SplashScreen.dart';
import 'package:media_vault/screen/download/DownloadsPage.dart';
import 'package:media_vault/screen/search/SearchPage.dart';


void main() => runApp(MyApp());
//void main() => fetchCategories();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Vault',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0x97232324),
        appBarTheme: AppBarTheme(
          color : Color(0x84061E78),



        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          selectedItemColor: Color(0xD3DCB937),
          unselectedItemColor: Colors.white60,
          elevation: 0,

        ),

        // tabBarTheme: TabBarTheme(
        //   labelColor: Colors.redAccent, // Color of the selected icon
        //   unselectedLabelColor: Colors.white, // Color of the unselected icons
        // ),
      ),
      home: SplashScreen(),

    );
  }
}



class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  PageController _pageController = PageController();

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomePage(),
          SearchPage(),
          DownloadsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          //borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(30), topStart: Radius.circular(30)),
          gradient: LinearGradient(
            colors: [Color(0x84061E78), Color(0x97232324)], // Define your gradient colors here
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),


        ),
        //height: 60,
        padding: EdgeInsets.all(5),
        child: BottomNavigationBar(

          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.download),
              label: 'Downloads',
            ),
          ],
        ),
      ),
    );
  }
}
//
// Future<void> fetchCategories() async {
//   final String apiKey = 'AIzaSyB_wRswu3iE7QBH_f7xoHP7RYgwvEA0WOc';
//   final String baseUrl = 'https://www.googleapis.com/youtube/v3/videoCategories?part=snippet&regionCode=US&key=$apiKey';
//   final response = await http.get(Uri.parse(baseUrl));
//
//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     final items = data['items'] as List?;
//     if (items != null) {
//       for (var item in items) {
//         print('Category ID: ${item['id']}, Title: ${item['snippet']['title']}');
//       }
//     }
//   } else {
//     print('Failed to load categories: ${response.body}');
//   }
// }








