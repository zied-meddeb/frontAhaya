import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/offer_provider.dart';
import '../models/offer.dart';
import '../theme/app_theme.dart';
import '../widgets/step_indicator.dart';
import '../widgets/gradient_button.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _isSubmitting = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _promotionalPriceController = TextEditingController();
  final _videoLinkController = TextEditingController();

  String _selectedCategory = '';
  String _selectedCountry = '';
  String _selectedRegion = '';
  DateTime? _promotionEndDate;
  DateTime? _displayPeriodStart;
  DateTime? _displayPeriodEnd;

  final List<String> _categories = [
    'Restaurant',
    'Hôtel',
    'Spa & Bien-être',
    'Activités',
    'Shopping',
    'Transport',
    'Divertissement'
  ];

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

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
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
          // Progress Header
          _buildProgressHeader(),
          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildBasicInfoStep(),
                _buildLocationStep(),
                _buildPricingStep(),
                _buildMediaTimingStep(),
              ],
            ),
          ),
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

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
                      'Créer une Nouvelle Offre',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note, size: 16),
                    SizedBox(width: 4),
                    Text('Brouillon'),
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
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value ?? ''),
                validator: (value) => value == null ? 'Catégorie requise' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de l\'offre *',
                  prefixIcon: Icon(Icons.title),
                  hintText: 'Ex: Restaurant Dar Zarrouk - Menu traditionnel tunisien',
                ),
                validator: (value) => value?.isEmpty == true ? 'Titre requis' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Décrivez votre offre en détail...',
                ),
                validator: (value) => value?.isEmpty == true ? 'Description requise' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Image Upload Placeholder
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[300]!, width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[50],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload, size: 40, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Téléchargez votre image', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('PNG, JPG jusqu\'à 5MB', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
              
              // Discount Calculator
              if (_originalPriceController.text.isNotEmpty && _promotionalPriceController.text.isNotEmpty)
                _buildDiscountCalculator(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildMediaTimingStep() {
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
                    child: const Icon(Icons.video_library, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Média et Planification',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _videoLinkController,
                decoration: const InputDecoration(
                  labelText: 'Lien vidéo (optionnel)',
                  prefixIcon: Icon(Icons.video_call),
                  hintText: 'https://youtube.com/watch?v=...',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Date fields
              _buildDateField(
                'Fin de la promotion *',
                _promotionEndDate,
                (date) => setState(() => _promotionEndDate = date),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      'Début d\'affichage *',
                      _displayPeriodStart,
                      (date) => setState(() => _displayPeriodStart = date),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      'Fin d\'affichage *',
                      _displayPeriodEnd,
                      (date) => setState(() => _displayPeriodEnd = date),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                              Text('Créer l\'offre', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }

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

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _selectedCategory.isNotEmpty &&
               _titleController.text.isNotEmpty &&
               _descriptionController.text.isNotEmpty;
      case 1:
        return _selectedCountry.isNotEmpty &&
               _selectedRegion.isNotEmpty &&
               _locationController.text.isNotEmpty;
      case 2:
        final original = double.tryParse(_originalPriceController.text);
        final promotional = double.tryParse(_promotionalPriceController.text);
        return original != null &&
               promotional != null &&
               promotional < original;
      case 3:
        return _promotionEndDate != null &&
               _displayPeriodStart != null &&
               _displayPeriodEnd != null;
      default:
        return false;
    }
  }

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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final newOffer = Offer(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        category: _selectedCategory,
        description: _descriptionController.text,
        location: _locationController.text,
        country: _selectedCountry,
        region: _selectedRegion,
        originalPrice: double.parse(_originalPriceController.text),
        promotionalPrice: double.parse(_promotionalPriceController.text),
        status: OfferStatus.pendingValidation,
        endDate: _promotionEndDate!,
        displayPeriodStart: _displayPeriodStart!,
        displayPeriodEnd: _displayPeriodEnd!,
        videoLink: _videoLinkController.text.isEmpty ? null : _videoLinkController.text,
        createdAt: DateTime.now(),
        submittedAt: DateTime.now(),
      );

      await context.read<OfferProvider>().addOffer(newOffer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎉 Offre soumise avec succès !', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Votre offre "${_titleController.text}" est en attente de validation.'),
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
          const SnackBar(
            content: Text('Une erreur est survenue lors de la création de l\'offre'),
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

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _originalPriceController.clear();
    _promotionalPriceController.clear();
    _videoLinkController.clear();
    
    setState(() {
      _selectedCategory = '';
      _selectedCountry = '';
      _selectedRegion = '';
      _promotionEndDate = null;
      _displayPeriodStart = null;
      _displayPeriodEnd = null;
      _currentStep = 0;
    });
    
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
