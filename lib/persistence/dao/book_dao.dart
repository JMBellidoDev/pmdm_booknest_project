import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/book.dart';

/// DAO de acceso a la base de datos de libros
class BookDao{

  /// Instancia de la clase. Patrón Singleton
  static final BookDao instance = BookDao._init();

  /// Base de datos
  static Database? bookDatabase;

  /// Constructor de clase
  BookDao._init();

  /// Getter para la base de datos
  /// 
  /// Params:
  /// 
  /// Return:
  ///   - Future<Database>
  Future<Database> get database async {

    if (bookDatabase != null) return bookDatabase!;
    bookDatabase = await initDB('books.db');
    return bookDatabase!;
  }

  /// Método para inicializar la base de datos
  /// 
  /// Params:
  ///   - filePath (String): Ruta hacia el fichero de la base de datos
  /// 
  /// Return:
  ///   - Future<Database>: La base de datos a usar
  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: createDB,
    );
  }

  /// Método que define la estructura de la base de datos
  /// 
  /// Params:
  ///   - db (Database): Base de datos a usar
  ///   - version (int): Versión de la base de datos
  /// 
  /// Return:
  ///   - void
  Future<void> createDB(Database db, int version) async {

    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        coverId INTEGER,
        title TEXT,
        firstPublishYear INTEGER,
        rating REAL,
        authorNames TEXT,
        isInWishlist INTEGER DEFAULT 0
      )
    ''');
  }

  /// Método para añadir un libro en la biblioteca
  /// En caso de existir previamente, significa que está en la lista de deseados, por lo que se cambia su estado.
  /// Si no existe, se inserta
  /// 
  /// Params:
  ///   - book (Book): Libro a guardar en la biblioteca
  /// 
  /// Return: 
  ///   - void
  Future<void> addBookToLibrary(Book book) async {
    final db = await instance.database;

    var books = await db.query(
      'books', where: 'title = ? AND authorNames = ?', 
      whereArgs: [book.title, book.authorNames!.join(', ')]
    );

    // Si no está incluido el libro en base de datos, se inserta
    if (books.isEmpty) {
      await db.insert(
        'books',
        book.toDBMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

    // Si ya lo está, se actualiza porque se presupone que pertenece a la lista de deseados
    } else {
      await db.update(
        'books',
        {'isInWishlist': 0},
        where: 'title = ? AND authorNames = ?',
        whereArgs: [book.title, book.authorNames!.join(', ')],
      );
    }
  }

  /// Obtiene todos los libros de la base de datos
  /// 
  /// Params:
  /// 
  /// Return:
  ///   - Future<List<Book>>: Lista de libros
  Future<List<Book>> getAllBooks() async {

    final db = await instance.database;
    final result = await db.query('books');

    return result.map((json) => Book.fromJson(json)).toList();
  }

  /// Obtiene todos los libros de la lista de la biblioteca
  /// 
  /// Params:
  /// 
  /// Result: 
  ///   - Future<List<Book>>
  Future<List<Book>> getLibraryBooks() async {
  final db = await instance.database;
  final result = await db.query('books', where: 'isInWishlist = ?', whereArgs: [0]);

  return result.map((json) => Book.fromJson(json)).toList();
}

  /// Obtiene todos los libros de la lista de deseados
  /// 
  /// Params:
  /// 
  /// Result: 
  ///   - Future<List<Book>>
  Future<List<Book>> getWishlistBooks() async {
  final db = await instance.database;
  final result = await db.query('books', where: 'isInWishlist = ?', whereArgs: [1]);

  return result.map((json) => Book.fromJson(json)).toList();
}

  /// Añade o elimina un libro de la lista de deseados. En caso de no estar en el sistema, se añade previamente
  /// 
  /// Params:
  ///   - book (Book): Libro a actualizar
  ///   - isInWishlist (bool): Indica si el libro de modifica para estar o no en lista de deseados
  /// 
  /// Result:
  ///   - void
  Future<void> updateWishlistStatus(Book book, bool isInWishlist) async {
    final db = await instance.database;

    // Si no están en la wishlist
    if (isInWishlist) {

      // Se comprueba si existe previamente y, si no lo está, se inserta
      var books = await db.query('books', where: 'title = ? AND authorNames = ?', whereArgs: [book.title, book.authorNames!.join(', ')]);

      if (books.isEmpty) {

        book.isInWishlist = true;
        await db.insert('books',
          book.toDBMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

      // Sino, se actualiza la entidad
      } else {
      
        await db.update(
          'books',
          {'isInWishlist': 1},
          where: 'title = ? AND authorNames = ?',
          whereArgs: [book.title, book.authorNames!.join(', ')],
        );
      }

    // Si está en la wishlist, se elimina el libro
    } else {
      await db.delete(
        'books',
        where: 'title = ? AND authorNames = ?',
        whereArgs: [book.title, book.authorNames!.join(', ')],
      );
    }
  }

  /// Elimina un libro de la base de datos. 
  /// No lanza ningún error si no se posee el libro previamente
  /// 
  /// Params:
  ///   - title (String): ID del libro en DB
  ///   - author (String): Autor/Autores del libro
  /// 
  /// Return:
  ///   - void
  Future<void> deleteBook(String title, String author) async {
    final db = await instance.database;

    await db.delete(
      'books',
      where: 'title = ? AND authorNames = ?',
      whereArgs: [title, author],
    );
  }

  /// Cierra la base de datos
  Future<void> close() async {
    if (bookDatabase != null) {
      await bookDatabase?.close();
    }
  }


}