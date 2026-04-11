import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppFonts {
  // Nunito Sans - Main font for clean, modern look
  static TextStyle _nunitoSans({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.nunitoSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Courier Prime - Retro TV feel
  static TextStyle _courierPrime({
    required double size,
    required Color color,
    double? letterSpacing,
    FontWeight weight = FontWeight.normal,
  }) =>
      GoogleFonts.courierPrime(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Display / Hero Text
  static TextStyle display({
    required Color color,
    double size = 96,
    FontWeight weight = FontWeight.w700,
    double letterSpacing = -3.5,
    double height = 1.0,
  }) =>
      _nunitoSans(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Headings
  static TextStyle heading({
    required Color color,
    double size = 44,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = -1.0,
  }) =>
      _nunitoSans(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Subheadings
  static TextStyle subheading({
    required Color color,
    double size = 24,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = -0.5,
  }) =>
      _nunitoSans(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Body text
  static TextStyle body({
    required Color color,
    double size = 18,
    FontWeight weight = FontWeight.w400,
    double height = 1.9,
    double letterSpacing = 0.0,
  }) =>
      _nunitoSans(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Small body text
  static TextStyle bodySmall({
    required Color color,
    double size = 14,
    FontWeight weight = FontWeight.w400,
    double height = 1.7,
    double letterSpacing = 0.0,
  }) =>
      _nunitoSans(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Labels
  static TextStyle label({
    required Color color,
    double size = 15,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0.1,
  }) =>
      _nunitoSans(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Small labels
  static TextStyle labelSmall({
    required Color color,
    double size = 12,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0.5,
  }) =>
      _nunitoSans(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // TV Retro Style (for channel numbers, status, etc.)
  static TextStyle tvRetro({
    required Color color,
    double size = 11,
    double letterSpacing = 2,
    FontWeight weight = FontWeight.normal,
  }) =>
      _courierPrime(
        size: size,
        color: color,
        letterSpacing: letterSpacing,
        weight: weight,
      );

  // TV Channel Style (for channel buttons)
  static TextStyle tvChannel({
    required Color color,
    double size = 9,
    double letterSpacing = 3,
    FontWeight weight = FontWeight.bold,
  }) =>
      _courierPrime(
        size: size,
        color: color,
        letterSpacing: letterSpacing,
        weight: weight,
      );

  // TV Display Style (for big channel numbers)
  static TextStyle tvDisplay({
    required Color color,
    double size = 16,
    double letterSpacing = 2,
    FontWeight weight = FontWeight.bold,
  }) =>
      _courierPrime(
        size: size,
        color: color,
        letterSpacing: letterSpacing,
        weight: weight,
      );

  // Code style (for code blocks)
  static TextStyle code({
    required Color color,
    double size = 13,
    double letterSpacing = 0.5,
    FontWeight weight = FontWeight.normal,
  }) =>
      _courierPrime(
        size: size,
        color: color,
        letterSpacing: letterSpacing,
        weight: weight,
      );

  // Button text
  static TextStyle button({
    required Color color,
    double size = 14,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 1,
  }) =>
      _nunitoSans(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Link text
  static TextStyle link({
    required Color color,
    double size = 14,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0.5,
    bool underline = true,
  }) =>
      _nunitoSans(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
      ).copyWith(
        decoration: underline ? TextDecoration.underline : null,
      );
}