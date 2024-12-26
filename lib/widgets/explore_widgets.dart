import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../persistence/model/book.dart';

/// Clase que representa el cuerpo de la página de explorar
class ExploreBody extends StatefulWidget {

  /// Constructor
  const ExploreBody({super.key});

  @override
  State<ExploreBody> createState() => _ExploreBodyState();
}

class _ExploreBodyState extends State<ExploreBody> {
  /// Controlador de búsqueda
  final TextEditingController searchController = TextEditingController();

  /// Controlador del scroll para hacer scroll infinito
  final ScrollController scrollController = ScrollController();

  /// Lista de libros
  List<Book> books = [];

  /// Booleano que indica si se están cargando resultados
  bool isLoading = false;

  /// Booleano que indica si hay más resultados
  bool hasMore = true;

  /// Número de página actual
  int currentPage = 0;

  /// Consulta actual
  String currentQuery = '';

  /// Contador de Debounce para la búsqueda tardía automática
  Timer? debounceTimer;

  /// Número de resultados por página
  static const int resultsPerPage = 10;

  /// Inicializa el estado de la página. Añade los listeners sobre los controladores
  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        fetchBooks();
      }
    });

    // Se cargan resultados al escribir texto en la barra de búsqueda
    searchController.addListener(() {
      onSearchTextChanged();
    });
  }

  /// Método de búsqueda de libros en la API externa
  ///
  /// Parámetros:
  ///   - reset: Booleano que indica si se debe resetear la búsqueda
  Future<void> fetchBooks({bool reset = false}) async {

    if (isLoading) return;

    // Se tienen en cuenta las distintas casuísticas para resetear variables
    if (reset) {
      setState(() {
        currentPage = 0;
        books = [];
        hasMore = true;
      });
    }

    if (currentQuery.isEmpty) {
      setState(() {
        books = [];
        isLoading = false;
        hasMore = false;
      });
      return;
    }

    // Si se llega hasta aquí, se deben cargar resultados. Se provoca renderizado para mostrar el spinner
    setState(() {
      isLoading = true;
    });

    // Llamada a la API
    final url = Uri.parse(
        'https://openlibrary.org/search.json?q=$currentQuery&page=${currentPage + 1}&fields=cover_i,title,author_name,first_publish_year,number_of_pages_median,ratings_average');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        currentPage++;
        books.addAll((data['docs'] as List).map((json) => Book.fromJson(json)).toList());
        hasMore = (data['docs'] as List).length >= resultsPerPage;
      });
    } else {
      setState(() {
        hasMore = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  /// Método que actúa sobre la barra de búsqueda para buscar con debounce
  void onSearchTextChanged() {
    if (debounceTimer?.isActive ?? false) {
      debounceTimer?.cancel();
    }

    debounceTimer = Timer(const Duration(milliseconds: 700), () {
      if (currentQuery != searchController.text.trim()) {
        setState(() {
          currentQuery = searchController.text.trim();
        });
        fetchBooks(reset: true);
      }
    });
  }

  /// Método para cerrar recursos abiertos al salir de la página
  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    debounceTimer?.cancel();
    super.dispose();
  }

  /// Construcción de la vista
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Barra de búsqueda
        SearchBar(
          controller: searchController,
          onClear: () {
            setState(() {
              searchController.clear();
              currentQuery = '';
              books = [];
            });
          },
        ),

        // Lista de libros
        Expanded(
          child: BookList(
            books: books,
            scrollController: scrollController,
            hasMore: hasMore,
            isLoading: isLoading,
          ),
        ),
        if (isLoading && books.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

/// Widget Barra de búsqueda 
class SearchBar extends StatelessWidget {

  /// Controlador de escritura de texto sobre la barra de búsqueda
  final TextEditingController controller;

  // Función a aplicar al limpiar el textfield
  final VoidCallback onClear;

  /// Constructor
  const SearchBar({super.key, required this.controller, required this.onClear});

  /// Construcción visual
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16.0),

      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium,

        decoration: InputDecoration(
          hintText: 'Buscar por título o autor...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),

          // Icono para limpiar la barra de búsqueda          
          suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
        ),
      ),
    );
  }
}

/// Elemento de la lista que contendrá la información de un libro
class BookTile extends StatelessWidget {

  /// Libro a mostrar
  final Book book;

  /// Constructor
  const BookTile({super.key, required this.book});

  /// Construcción visual
  @override
  Widget build(BuildContext context) {

    return ListTile(

      // Se accede a la portada o se muestra un icono en caso de no poder
      leading: book.coverId != null
        ? Image.network(
            'https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg',
            width: 50,
            fit: BoxFit.cover,
          )
        : const Icon(Icons.book, size: 50),

      // Se muestra el resto de datos
      title: Text(book.title ?? 'Sin título'),
      subtitle: Text(book.authorNames?.join(', ') ?? 'Autor desconocido'),
      trailing: Text(
        '⭐ ${book.rating?.toStringAsFixed(1) ?? 'N/A'}',
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

/// Lista de libros completa
class BookList extends StatelessWidget {

  /// Lista con los libros a mostrar
  final List<Book> books;

  /// Controlador de scroll para cargar más elementos
  final ScrollController scrollController;

  /// Booleano que indica si hay más elementos a cargar
  final bool hasMore;

  /// Booleano que indica si la página está cargando
  final bool isLoading;

  /// Constructor
  const BookList({
    super.key,
    required this.books,
    required this.scrollController,
    required this.hasMore,
    required this.isLoading,
  });

  /// Construcción visual
  @override
  Widget build(BuildContext context) {

    // Si no hay elementos
    if (books.isEmpty && !isLoading) {
      return const Center(child: Text('No se encontraron resultados.'));
    }

    // Si hay elementos se listan en bucle    
    return ListView.builder(
      controller: scrollController,
      itemCount: books.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == books.length) {
          return const Center(child: CircularProgressIndicator());
        }

        return BookTile(book: books[index]);
      },
    );
  }
}
