class Promotion {
  final String? id;
  final String? fournisseur;
  final String type;
  final List<String>? afficheUrls;
  final String description;
  final double prixOriginal;
  final double prixOffre;
  final DateTime dateDebut;
  final DateTime dateFin;
  final DateTime? dateAffiche;
  final List<String>? produits;
  final String? statut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Promotion({
    this.id,
    this.fournisseur,
    required this.type,
    this.afficheUrls,
    required this.description,
    required this.prixOriginal,
    required this.prixOffre,
    required this.dateDebut,
    required this.dateFin,
    this.dateAffiche,
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
      afficheUrls: json['afficheUrls'] != null 
          ? List<String>.from(json['afficheUrls']) 
          : null,
      description: json['description'],
      prixOriginal: (json['prix_original'] ?? 0).toDouble(),
      prixOffre: (json['prix_offre'] ?? 0).toDouble(),
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      dateAffiche: json['date_affiche'] != null ? DateTime.parse(json['date_affiche']) : null,
      produits: json['produits'] != null 
          ? List<String>.from(json['produits']) 
          : null,
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
      if (afficheUrls != null) 'afficheUrls': afficheUrls,
      'description': description,
      'prix_original': prixOriginal,
      'prix_offre': prixOffre,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      if (dateAffiche != null) 'date_affiche': dateAffiche!.toIso8601String(),
      if (produits != null) 'produits': produits,
      if (statut != null) 'statut': statut,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}