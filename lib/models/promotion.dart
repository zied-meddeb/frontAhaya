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
      id: json['_id'] as String,
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
      dateDebut: DateTime.parse(json['date_debut'] as String),
      dateFin: DateTime.parse(json['date_fin'] as String),
      dateAffiche: json['date_affiche'] != null
          ? DateTime.parse(json['date_affiche'] as String)
          : null,
      produits: json['produits'] as List<dynamic>?,
      statut: (json['statut'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
