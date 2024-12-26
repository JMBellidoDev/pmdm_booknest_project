

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

  /// Constructor
  Book(
    this.id,
    this.coverId,
    this.title,
    this.firstPublishYear,
    this.rating,
    this.authorNames,
  );

  /// Método para obtener los datos de un libro a partir de un JSON
  ///
  /// Parámetros:
  ///   - json: Mapa que actúa como JSON
  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    coverId = json['cover_i'];
    title = json['title'];
    firstPublishYear = json['first_publish_year'];
    rating = (json['ratings_average'] as num?)?.toDouble();
    authorNames = (json['author_name'] as List<dynamic>?)
        ?.map((author) => author.toString())
        .toList();
  }

  /// Método para convertir los datos del libro a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cover_i': coverId,
      'title': title,
      'first_publish_year': firstPublishYear,
      'ratings_average': rating,
      'author_name': authorNames?.join(', '),
    };
  }
}
