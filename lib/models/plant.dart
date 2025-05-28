class Plant {
  final int id;
  final String scientificName;
  final String commonName;
  final String family;
  final String genus;
  final String rank;
  final String status;
  final String author;
  final int year;
  final String bibliography;
  final String imageUrl;
  final String description;
  final String distribution;
  final String slug;

  Plant({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.family,
    required this.genus,
    required this.rank,
    required this.status,
    required this.author,
    required this.year,
    required this.bibliography,
    required this.imageUrl,
    required this.description,
    required this.distribution,
    required this.slug,
  });

  /// Crée une instance de `Plant` à partir d’un JSON.
  /// Assure des valeurs par défaut pour éviter les erreurs nulles.
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] ?? 0,
      scientificName: json['scientific_name'] ?? 'Unknown',
      commonName: json['common_name'] ?? 'Unknown',
      family: json['family'] ?? 'Unknown',
      genus: json['genus'] ?? 'Unknown',
      rank: json['rank'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
      author: json['author'] ?? 'Unknown',
      year: json['year'] ?? 0,
      bibliography: json['bibliography'] ?? 'No bibliography available.',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? 'No description available.',
      distribution: json['distribution'] ?? 'Unknown',
      slug: json['slug'] ?? '',
    );
  }
}
