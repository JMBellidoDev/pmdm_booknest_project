

/// Clase representación de un libro del sistema
class Book {
  /// ID del libro
  int? id;

  /// ID de la portada del libro
  int? coverId;

  /// Título del libro
  String? title;

  /// Primer año de publicación
  int? firstPublishYear;

  /// Media de puntuaciones
  double? rating;

  /// Lista de nombres de autores
  List<String>? authorNames;

  /// Booleano que indica si el libro está en la lista de deseados
  bool? isInWishlist;

  /// Constructor
  Book(
    this.id,
    this.coverId,
    this.title,
    this.firstPublishYear,
    this.rating,
    this.authorNames,
    this.isInWishlist,
  );

  /// Método para obtener los datos de un libro a partir de un JSON.
  /// Puede provenir tanto de base de datos como de API, por lo que se deben diferenciar los casos
  ///
  /// Params:
  ///   - json (Map<String, dynamic>): Mapa que actúa como JSON
  /// 
  /// Return:
  ///   - Book: Libro generado
  Book.fromJson(Map<String, dynamic> json) {

    // Caso API
    if (json.containsKey('cover_i')) {
      id = null;
      coverId = json['cover_i'];
      title = json['title'];
      firstPublishYear = json['first_publish_year'];
      rating = (json['ratings_average'] as num?)?.toDouble();
      authorNames = (json['author_name'] as List<dynamic>?)
          ?.map((author) => author.toString())
          .toList();
      isInWishlist = false;

    // Caso DB
    } else {
      id = json['id'] != null ? (json['id'] as int?) : null;
      coverId = json['coverId'];
      title = json['title'];
      firstPublishYear = json['firstPublishYear'];
      rating = (json['rating'] as num?)?.toDouble();
      authorNames = json['authorNames']?.split(', ');
      isInWishlist = (json['isInWishlist'] ?? 0) == 1;
    }
  }

  /// Método que convierte el objeto en un mapa para poder trabajar con base de datos
  /// 
  /// Params:
  /// 
  /// Return:
  ///   - Map<String, dynamic>: Mapa generado a partir del libro
  Map<String, dynamic> toDBMap() {

    return {
      'id': id,
      'coverId': coverId,
      'title': title,
      'firstPublishYear': firstPublishYear,
      'rating': rating,
      'authorNames': authorNames?.join(', ') ?? '',
      'isInWishlist': (isInWishlist ?? false) ? 1 : 0,
    };
  }

  /// Método toString
  @override
  String toString() {
    return 'Book{id: $id, coverId: $coverId, title: $title, '
        'firstPublishYear: $firstPublishYear, rating: $rating, '
        'authorNames: ${authorNames?.join(", ")}}';
  }
}
