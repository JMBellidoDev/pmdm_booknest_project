import 'package:flutter/material.dart';

import '../utils/app_routes.dart';
import '../widgets/common_widgets.dart';
import '../widgets/wishlist_widgets.dart';

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HeaderBar(headerText: 'Libros deseados'),
      drawer: MenuDrawer(markedLink: AppRoutes.wishlist),
      body: WishlistBody(),
    );
  }
}