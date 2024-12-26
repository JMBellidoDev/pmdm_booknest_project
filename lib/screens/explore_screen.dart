import 'package:flutter/material.dart';

import '../utils/app_routes.dart';
import '../widgets/common_widgets.dart';
import '../widgets/explore_widgets.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HeaderBar(headerText: 'Explorar'),
      drawer: MenuDrawer(markedLink: AppRoutes.explore),
      body: ExploreBody(),
    );
  }
}