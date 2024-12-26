import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/screens.dart';

/// HeaderBar de todas las páginas 
class HeaderBar extends StatelessWidget implements PreferredSizeWidget {

  /// Texto a mostrar
  final String headerText;

  /// Constructor
  const HeaderBar({super.key, required this.headerText});

  /// Construcción visual del HeaderBar
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(
          headerText, 
          style: Theme.of(context).textTheme.headlineLarge
        )
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

/// Elemento de la lista del drawer
class InkedDrawerText extends StatelessWidget {

  /// URL
  final String url;

  /// Indica si está marcado el enlace como la página actual
  final bool marked;

  /// Constructor con URL que indica si debe ser marcado como la página actual
  const InkedDrawerText({super.key, required this.url, required this.marked});

  /// Método que enlaza la entrada del drawer con su Widget en función de la URL aportada
  Widget getPageWithUrl(String url) {
    switch (url) {
      case AppRoutes.home:
        return const MainApp();

      case AppRoutes.credits:
        return const Credits();

      case AppRoutes.explore:
        return const Explore();

      case AppRoutes.library:
        return const Library();

      case AppRoutes.wishlist:
        return const Wishlist();

      default:
        return const MainApp();
    }
  }

  /// Método que obtiene el texto del drawer en función de la URL
  String getDrawerText(String url) {
        switch (url) {
      case AppRoutes.home:
        return 'Bienvenida';

      case AppRoutes.credits:
        return 'Créditos';

      case AppRoutes.explore:
        return 'Explorar';

      case AppRoutes.library:
        return 'Mi biblioteca';

      case AppRoutes.wishlist:
        return 'Lista de deseos';

      default:
        return 'Presentación';
    }
  }

  /// Construcción visual del widget
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
      border: Border.all(
        color: marked ? Colors.blue : Colors.black,
        width: 0.2, 
        )
      ),
      child: Ink(
        color: marked ? Theme.of(context).secondaryHeaderColor : Colors.white60,
        child: ListTile(
          title: Text(
            getDrawerText(url),
            style: GoogleFonts.poppins(
              color: marked ?Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            )),
            onTap: 
            !marked ? () {
              Navigator.pushReplacementNamed(context, url);
            } : () {},
        )
      )
    );
  }
}


/// Drawer personalizado de la aplicación
class MenuDrawer extends StatelessWidget {

  final String markedLink;

  const MenuDrawer({super.key, required this.markedLink});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          // Cabecera
          DrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/drawer-background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                const Positioned(
                  top: 6.0,
                  left: 10.0,
                  child: CircleAvatar(
                    radius: 70.0,
                    backgroundImage: AssetImage('assets/images/app-icon.jpg'),
                  ),
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: Text(
                    'BookNest',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      backgroundColor: const Color.fromARGB(5, 0, 0, 0)
                    ),
                  ),
                ),
              ],
            )
          ),

          // Enlaces
          Expanded(
            child: ListView(
              children: [
                InkedDrawerText(url: AppRoutes.home, marked: markedLink == AppRoutes.home),
                InkedDrawerText(url: AppRoutes.explore, marked: markedLink == AppRoutes.explore),
                InkedDrawerText(url: AppRoutes.library, marked: markedLink == AppRoutes.library),
                InkedDrawerText(url: AppRoutes.wishlist, marked: markedLink == AppRoutes.wishlist),
                InkedDrawerText(url: AppRoutes.credits, marked: markedLink == AppRoutes.credits)
              ],
            ),
          )
        ],
      )
    );
  }
}