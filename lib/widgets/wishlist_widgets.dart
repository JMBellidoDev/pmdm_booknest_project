import 'package:flutter/material.dart';
import 'dart:async';

import './common_widgets.dart';
import '../persistence/model/book.dart';
import '../persistence/persistence/book_dao.dart';

/// Clase que representa el cuerpo de la página de libros deseados (wishlist)
class WishlistBody extends StatefulWidget {

  /// Constructor
  const WishlistBody({super.key});

  @override
  State<WishlistBody> createState() => _WishlistBodyState();
}

class _WishlistBodyState extends State<WishlistBody> {

  /// Lista de libros de la lista de deseados
  List<Book> wishlistBooks = [];

  /// Lista de libros de la lista de deseados mostrados al usuario
  List<Book> shownWishlistBooks = [];

  /// Controlador de búsqueda
  final TextEditingController searchController = TextEditingController();

  /// Tipo de ordenación seleccionada
  String sortOrder = 'year_desc';

  /// Inicializa el estado de la página. Añade los listeners sobre los controladores y carga los libros del usuario
  @override
  void initState() {
    super.initState();
    loadWishlistBooks();
  }

  /// Carga los libros de la lista de deseados asociados al usuario
  /// 
  /// Params:
  /// 
  /// Return: 
  ///   - Future<void>
  Future<void> loadWishlistBooks() async {
    final books = await BookDao.instance.getWishlistBooks();
    setState(() {
      wishlistBooks = books;
      shownWishlistBooks = books;
      sortBooks(sortOrder);
    });
  }

  /// Elimina un libro de la DB y avisa al usuario
  /// 
  /// Params:
  ///   - book (Book): Libro a eliminar
  /// 
  /// Return:
  ///   - void
  Future<void> removeBook(Book book) async {

  // Se elimina el libro de la base de datos
  await BookDao.instance.deleteBook(book.title ?? '', book.authorNames!.join(', '));

  // Se actualiza la lista en el estado
  setState(() {
    wishlistBooks.remove(book);
    shownWishlistBooks.remove(book);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Libro "${book.title}" eliminado de la lista de deseados',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
    );
  });
}

  /// Ordena los libros según el criterio seleccionado
  /// 
  /// Params:
  ///   - sort (String): Ordenación
  /// 
  /// Return:
  ///   - void
  void sortBooks(String sort) {
    setState(() {
      sortOrder = sort;
      
      switch (sortOrder) {
        case 'title_asc':
          shownWishlistBooks.sort((a, b) => a.title!.compareTo(b.title!));
          break;
        case 'title_desc':
          shownWishlistBooks.sort((a, b) => b.title!.compareTo(a.title!));
          break;
        case 'author_asc':
          shownWishlistBooks.sort((a, b) =>
              a.authorNames!.join(', ').compareTo(b.authorNames!.join(', ')));
          break;
        case 'author_desc':
          shownWishlistBooks.sort((a, b) =>
              b.authorNames!.join(', ').compareTo(a.authorNames!.join(', ')));
          break;
        case 'year_asc':
          shownWishlistBooks.sort((a, b) => (a.firstPublishYear ?? 0).compareTo(b.firstPublishYear ?? 0));
          break;
        case 'year_desc':
          shownWishlistBooks.sort((a, b) => (b.firstPublishYear ?? 0).compareTo(a.firstPublishYear ?? 0));
          break;
      }
    });
  }

  /// Método para cerrar recursos abiertos al salir de la página
  /// 
  /// Params:
  /// 
  /// Return:
  ///   - void
  @override
  void dispose() {
    searchController.dispose();
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
          onSearch: (query) {
            setState(() {
              if (query.isEmpty) {
                shownWishlistBooks = wishlistBooks;
              
              } else {
                shownWishlistBooks = wishlistBooks
                    .where((book) => book.title!.toLowerCase().contains(query.toLowerCase()) ||
                        book.authorNames!.join(', ').toLowerCase().contains(query.toLowerCase()))
                    .toList();
              }
            });
          },
          onClear: () => setState(() {
            searchController.clear();
            shownWishlistBooks = wishlistBooks;
          }),
        ),

        // Selector de ordenación
        SortSelector(selectedSort: sortOrder, onSortChanged: sortBooks),

        // Lista de libros
        Expanded(
          child: shownWishlistBooks.isEmpty
              ? Center(child: Text('No se encontraron libros en la lista de deseados.', 
                style: Theme.of(context).textTheme.bodyMedium, 
                textAlign: TextAlign.center
                )
              )
              : ListView.builder(
                  itemCount: shownWishlistBooks.length,
                  itemBuilder: (context, index) {
                    return BookTile(
                      book: shownWishlistBooks[index], 
                      onDelete: () => removeBook(shownWishlistBooks[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Widget Barra de búsqueda
class SearchBar extends StatelessWidget {

  /// Controlador de edición de texto sobre el textfield
  final TextEditingController controller;

  /// Función al realizar la búsqueda
  final Function(String) onSearch;

  /// Método de limpiado de búsqueda
  final VoidCallback onClear;

  /// Constructor
  const SearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),

      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: onSearch,

        decoration: InputDecoration(
          hintText: 'Buscar por título o autor...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),

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

  /// Método a ejecutar al eliminar un libro de la lista
  final VoidCallback onDelete;

  /// Constructor
  const BookTile({super.key, required this.book, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: book.coverId != null
          ? Image.network(
              'https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg',
              width: 50,
              fit: BoxFit.cover,
            )
          : const Icon(Icons.book, size: 50),
      title: Text(book.title ?? 'Sin título', style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(book.authorNames?.join(', ') ?? 'Autor desconocido', style: Theme.of(context).textTheme.bodySmall),
      trailing: IconButton(
        icon: const Icon(Icons.favorite, color: Colors.red),
        onPressed: onDelete, 
      ),
    );
  }
}