import 'package:flutter/material.dart';

import '../utils/app_routes.dart';
import '../widgets/common_widgets.dart';
import '../widgets/library_widgets.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HeaderBar(headerText: 'Mi biblioteca'),
      drawer: MenuDrawer(markedLink: AppRoutes.library),
      body: LibraryBody(),
    );
  }
}