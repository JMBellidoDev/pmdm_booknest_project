import 'package:flutter/material.dart';
import '../utils/app_routes.dart';

/// Clase principal del contenido para la página Home de Bienvenida
class HomeApp extends StatelessWidget {

  /// Constructor
  const HomeApp({super.key});

  /// Construcción visual del widget
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // Texto principal
          Text('¡Bienvenido a tu Biblioteca Digital!',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text('Explora nuestra vasta colección de libros y crea tu biblioteca personal.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text('Además, utiliza nuestra lista de deseos para guardar los títulos que siempre has querido leer.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Navegación a la biblioteca
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.library);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text('Ir a mi Biblioteca Personal',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          const SizedBox(height: 16),

          // Navegación a la lista de deseos
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.wishlist);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
              
            ),
            child: Text('Ver mi Lista de Deseos',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

