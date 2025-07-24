class Promotion {
  final String? id;
  final String? fournisseur;
  final String type;
  final String? afficheUrl;
  final String description;
  final double prixOriginal;
  final double prixOffre;
  final DateTime dateDebut;
  final DateTime dateFin;
  final List<dynamic>? produits;
  final String? statut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Promotion({
    this.id,
    this.fournisseur,
    required this.type,
    this.afficheUrl,
    required this.description,
    required this.prixOriginal,
    required this.prixOffre,
    required this.dateDebut,
    required this.dateFin,
    this.produits,
    this.statut,
    this.createdAt,
    this.updatedAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['_id'],
      fournisseur: json['Fournisseur'],
      type: json['type'],
      afficheUrl: json['afficheUrl'],
      description: json['description'],
      prixOriginal: (json['prix_original'] ?? 0).toDouble(),
      prixOffre: (json['prix_offre'] ?? 0).toDouble(),
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      produits: json['produits'],
      statut: json['statut'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (fournisseur != null) 'Fournisseur': fournisseur,
      'type': type,
      if (afficheUrl != null) 'afficheUrl': afficheUrl,
      'description': description,
      'prix_original': prixOriginal,
      'prix_offre': prixOffre,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      if (produits != null) 'produits': produits,
      if (statut != null) 'statut': statut,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}