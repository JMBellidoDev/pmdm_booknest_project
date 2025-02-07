import 'package:flutter/material.dart';
import './utils/app_routes.dart';
import './customization/themes.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'BookNest',
      themeMode: ThemeMode.light,
      theme: customizedLightTheme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
