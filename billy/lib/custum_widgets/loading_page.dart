import 'package:billy/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Container loadingPage(decoration) {
  return Container(
    decoration: decoration,
      child: Center(
        child: LoadingAnimationWidget.threeRotatingDots(color: BLUE_COLOR_L, size: 50)
      ),
    );
}