import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/offer.dart';

class OfferProvider with ChangeNotifier {
  List<Offer> _offers = [];
  bool _isLoading = false;
  String _searchTerm = '';
  OfferStatus? _filterStatus;

  List<Offer> get offers => _offers;
  bool get isLoading => _isLoading;
  String get searchTerm => _searchTerm;
  OfferStatus? get filterStatus => _filterStatus;

  List<Offer> get filteredOffers {
    return _offers.where((offer) {
      final matchesSearch = offer.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          offer.category.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          offer.location.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          offer.region.toLowerCase().contains(_searchTerm.toLowerCase());

      final matchesFilter = _filterStatus == null || offer.status == _filterStatus;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Statistiques
  int get totalOffers => _offers.length;
  int get activeOffers => _offers.where((o) => o.status == OfferStatus.active).length;
  int get pendingOffers => _offers.where((o) => o.status == OfferStatus.pendingValidation).length;
  int get rejectedOffers => _offers.where((o) => o.status == OfferStatus.rejected).length;
  int get totalViews => _offers.fold(0, (sum, offer) => sum + offer.views);
  int get totalBookings => _offers.fold(0, (sum, offer) => sum + offer.bookings);

  OfferProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadOffers();
    if (_offers.isEmpty) {
      await _createSampleData();
    }
  }

  Future<void> _createSampleData() async {
    final sampleOffers = [
      Offer(
        id: 1,
        title: 'Restaurant Dar Zarrouk - Menu traditionnel tunisien',
        category: 'Restaurant',
        description: 'Découvrez la cuisine tunisienne authentique avec couscous royal, tajine d\'agneau et pâtisseries orientales dans un cadre traditionnel.',
        location: 'Sidi Bou Saïd',
        country: 'Tunisie',
        region: 'Tunis',
        originalPrice: 45.0,
        promotionalPrice: 32.0,
        status: OfferStatus.active,
        views: 1834,
        bookings: 67,
        rating: 4.8,
        endDate: DateTime.now().add(const Duration(days: 45)),
        displayPeriodStart: DateTime.now().subtract(const Duration(days: 30)),
        displayPeriodEnd: DateTime.now().add(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        submittedAt: DateTime.now().subtract(const Duration(days: 29)),
        validatedAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      Offer(
        id: 2,
        title: 'Spa Thalasso Sousse - Massage aux huiles d\'argan',
        category: 'Spa & Bien-être',
        description: 'Massage relaxant de 90 minutes aux huiles d\'argan bio dans notre centre thalasso face à la mer.',
        location: 'Port El Kantaoui',
        country: 'Tunisie',
        region: 'Sousse',
        originalPrice: 80.0,
        promotionalPrice: 55.0,
        status: OfferStatus.pendingValidation,
        endDate: DateTime.now().add(const Duration(days: 20)),
        displayPeriodStart: DateTime.now(),
        displayPeriodEnd: DateTime.now().add(const Duration(days: 20)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Offer(
        id: 3,
        title: 'Hôtel Villa Didon - Nuit romantique avec vue sur Carthage',
        category: 'Hôtel',
        description: 'Séjour romantique dans notre suite avec vue panoramique sur les ruines de Carthage, petit-déjeuner continental inclus.',
        location: 'Carthage',
        country: 'Tunisie',
        region: 'Tunis',
        originalPrice: 180.0,
        promotionalPrice: 135.0,
        status: OfferStatus.rejected,
        endDate: DateTime.now().add(const Duration(days: 10)),
        displayPeriodStart: DateTime.now(),
        displayPeriodEnd: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        submittedAt: DateTime.now().subtract(const Duration(days: 4)),
        validatedAt: DateTime.now().subtract(const Duration(days: 3)),
        rejectionReason: 'Les photos fournies ne correspondent pas aux standards de qualité requis. Veuillez fournir des images haute résolution.',
      ),
    ];

    _offers = sampleOffers;
    await saveOffers();
    notifyListeners();
  }

  Future<void> loadOffers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final offersJson = prefs.getString('supplier_offers');

      if (offersJson != null) {
        final List<dynamic> offersList = json.decode(offersJson);
        _offers = offersList.map((json) => Offer.fromJson(json)).toList();

        // Mettre à jour les statuts expirés
        _updateExpiredOffers();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des offres: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveOffers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offersJson = json.encode(_offers.map((offer) => offer.toJson()).toList());
      await prefs.setString('supplier_offers', offersJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des offres: $e');
    }
  }

  void _updateExpiredOffers() {
    bool hasChanges = false;
    for (int i = 0; i < _offers.length; i++) {
      if (_offers[i].isExpired && _offers[i].status == OfferStatus.active) {
        _offers[i] = _offers[i].copyWith(status: OfferStatus.expired);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      saveOffers();
    }
  }

  Future<void> addOffer(Offer offer) async {
    _offers.add(offer);
    await saveOffers();
    notifyListeners();
  }

  Future<void> updateOffer(Offer updatedOffer) async {
    final index = _offers.indexWhere((offer) => offer.id == updatedOffer.id);
    if (index != -1) {
      _offers[index] = updatedOffer;
      await saveOffers();
      notifyListeners();
    }
  }

  Future<void> deleteOffer(int offerId) async {
    _offers.removeWhere((offer) => offer.id == offerId);
    await saveOffers();
    notifyListeners();
  }

  Future<void> simulateValidation(int offerId, bool approve) async {
    final index = _offers.indexWhere((offer) => offer.id == offerId);
    if (index != -1) {
      _offers[index] = _offers[index].copyWith(
        status: approve ? OfferStatus.active : OfferStatus.rejected,
        validatedAt: DateTime.now(),
        rejectionReason: approve ? null : 'L\'offre ne respecte pas nos standards de qualité.',
      );
      await saveOffers();
      notifyListeners();
    }
  }

  Future<void> updateViews(int offerId) async {
    final index = _offers.indexWhere((offer) => offer.id == offerId);
    if (index != -1) {
      final additionalViews = (10 + (50 * (DateTime.now().millisecond / 1000))).round();
      _offers[index] = _offers[index].copyWith(views: _offers[index].views + additionalViews);
      await saveOffers();
      notifyListeners();
    }
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void setFilterStatus(OfferStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchTerm = '';
    _filterStatus = null;
    notifyListeners();
  }
}