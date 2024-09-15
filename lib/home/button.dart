import 'package:flutter/material.dart';

class PageButton extends StatefulWidget {
  const PageButton({super.key});


  @override
  State<StatefulWidget> createState() {
    return PageButtonState();
  }
}

class PageButtonState extends State<PageButton> {
  String? _selectedButton;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildButton('P1', isLeft: true),
          buildButton('P2'),
          buildButton('P3'),
          buildButton('P4', isRight: true),
        ],
      ),
    );
  }

  Widget buildButton(String text, {bool isLeft = false, bool isRight = false}) {
    bool isPressed = _selectedButton == text;
    return OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedButton = text;
          });
        },
        style: OutlinedButton.styleFrom(
            backgroundColor: isPressed ? Colors.cyan[100] : Colors.white,
            side: BorderSide(
                color: isPressed ? Colors.blueAccent : Colors.grey, width: 2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
              left: isLeft ? const Radius.circular(10) : Radius.zero,
              right: isRight ? const Radius.circular(10) : Radius.zero,
            ))),
        child: Text(
            text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ));
  }
}

class OptionButton extends StatefulWidget {

  final Function(String) onPressed;

  const OptionButton({super.key, required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return OptionButtonState();
  }
}

class OptionButtonState extends State<OptionButton> {

  String? _selectedButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildButton('Src',),
        buildButton('Ctrl'),
        buildButton('Stream'),
        buildButton('Ctx'),
        buildButton('Log'),
      ],
    );
  }

  Widget buildButton(String text) {

    bool isSelected = _selectedButton == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedButton = text;
          });
          widget.onPressed(text);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.lightBlueAccent : Colors.transparent,
                width: 2
              )
            )
          ),

          child: Center(
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
