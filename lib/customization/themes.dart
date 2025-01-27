import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const mainColor = Color.fromARGB(255, 161, 189, 201);
const secondaryColor = Color.fromARGB(255, 250, 102, 94);
const darkSecondaryColor = Color.fromARGB(255, 182, 59, 53);

// Tema claro
final customizedLightTheme = ThemeData(

  // Básica
  brightness: Brightness.light,
  primaryColor: mainColor,
  secondaryHeaderColor: secondaryColor,
  dividerColor: Colors.black54,

  // Scaffold + AppBar
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white)
  ),

  // ElevatedButton
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white
    )
  ),

  // FloatingActionButton
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.white
  ),

  // Textos
  textTheme: TextTheme(

    // Títulos
    titleLarge: GoogleFonts.poppins(
      color: Colors.black,
      fontSize: 35,
      backgroundColor: const Color.fromARGB(80, 254, 247, 255)
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: darkSecondaryColor
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black
    ),

    headlineLarge: GoogleFonts.poppins(
      fontSize: 26,
      color: Colors.white,
      fontWeight: FontWeight.w600
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.w600
    ),

    // Texto del cuerpo
    labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: secondaryColor),
    labelMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: secondaryColor),
    labelSmall: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14, color: secondaryColor),
    
    bodyLarge: GoogleFonts.poppins(fontSize: 18),
    bodyMedium: GoogleFonts.poppins(fontSize: 15),
    bodySmall: GoogleFonts.poppins(fontSize: 14),

  ),

  iconTheme: const IconThemeData(
    color: Colors.black
  ),
);

