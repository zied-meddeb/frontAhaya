// models/promotion.dart

class Promotion {
  final String id;
  final String fournisseur;
  final String type;
  final List<String> afficheUrls;
  final String titre;
  final String description;
  final double prixOriginal;
  final double prixOffre;
  final DateTime dateDebut;
  final DateTime dateFin;
  final DateTime? dateAffiche;
  final List<dynamic>? produits;
  final String statut;
  final DateTime createdAt;
  final DateTime updatedAt;

  Promotion({
    required this.id,
    required this.fournisseur,
    required this.type,
    required this.afficheUrls,
    required this.titre,
    required this.description,
    required this.prixOriginal,
    required this.prixOffre,
    required this.dateDebut,
    required this.dateFin,
    this.dateAffiche,
    this.produits,
    required this.statut,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    final rawFournisseur = json['Fournisseur'];
    final fournisseur = rawFournisseur is Map
        ? (rawFournisseur['nom'] ?? '').toString()
        : rawFournisseur.toString();

    return Promotion(
      id: json['_id']?.toString() ?? '',
      fournisseur: fournisseur,
      type: (json['type'] ?? '').toString(),
      afficheUrls: (json['afficheUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      titre: (json['titre'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      prixOriginal: (json['prix_original'] ?? 0).toDouble(),
      prixOffre: (json['prix_offre'] ?? 0).toDouble(),
      dateDebut: json['date_debut'] != null ? DateTime.parse(json['date_debut']) : DateTime.now(),
      dateFin: json['date_fin'] != null ? DateTime.parse(json['date_fin']) : DateTime.now(),
      dateAffiche: json['date_affiche'] != null
          ? DateTime.parse(json['date_affiche'])
          : null,
      produits: json['produits'] != null
          ? List<Map<String, dynamic>>.from(json['produits'])
          : [],
      statut: (json['statut'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      if (fournisseur.isNotEmpty) 'Fournisseur': fournisseur,
      'type': type,
      'afficheUrls': afficheUrls,
      'description': description,
      'prix_original': prixOriginal,
      'prix_offre': prixOffre,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      if (dateAffiche != null) 'date_affiche': dateAffiche!.toIso8601String(),
      if (produits != null) 'produits': produits,
      if (statut.isNotEmpty) 'statut': statut,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'titre': titre
    };
  }
}
