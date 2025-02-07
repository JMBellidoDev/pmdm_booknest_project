import 'package:flutter/material.dart';
import '../screens/screens.dart';

class AppRoutes {
  
  // Nombres de rutas
  static const String credits = "/credits";
  static const String explore = "/explore";
  static const String home = "/";
  static const String library = "/library";
  static const String wishlist = "/wishlist";


  // Mapas de rutas
  static final Map<String, WidgetBuilder> routes = {
    credits: (context) => const Credits(),
    explore: (context) => const Explore(),
    home: (context) => const MainApp(),
    library: (context) => const Library(),
    wishlist: (context) => const Wishlist()
  };

}