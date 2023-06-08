import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:billy/theme/colors.dart';

class Button extends StatefulWidget {
  final Widget Function(bool isHovered) builder;

  const Button({
    Key? key,
    required this.builder
  }) : super(key: key);

  @override 
  _Button createState() => _Button();
}

class _Button extends State<Button> with SingleTickerProviderStateMixin {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => onEntered(true),
      onExit: (event) => onEntered(false),
      child: widget.builder(isHovered)
    );
  }

  void onEntered(bool isHovered) => setState(() {
    this.isHovered = isHovered;
  });
}

Widget get_B_button(on_press, margin, context) {
  return Container(
    margin: margin,
    child: Button(
      builder: (isHovered) {
        final radius = !isHovered ? BorderRadius.all(Radius.circular(30)) : BorderRadius.all(Radius.circular(20));
        return AnimatedContainer(
              duration: Duration(milliseconds: 250),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).buttonColor,
                borderRadius: radius
              ),
              child: TextButton(
                onPressed: on_press,
                child: Text("B", style: TextStyle(color: Colors.white, fontSize: 30),),
              ),
            );
      } 
    )
  );
}

Widget get_simple_button(text, on_press, width, height, margin, context) {
  return Container(
    margin: margin,
    child: Button(
      builder: (isHovered) {
        final radius = !isHovered ? BorderRadius.all(Radius.circular(30)) : BorderRadius.all(Radius.circular(20));
        return AnimatedContainer(
              duration: Duration(milliseconds: 250),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).buttonColor,
                borderRadius: radius
              ),
              child: TextButton(
                onPressed: on_press,
                child: Text(text, style: TextStyle(color: Colors.white, fontSize: (MediaQuery.of(context).size.width>400)?20:15),),
              ),
            );
      } 
    )
  );
}

Widget get_animatedText_button(text, on_press, maj, width, height, margin, visible, context) {
  return Container(
    margin: margin,
    child: Button(
      builder: (isHovered) {
        final radius = !isHovered ? BorderRadius.all(Radius.circular(30)) : BorderRadius.all(Radius.circular(20));
        return AnimatedContainer(
              duration: Duration(milliseconds: 250),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).buttonColor,
                borderRadius: radius
              ),
              child: TextButton(
                onPressed: on_press,
                child: AnimatedOpacity(
                  opacity: visible ? 1.0: 0.0,
                  duration: Duration(milliseconds: 250),
                  onEnd: maj,
                  child: Text(text, style: TextStyle(color: Colors.white, fontSize: (MediaQuery.of(context).size.width>400)?20:15)),
                )
              )
        );
      } 
    )
  );
}