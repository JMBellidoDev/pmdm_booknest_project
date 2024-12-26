import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../widgets/credits_widgets.dart';
import '../utils/app_routes.dart';

class Credits extends StatelessWidget {
  const Credits({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HeaderBar(headerText: 'Créditos'),
      drawer: MenuDrawer(markedLink: AppRoutes.credits),
      body: CreditsBody(),
    );
  }
}
