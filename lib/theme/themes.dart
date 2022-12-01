import 'package:flutter/material.dart';
import 'package:billy/theme/colors.dart';

bool darkMode = false;

ThemeData lightTheme = ThemeData(
  fontFamily: "ComicSansMS",
  primaryColor: BACKGROUND_COLOR_L,
  scaffoldBackgroundColor: BACKGROUND_COLOR_L,
  buttonColor: BLUE_COLOR_L
);

ThemeData darkTheme = ThemeData(
  fontFamily: "ComicSansMS",
  primaryColor: BACKGROUND_COLOR_D,
  scaffoldBackgroundColor: BACKGROUND_COLOR_D,
  colorScheme: ColorScheme.dark(),
  buttonColor: BLUE_COLOR_D
);