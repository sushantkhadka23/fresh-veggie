import 'package:flutter/material.dart';

const seedColor = Colors.cyan;
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Lato',
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Lato',
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  ),
);
