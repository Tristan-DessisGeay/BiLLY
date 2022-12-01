import 'package:billy/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

class Cell extends StatefulWidget {
  final Widget Function(bool isHovered) builder;
  final Function() refresh;

  const Cell({
    Key? key,
    required this.builder,
    required this.refresh
  }) : super(key: key);

  @override 
  _Cell createState() => _Cell();
}

class _Cell extends State<Cell> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverdTransform = Matrix4.identity()..scale(0.98);
    final transform = isHovered ? hoverdTransform : Matrix4.identity();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => onEntered(true),
      onExit: (event) => onEntered(false),
      child: AnimatedContainer(
        curve: Sprung.overDamped,
        duration: Duration(milliseconds: 200),
        transform: transform,
        child: GestureDetector(
          onTap: () {
            widget.refresh();
          },
          child: widget.builder(isHovered)
        )
      )
    );
  }

  void onEntered(bool isHovered) => setState(() {
    this.isHovered = isHovered;
  });
}