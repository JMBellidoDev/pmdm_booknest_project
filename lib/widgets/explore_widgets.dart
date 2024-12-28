import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../persistence/model/book.dart';
import '../persistence/persistence/book_dao.dart';

/// Clase que representa el cuerpo de la página de explorar
class ExploreBody extends StatefulWidget {

  /// Constructor
  const ExploreBody({super.key});

  @override
  State<ExploreBody> createState() => _ExploreBodyState();
}

class _ExploreBodyState extends State<ExploreBody> {

  /// Número de resultados por página
  static const int resultsPerPage = 10;

  /// Controlador de búsqueda
  final TextEditingController searchController = TextEditingController();

  /// Controlador del scroll para hacer scroll infinito
  final ScrollController scrollController = ScrollController();

  /// Lista de libros
  List<Book> books = [];

  /// Lista de libros asociados con el usuario
  List<Book> userBooks = [];

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

  /// Inicializa el estado de la página. Añade los listeners sobre los controladores y carga los libros del usuario
  @override
  void initState() {
    super.initState();

    loadUserBooks();

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

  /// Carga los libros asociados al usuario
  /// 
  /// Params:
  /// 
  /// Return: 
  ///   - Future<void>
  Future<void> loadUserBooks() async {
    final loadedBooks = await BookDao.instance.getAllBooks();
    setState(() {
      userBooks = loadedBooks;
    });
  }

  /// Método de búsqueda de libros en la API externa
  ///
  /// Params:
  ///   - reset: Booleano que indica si se debe resetear la búsqueda
  /// 
  /// Return:
  ///   - Future<void>
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
      final newBooks = (data['docs'] as List).map((json) => Book.fromJson(json)).toList();

      setState(() {
        currentPage++;
        books.addAll(newBooks);
        hasMore = data['docs'].length >= resultsPerPage;
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
  /// 
  /// Params:
  /// 
  /// Return:
  ///   - void
  void onSearchTextChanged() {
    if (debounceTimer?.isActive ?? false) {
      debounceTimer?.cancel();
    }

    debounceTimer = Timer(const Duration(milliseconds: 700), () {
      final trimmedQuery = searchController.text.trim();

      if (currentQuery != trimmedQuery) {
        setState(() {
          currentQuery = trimmedQuery;
        });
        fetchBooks(reset: true);
      }
    });
  }

  /// Método para añadir o eliminar un libro de la base de datos
  /// 
  /// Params:
  ///   - book (Book): Libro a insertar o eliminar
  /// 
  /// Return:
  ///   - Future<void>
  Future<void> addOrRemoveBook(Book book) async {

    bool isInLibrary = userBooks.any((b) => 
      b.title == book.title 
      && b.authorNames!.join(', ') == book.authorNames!.join(', ') 
      && b.isInWishlist == false
    );

    bool wasAdded;
    print(isInLibrary);
    print(book.isInWishlist);

    // Si está en la biblioteca, se elimina
    if (isInLibrary) {
      await BookDao.instance.deleteBook(book.title ?? '', book.authorNames!.join(', '));
      wasAdded = false;

    // Si no está en la biblioteca, se añade
    } else {
      await BookDao.instance.addBookToLibrary(book);
      print('se está llamando aquí');
      print(book.isInWishlist);
      wasAdded = true;
    }

    // Se recargan los libros del usuario
    await loadUserBooks();

    // Cambio de estado y mensaje al usuario
    setState(() {
      String message = wasAdded
        ? 'Libro "${book.title}" añadido a la biblioteca'
        : 'Libro "${book.title}" eliminado de la biblioteca';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          duration: const Duration(seconds: 2),
          showCloseIcon: true,
          backgroundColor: Theme.of(context).secondaryHeaderColor,
        ),
      );
    });
  }

/// Método que añade o elimina un libro de la lista de deseados
/// 
/// Params:
///   - book (Book): Libro a insertar o eliminar de la lista
/// 
/// Result:
///   - void
Future<void> addOrRemoveFromWishlist(Book book) async {

  bool isInWishlist = userBooks.any((b) => 
    b.title == book.title 
    && b.authorNames!.join(', ') == book.authorNames!.join(', ') 
    && b.isInWishlist == true
  );

  // Actualizar el estado en la base de datos
  await BookDao.instance.updateWishlistStatus(book, !isInWishlist);

  // Recargar los libros del usuario
  await loadUserBooks();

  // Mostrar mensaje
  setState(() {
    String message = isInWishlist
        ? 'Libro "${book.title}" eliminado de la lista de deseados'
        : 'Libro "${book.title}" añadido a la lista de deseados';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
    );
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
            onAddOrRemove: addOrRemoveBook,
            userBooks: userBooks,
            onAddOrRemoveFromWishlist: addOrRemoveFromWishlist,
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

  /// Lista de libros del usuario
  final List<Book> userBooks;

  /// Función para añadir o eliminar libro
  final Function(Book) onAddOrRemove;

  /// Función para añadir o eliminar libro de la lista de deseados
  final Function(Book) onAddOrRemoveFromWishlist;

  /// Constructor
  const BookTile({
    super.key, 
    required this.book, 
    required this.userBooks,
    required this.onAddOrRemove,
    required this.onAddOrRemoveFromWishlist});

  /// Verifica si el libro está en la biblioteca del usuario
  bool isBookInLibrary(Book book) {
    return userBooks.any((userBook) => 
      userBook.title == book.title && 
      userBook.authorNames?.join(', ') == book.authorNames?.join(', ') && 
      userBook.isInWishlist == false);
  }

  /// Verifica si el libro está en la lista de deseados del usuario
  bool isBookInWishlist(Book book) {
    return userBooks.any((userBook) => 
      userBook.title == book.title && 
      userBook.authorNames!.join(', ') == book.authorNames!.join(', ') && 
      userBook.isInWishlist == true);
  }

  /// Construcción visual
  @override
  Widget build(BuildContext context) {

    bool isInLibrary = isBookInLibrary(book);
    bool isInWishlist = isBookInWishlist(book);

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
      title: Text(book.title ?? 'Sin título', style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(book.authorNames?.join(', ') ?? 'Autor desconocido', style: Theme.of(context).textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⭐ ${book.rating?.toStringAsFixed(1) ?? 'N/A'}',
            style: const TextStyle(color: Colors.grey),
          ),
          IconButton(
            iconSize: 30,
            icon: Icon(
              isInLibrary ? Icons.remove_circle : Icons.add_circle,
              color: isInLibrary ? Colors.red : Colors.green,
            ),
            onPressed: () => onAddOrRemove(book),
          ),
          IconButton(
            iconSize: 30,
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.pink : Colors.grey,
            ),
            onPressed: () => onAddOrRemoveFromWishlist(book),
          ),
        ],
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

  /// Función para añadir o eliminar un libro
  final Function(Book) onAddOrRemove;

  /// Lista de libros del usuario
  final List<Book> userBooks;

  /// Función para añadir o eliminar un libro de la lista de deseados
  final Function(Book) onAddOrRemoveFromWishlist;

  /// Constructor
  const BookList({
    super.key,
    required this.books,
    required this.scrollController,
    required this.hasMore,
    required this.isLoading,
    required this.onAddOrRemove,
    required this.userBooks,
    required this.onAddOrRemoveFromWishlist
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

        return BookTile(book: books[index], userBooks: userBooks, onAddOrRemove: onAddOrRemove, onAddOrRemoveFromWishlist: onAddOrRemoveFromWishlist,);
      },
    );
  }
}
