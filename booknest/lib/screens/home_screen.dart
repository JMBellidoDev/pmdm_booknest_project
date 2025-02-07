import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../widgets/home_widgets.dart';
import '../utils/app_routes.dart';


class MainApp extends StatelessWidget {

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      appBar: HeaderBar(headerText: '¡Bienvenid@!'),
      drawer: MenuDrawer(markedLink: AppRoutes.home),
      body: HomeApp(),
    );

  }
}