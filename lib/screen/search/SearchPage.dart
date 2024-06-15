import 'package:flutter/material.dart';
import 'SearchResultPage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  void _onSearch() {
    final query = _controller.text;
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResult(query: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Search Videos'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter search query',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(elevation: MaterialStatePropertyAll(11), backgroundColor: MaterialStatePropertyAll(Color(0xFF10186D))),

              onPressed: _onSearch,
              child: Text('Search'),
            ),
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
        title: Text(title,
          style: TextStyle(

            color: Color(0xF1F2F2D5),
            fontWeight: FontWeight.w500,
            fontSize: 27,

          ),
        ),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        elevation: 0, // Remove shadow
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 10);
}
