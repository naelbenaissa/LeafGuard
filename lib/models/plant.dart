class Plant {
  final int id;
  final String scientificName;
  final String commonName;
  final String family;
  final String imageUrl;
  final String description;
  final String distribution;

  Plant({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.family,
    required this.imageUrl,
    required this.description,
    required this.distribution,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] ?? 0,
      scientificName: json['scientific_name'] ?? 'Unknown',
      commonName: json['common_name'] ?? 'Unknown',
      family: json['family'] ?? 'Unknown',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? 'No description available.',
      distribution: json['distribution'] ?? 'Unknown',
    );
  }
}