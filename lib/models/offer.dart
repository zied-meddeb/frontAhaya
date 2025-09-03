import 'package:flutter/material.dart';

class Offer {
  final int id;
  final String title;
  final String category;
  final String description;
  final String location;
  final String country;
  final String region;
  final double originalPrice;
  final double promotionalPrice;
  final OfferStatus status;
  final int views;
  final int bookings;
  final double rating;
  final DateTime endDate;
  final DateTime displayPeriodStart;
  final DateTime displayPeriodEnd;
  final String? videoLink;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? validatedAt;
  final String? rejectionReason;
  final String? imageUrl;

  Offer({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.country,
    required this.region,
    required this.originalPrice,
    required this.promotionalPrice,
    required this.status,
    this.views = 0,
    this.bookings = 0,
    this.rating = 0.0,
    required this.endDate,
    required this.displayPeriodStart,
    required this.displayPeriodEnd,
    this.videoLink,
    required this.createdAt,
    this.submittedAt,
    this.validatedAt,
    this.rejectionReason,
    this.imageUrl,
  });

  double get discountPercentage {
    return ((originalPrice - promotionalPrice) / originalPrice * 100);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'location': location,
      'country': country,
      'region': region,
      'originalPrice': originalPrice,
      'promotionalPrice': promotionalPrice,
      'status': status.name,
      'views': views,
      'bookings': bookings,
      'rating': rating,
      'endDate': endDate.toIso8601String(),
      'displayPeriodStart': displayPeriodStart.toIso8601String(),
      'displayPeriodEnd': displayPeriodEnd.toIso8601String(),
      'videoLink': videoLink,
      'createdAt': createdAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'validatedAt': validatedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'imageUrl': imageUrl,
    };
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      description: json['description'],
      location: json['location'],
      country: json['country'],
      region: json['region'],
      originalPrice: json['originalPrice'].toDouble(),
      promotionalPrice: json['promotionalPrice'].toDouble(),
      status: OfferStatus.values.firstWhere((e) => e.name == json['status']),
      views: json['views'] ?? 0,
      bookings: json['bookings'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      endDate: DateTime.parse(json['endDate']),
      displayPeriodStart: DateTime.parse(json['displayPeriodStart']),
      displayPeriodEnd: DateTime.parse(json['displayPeriodEnd']),
      videoLink: json['videoLink'],
      createdAt: DateTime.parse(json['createdAt']),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      validatedAt: json['validatedAt'] != null
          ? DateTime.parse(json['validatedAt'])
          : null,
      rejectionReason: json['rejectionReason'],
      imageUrl: json['imageUrl'],
    );
  }

  Offer copyWith({
    int? id,
    String? title,
    String? category,
    String? description,
    String? location,
    String? country,
    String? region,
    double? originalPrice,
    double? promotionalPrice,
    OfferStatus? status,
    int? views,
    int? bookings,
    double? rating,
    DateTime? endDate,
    DateTime? displayPeriodStart,
    DateTime? displayPeriodEnd,
    String? videoLink,
    DateTime? createdAt,
    DateTime? submittedAt,
    DateTime? validatedAt,
    String? rejectionReason,
    String? imageUrl,
  }) {
    return Offer(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      country: country ?? this.country,
      region: region ?? this.region,
      originalPrice: originalPrice ?? this.originalPrice,
      promotionalPrice: promotionalPrice ?? this.promotionalPrice,
      status: status ?? this.status,
      views: views ?? this.views,
      bookings: bookings ?? this.bookings,
      rating: rating ?? this.rating,
      endDate: endDate ?? this.endDate,
      displayPeriodStart: displayPeriodStart ?? this.displayPeriodStart,
      displayPeriodEnd: displayPeriodEnd ?? this.displayPeriodEnd,
      videoLink: videoLink ?? this.videoLink,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      validatedAt: validatedAt ?? this.validatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

enum OfferStatus {
  draft,
  pendingValidation,
  active,
  rejected,
  expired,
}

extension OfferStatusExtension on OfferStatus {
  String get displayName {
    switch (this) {
      case OfferStatus.draft:
        return 'Brouillon';
      case OfferStatus.pendingValidation:
        return 'En attente de validation';
      case OfferStatus.active:
        return 'Actif';
      case OfferStatus.rejected:
        return 'Rejetée';
      case OfferStatus.expired:
        return 'Expiré';
    }
  }

  Color get color {
    switch (this) {
      case OfferStatus.draft:
        return const Color(0xFF424242);
      case OfferStatus.pendingValidation:
        return const Color(0xFF000000);
      case OfferStatus.active:
        return const Color(0xFF000000);
      case OfferStatus.rejected:
        return const Color(0xFF757575);
      case OfferStatus.expired:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData get icon {
    switch (this) {
      case OfferStatus.draft:
        return Icons.edit_note;
      case OfferStatus.pendingValidation:
        return Icons.hourglass_empty;
      case OfferStatus.active:
        return Icons.check_circle;
      case OfferStatus.rejected:
        return Icons.cancel;
      case OfferStatus.expired:
        return Icons.schedule;
    }
  }
}
