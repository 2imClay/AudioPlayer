import 'package:audioplayer/home/button.dart';
import 'package:audioplayer/home/content.dart';
import 'package:flutter/material.dart';

class AudioPlayerTest extends StatefulWidget {
  const AudioPlayerTest({super.key});

  @override
  State<StatefulWidget> createState() {
    return AudioPlayerState();
  }
}

class AudioPlayerState extends State<AudioPlayerTest> {
  String _nameButtonPressed='Src';

  void buttonPressed(String text){
    setState(() {
      _nameButtonPressed = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.cyan,
        title: const Center(
          child: Text(
            'Audio Player',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          PageButton(),
          OptionButton(onPressed: buttonPressed),
          ContentPage(pageName: _nameButtonPressed)

        ],
      ),
    );
  }
}


