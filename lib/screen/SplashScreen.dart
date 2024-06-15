import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:youtube_player/main.dart';
import 'dart:async';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    // Start the animation after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _visible = true;
      });
    });

    // Navigate to home screen after 2 seconds
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Color(0x161616D6)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: Duration(seconds: 2),
                      child: Icon(Icons.play_arrow_outlined,size: 150, color: Colors.redAccent,shadows: [Shadow(color: Colors.yellow,offset: Offset(3,3),blurRadius: 12)]),

                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Media',
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

                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
