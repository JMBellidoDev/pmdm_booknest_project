import 'package:flutter/material.dart';

/// Cuerpo de la página de créditos
class CreditsBody extends StatelessWidget {

  /// Constructor
  const CreditsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: const [
          CreditsSection(),
          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),
          ResourcesSection(),
        ],
      ),
    );
  }
}

/// Sección de créditos y contacto
class CreditsSection extends StatelessWidget {

  /// Constructor
  const CreditsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Créditos de la aplicación',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        Text('Biblioteca de Libros - Versión 1.0',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 10),
        Text('Desarrollado por: José Martín Bellido',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text('Contacto: jmarbel857@g.educaand.es',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text('Descripción: Esta aplicación permite almacenar tu biblioteca personal de libros y gestionar tu lista de deseos.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// Sección de recursos utilizados
class ResourcesSection extends StatelessWidget {

  /// Constructor
  const ResourcesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recursos usados',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Text('API utilizada:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text('- Open Library',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text('Bibliotecas utilizadas:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text('- Flutter SDK\n- SQLite\n- Google Fonts\n- http\n- sqflite\n- path',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
