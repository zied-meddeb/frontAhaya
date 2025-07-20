class Promotion {
  final String? id;
  final String type;
  final String description;
  final double prixOriginal;
  final double prixOffre;
  final DateTime dateDebut;
  final DateTime dateFin;
  final List<String>? produits;

  Promotion({
    this.id,
    required this.type,
    required this.description,
    required this.prixOriginal,
    required this.prixOffre,
    required this.dateDebut,
    required this.dateFin,
    this.produits,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['_id'],
      type: json['type'],
      description: json['description'],
      prixOriginal: json['prix_original'].toDouble(),
      prixOffre: json['prix_offre'].toDouble(),
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      produits: json['produits'] != null ? List<String>.from(json['produits']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'prix_original': prixOriginal,
      'prix_offre': prixOffre,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      if (produits != null) 'produits': produits,
    };
  }
}