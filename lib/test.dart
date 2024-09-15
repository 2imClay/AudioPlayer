import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimationTest extends StatefulWidget{
  const AnimationTest({super.key});

  @override
  AnimationTestState createState() => AnimationTestState();
}

class AnimationTestState extends State<AnimationTest> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isHovered = false;
  Alignment _alignment = Alignment.centerLeft;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.5, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            child:
            AnimatedContainer(
              width: _isHovered ? 70 : 100,
              height: _isHovered ? 70 : 100,
              duration: Duration(seconds: 2),
              // curve: Curves.fastOutSlowIn,
              // child: Image.asset('assets/images/todoappimage.png'),
              child: Container(
                color: Colors.cyan,
              ),
            ),

          ),
          Container(
            width: 100,
            height: 100,
            child:
            AnimatedOpacity(
              opacity: _isHovered ? 1 : 0.2,
              duration: Duration(seconds: 2),
              // child: Image.asset('assets/images/todoappimage.png'),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.cyan,
              ),
            ),

          ),
          Stack(
            children: [
              Container(
                width: 400,
                height: 5,
                margin: EdgeInsets.only(top: 10),
                color: Colors.grey,
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: AnimatedContainer(
                  // curve: Curves.easeInOut,
                  width: _isHovered ? 360 : 0,
                  duration: Duration(seconds: 10),
                  child: Container(
                    width: 0,
                    height: 5,
                    color: Colors.cyan,
                  ),
                ),
              ),
              AnimatedAlign(
                // curve: Curves.easeInOut,
                duration: Duration(seconds: 10),
                alignment: _alignment,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      color: Colors.cyan,
                      shape: BoxShape.circle
                  ),

                ),
              ),
            ],
          ),




          ElevatedButton(
            onPressed: () {
              setState(() {
                _isHovered=!_isHovered;
                _alignment == Alignment.centerLeft?
                Alignment.centerRight : Alignment.centerLeft;
              });
            },
            child: Text('Change'),)
        ],
      ),
    );

  }

}