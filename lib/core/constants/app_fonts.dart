import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppFonts {
  static TextStyle _poppins({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle _mono({
    required double size,
    required Color color,
    double? letterSpacing,
  }) =>
      GoogleFonts.nunitoSans(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle display({
    required Color color,
    double size = 96,
    FontWeight weight = FontWeight.w700,
    double letterSpacing = -3.5,
    double height = 1.0,
  }) =>
      _poppins(
          size: size,
          weight: weight,
          color: color,
          letterSpacing: letterSpacing,
          height: height);

  static TextStyle heading({
    required Color color,
    double size = 44,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = -1.0,
  }) =>
      _poppins(
          size: size,
          weight: weight,
          color: color,
          letterSpacing: letterSpacing);

  static TextStyle body({
    required Color color,
    double size = 18,
    FontWeight weight = FontWeight.w400,
    double height = 1.9,
    double letterSpacing = 0.0,
  }) =>
      _poppins(
          size: size,
          weight: weight,
          color: color,
          letterSpacing: letterSpacing,
          height: height);

  static TextStyle label({
    required Color color,
    double size = 15,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0.1,
  }) =>
      _poppins(
          size: size,
          weight: weight,
          color: color,
          letterSpacing: letterSpacing);

  static TextStyle mono({
    required Color color,
    double size = 14,
    double letterSpacing = 0.02,
  }) =>
      _mono(size: size, color: color, letterSpacing: letterSpacing);
}
