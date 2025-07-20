import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/offer.dart';
import '../../providers/offer_provider.dart';
import '../../models/promotion.dart';
import '../../services/promotion_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/gradient_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4; // Includes basic info, location, pricing, product selection, timing
  bool _isSubmitting = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _promotionalPriceController = TextEditingController();
  final _videoLinkController = TextEditingController();

  List<XFile> _selectedImages = []; // Store selected images
  List<String> _imageUrls = []; // Store uploaded image URLs
  final ImagePicker _picker = ImagePicker();

  String _selectedType = 'Biens';
  String _selectedCountry = '';
  String _selectedRegion = '';
  DateTime? _promotionStartDate;
  DateTime? _promotionEndDate;
  List<String> _selectedProductIds = [];

  final List<String> _types = ['Biens', 'Services'];
  final List<String> _countries = [
    'Tunisie',
    'Maroc',
    'Algérie',
    'Libye',
    'France',
    'Italie',
    'Allemagne'
  ];
  final List<String> _tunisianGovernorates = [
    'Tunis', 'Ariana', 'Ben Arous', 'Manouba', 'Nabeul', 'Zaghouan',
    'Bizerte', 'Béja', 'Jendouba', 'Kef', 'Siliana', 'Sousse',
    'Monastir', 'Mahdia', 'Sfax', 'Kairouan', 'Kasserine', 'Sidi Bouzid',
    'Gabès', 'Médenine', 'Tataouine', 'Gafsa', 'Tozeur', 'Kebili',
  ];
  List<Map<String, dynamic>> _products = [];

  // Initialize PromotionService with authentication token
  final PromotionService _promotionService = PromotionService(); // Replace with actual token

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Fetch products for the fournisseur
  Future<void> _fetchProducts() async {
    try {
      const fournisseurId = 'your-fournisseur-id'; // Replace with actual fournisseur ID
      final products = await _promotionService.fetchProducts(fournisseurId);
      setState(() {
        _products = products;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des produits: $e')),
      );
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (images != null && images.isNotEmpty) {
        List<XFile> processedImages = [];
        for (var image in images) {
          if (image.mimeType == 'image/png') {
            final compressedFile = await FlutterImageCompress.compressAndGetFile(
              image.path,
              image.path.replaceAll('.png', '_compressed.png'),
              minWidth: 1920,
              minHeight: 1920,
            );
            processedImages.add(compressedFile != null ? XFile(compressedFile.path, mimeType: 'image/png') : image);
          } else {
            processedImages.add(image);
          }
        }
        setState(() {
          _selectedImages.addAll(processedImages.where((img) => img.mimeType == 'image/jpeg' || img.mimeType == 'image/png'));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection des images: $e')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _originalPriceController.dispose();
    _promotionalPriceController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildBasicInfoStep(),
                _buildLocationStep(),
                _buildPricingStep(),
                _buildTimingStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // Build the progress header with step indicator
  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Créer une Nouvelle Promotion',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Étape ${_currentStep + 1} sur $_totalSteps',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
          const SizedBox(height: 16),
          StepIndicator(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
        ],
      ),
    );
  }

  // Basic information step (type and description)
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: SupplierTheme.blueGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Informations de Base',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type de promotion *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _types.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) => setState(() => _selectedType = value ?? 'Biens'),
                validator: (value) => value == null ? 'Type requis' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Nom Produit',
                  prefixIcon: Icon(Icons.place),
                  hintText: 'Iphone 15, Samsung S21..',
                ),
                validator: (value) => value?.isEmpty == true ? 'Nom requis' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Décrivez votre promotion en détail...',
                ),
                validator: (value) => value?.isEmpty == true ? 'Description requise' : null,
              ),
              const SizedBox(height: 16),

              // Image Upload Section
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[50],
                ),
                child: _selectedImages.isEmpty
                    ? InkWell(
                  onTap: _pickImages,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 40, color: Colors.blue),
                        SizedBox(height: 8),
                        Text('Téléchargez vos images', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('PNG, JPG jusqu\'à 5MB', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return InkWell(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.add_photo_alternate, color: Colors.blue),
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedImages.removeAt(index);
                              }),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Location step (country, governorate, specific location)
  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: SupplierTheme.emeraldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Localisation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCountry.isEmpty ? null : _selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'Pays *',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: _countries.map((country) => DropdownMenuItem(
                      value: country,
                      child: Text('🇹🇳 $country'),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedCountry = value ?? ''),
                    validator: (value) => value == null ? 'Pays requis' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRegion.isEmpty ? null : _selectedRegion,
                    decoration: const InputDecoration(
                      labelText: 'Gouvernorat *',
                      prefixIcon: Icon(Icons.map),
                    ),
                    items: _tunisianGovernorates.map((gov) => DropdownMenuItem(
                      value: gov,
                      child: Text(gov),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedRegion = value ?? ''),
                    validator: (value) => value == null ? 'Gouvernorat requis' : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu précis *',
                  prefixIcon: Icon(Icons.place),
                  hintText: 'Ex: Sidi Bou Saïd, La Marsa, Centre-ville',
                ),
                validator: (value) => value?.isEmpty == true ? 'Lieu requis' : null,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[50]!, Colors.blue[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💡 Conseil', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Plus votre localisation est précise, plus il sera facile pour les clients tunisiens de vous trouver.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pricing step (original and promotional price)
  Widget _buildPricingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[400]!, Colors.pink[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.attach_money, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Tarification',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix original (DT) *',
                        prefixIcon: Icon(Icons.price_change),
                        hintText: '50',
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Prix original requis' : null,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _promotionalPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix promotionnel (DT) *',
                        prefixIcon: Icon(Icons.local_offer),
                        hintText: '35',
                      ),
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Prix promotionnel requis';
                        final original = double.tryParse(_originalPriceController.text);
                        final promotional = double.tryParse(value!);
                        if (original != null && promotional != null && promotional >= original) {
                          return 'Le prix promotionnel doit être inférieur au prix original';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (_originalPriceController.text.isNotEmpty && _promotionalPriceController.text.isNotEmpty)
                _buildDiscountCalculator(),
            ],
          ),
        ),
      ),
    );
  }

  // Discount calculator for pricing step
  Widget _buildDiscountCalculator() {
    final original = double.tryParse(_originalPriceController.text);
    final promotional = double.tryParse(_promotionalPriceController.text);

    if (original == null || promotional == null || promotional >= original) {
      return const SizedBox.shrink();
    }

    final discountPercent = ((original - promotional) / original * 100).round();
    final savings = original - promotional;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[100]!, Colors.green[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Réduction calculée',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  'Économie pour le client',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$discountPercent%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              Text(
                '-${savings.toStringAsFixed(1)} DT',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Timing step (start and end dates)
  Widget _buildTimingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: SupplierTheme.orangeGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Planification',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildDateField(
                'Début de la promotion *',
                _promotionStartDate,
                    (date) => setState(() => _promotionStartDate = date),
              ),

              const SizedBox(height: 16),

              _buildDateField(
                'Fin de la promotion *',
                _promotionEndDate,
                    (date) => setState(() => _promotionEndDate = date),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _videoLinkController,
                decoration: const InputDecoration(
                  labelText: 'Lien vidéo (optionnel)',
                  prefixIcon: Icon(Icons.video_call),
                  hintText: 'https://youtube.com/watch?v=...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Date picker field
  Widget _buildDateField(String label, DateTime? value, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onChanged(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? '${value.day}/${value.month}/${value.year}'
              : 'Sélectionner une date',
          style: TextStyle(
            color: value != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  // Navigation buttons (Previous/Next/Submit)
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Précédent'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _currentStep < _totalSteps - 1
                ? GradientButton(
              onPressed: _nextStep,
              gradient: SupplierTheme.blueGradient,
              child: const Text('Suivant', style: TextStyle(color: Colors.white)),
            )
                : GradientButton(
              onPressed: _isSubmitting ? null : _submitOffer,
              gradient: SupplierTheme.emeraldGradient,
              child: _isSubmitting
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Création...', style: TextStyle(color: Colors.white)),
                ],
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Créer la promotion', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handle next step navigation with validation
  void _nextStep() {
    if (_validateCurrentStep()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Étape ${_currentStep + 1} validée ✅'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs avant de continuer'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Validate the current step
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Info
        return _selectedType.isNotEmpty && _descriptionController.text.isNotEmpty;
      case 1: // Location
        return _selectedCountry.isNotEmpty &&
            _selectedRegion.isNotEmpty &&
            _locationController.text.isNotEmpty;
      case 2: // Pricing
        final original = double.tryParse(_originalPriceController.text);
        final promotional = double.tryParse(_promotionalPriceController.text);
        return original != null &&
            promotional != null &&
            promotional < original;
      case 3: // Product Selection
        return _selectedProductIds.isNotEmpty; // Require at least one product
      case 4: // Timing
        return _promotionStartDate != null && _promotionEndDate != null;
      default:
        return false;
    }
  }

  // Submit the promotion to the backend
  Future<void> _submitOffer() async {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs avant de continuer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final promotion = Promotion(
        type: _selectedType,
        description: _descriptionController.text,
        prixOriginal: double.parse(_originalPriceController.text),
        prixOffre: double.parse(_promotionalPriceController.text),
        dateDebut: _promotionStartDate!,
        dateFin: _promotionEndDate!,
        produits: _selectedProductIds.isNotEmpty ? _selectedProductIds : null,
      );

      final createdPromotion = await _promotionService.createPromotion(promotion);

      // Update OfferProvider if needed
      await context.read<OfferProvider>().addOffer(createdPromotion as Offer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎉 Promotion soumise avec succès !', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Votre promotion "${_descriptionController.text}" est en attente de validation.'),
                const Text('Vous recevrez une notification une fois approuvée.'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de la promotion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Reset the form after submission
  void _resetForm() {
    _descriptionController.clear();
    _locationController.clear();
    _originalPriceController.clear();
    _promotionalPriceController.clear();
    _videoLinkController.clear();

    setState(() {
      _selectedType = 'Biens';
      _selectedCountry = '';
      _selectedRegion = '';
      _promotionStartDate = null;
      _promotionEndDate = null;
      _selectedProductIds = [];
      _currentStep = 0;
    });

    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}