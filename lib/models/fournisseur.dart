class SocialMedia {
  final String? facebook;
  final String? instagram;
  final String? twitter;

  SocialMedia({
    this.facebook,
    this.instagram,
    this.twitter,
  });

  Map<String, dynamic> toJson() {
    return {
      if (facebook != null) 'facebook': facebook,
      if (instagram != null) 'instagram': instagram,
      if (twitter != null) 'twitter': twitter,
    };
  }

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      facebook: json['facebook'],
      instagram: json['instagram'],
      twitter: json['twitter'],
    );
  }
}

class StoreInfo {
  final String? website;
  final String? logoUrl;
  final String? description;
  final SocialMedia? socialMedia;

  StoreInfo({
    this.website,
    this.logoUrl,
    this.description,
    this.socialMedia,
  });

  Map<String, dynamic> toJson() {
    return {
      if (website != null) 'website': website,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (description != null) 'description': description,
      if (socialMedia != null) 'socialMedia': socialMedia!.toJson(),
    };
  }

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      website: json['website'],
      logoUrl: json['logoUrl'],
      description: json['description'],
      socialMedia: json['socialMedia'] != null 
          ? SocialMedia.fromJson(json['socialMedia']) 
          : null,
    );
  }
}

class FournisseurAddress {
  final String? id;
  final String type; // 'primary' | 'secondary' | 'warehouse' | 'office'
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final Coordinates? coordinates;

  FournisseurAddress({
    this.id,
    required this.type,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
    this.coordinates,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'type': type,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      if (coordinates != null) 'coordinates': coordinates!.toJson(),
    };
  }

  factory FournisseurAddress.fromJson(Map<String, dynamic> json) {
    return FournisseurAddress(
      id: json['_id'],
      type: json['type'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      isDefault: json['isDefault'] ?? false,
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'])
          : null,
    );
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }
}

class PerformanceMetrics {
  final int totalProductsListed;
  final double clickThroughRate;

  PerformanceMetrics({
    this.totalProductsListed = 0,
    this.clickThroughRate = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalProductsListed': totalProductsListed,
      'clickThroughRate': clickThroughRate,
    };
  }

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      totalProductsListed: json['totalProductsListed'] ?? 0,
      clickThroughRate: (json['clickThroughRate'] ?? 0).toDouble(),
    );
  }
}

class Fournisseur {
  final String? id;
  final String nom;
  final String email;
  final String? password;
  final String telephone;
  final List<FournisseurAddress> addresses;
  final bool isVerified;
  final String? verificationCode;
  final bool isOnboardingCompleted;
  final StoreInfo? storeInfo;
  final PerformanceMetrics? performanceMetrics;
  final String role;

  Fournisseur({
    this.id,
    required this.nom,
    required this.email,
    this.password,
    required this.telephone,
    required this.addresses,
    this.isVerified = false,
    this.verificationCode,
    this.isOnboardingCompleted = false,
    this.storeInfo,
    this.performanceMetrics,
    this.role = 'fournisseur',
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'nom': nom,
      'email': email,
      if (password != null) 'password': password,
      'telephone': telephone,
      'addresses': addresses.map((addr) => addr.toJson()).toList(),
      'isVerified': isVerified,
      if (verificationCode != null) 'verificationCode': verificationCode,
      'isOnboardingCompleted': isOnboardingCompleted,
      if (storeInfo != null) 'storeInfo': storeInfo!.toJson(),
      if (performanceMetrics != null) 'performanceMetrics': performanceMetrics!.toJson(),
      'role': role,
    };
  }

  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      id: json['_id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((addr) => FournisseurAddress.fromJson(addr))
              .toList() ??
          [],
      isVerified: json['isVerified'] ?? false,
      verificationCode: json['verificationCode'],
      isOnboardingCompleted: json['isOnboardingCompleted'] ?? false,
      storeInfo: json['storeInfo'] != null
          ? StoreInfo.fromJson(json['storeInfo'])
          : null,
      performanceMetrics: json['performanceMetrics'] != null
          ? PerformanceMetrics.fromJson(json['performanceMetrics'])
          : null,
      role: json['role'] ?? 'fournisseur',
    );
  }
}
