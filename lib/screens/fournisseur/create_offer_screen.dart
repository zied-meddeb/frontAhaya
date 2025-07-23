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

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _promotionalPriceController = TextEditingController();
  final _videoLinkController = TextEditingController();
  final _newProductNameController = TextEditingController();
  final _newProductPriceController = TextEditingController();

  List<XFile> _selectedImages = [];
  List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  XFile? _newProductImage;

  String _selectedType = 'Biens';
  String _selectedCountry = '';
  String _selectedRegion = '';
  DateTime? _promotionStartDate;
  DateTime? _promotionEndDate;
  List<Map<String, dynamic>> _selectedProducts = [];

  final List<String> _types = ['Biens', 'Services'];
  final List<String> _countries = ['Tunisie'];
  final List<String> _tunisianGovernorates = [
    'Tunis', 'Ariana', 'Ben Arous', 'Manouba', 'Nabeul', 'Zaghouan',
    'Bizerte', 'Béja', 'Jendouba', 'Kef', 'Siliana', 'Sousse',
    'Monastir', 'Mahdia', 'Sfax', 'Kairouan', 'Kasserine', 'Sidi Bouzid',
    'Gabès', 'Médenine', 'Tataouine', 'Gafsa', 'Tozeur', 'Kebili',
  ];
  List<Map<String, dynamic>> _products = [];

  final PromotionService _promotionService = PromotionService();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      const fournisseurId = 'your-fournisseur-id';
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
      await showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImages.add(image);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir dans la galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile>? images = await _picker.pickMultiImage(
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (images != null && images.isNotEmpty) {
                    List<XFile> validImages = [];
                    for (var image in images) {
                      final file = File(image.path);
                      final sizeInBytes = await file.length();
                      final sizeInMB = sizeInBytes / (1024 * 1024);
                      if (sizeInMB <= 5) {
                        validImages.add(image);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Image ${image.name} dépasse la limite de 5MB'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                    setState(() {
                      _selectedImages.addAll(validImages);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection des images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickProductImage() async {
    try {
      await showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (image != null) {
                    setState(() {
                      _newProductImage = image;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir dans la galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (image != null) {
                    setState(() {
                      _newProductImage = image;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addNewProduct() {
    if (_newProductNameController.text.isNotEmpty &&
        _newProductPriceController.text.isNotEmpty) {
      setState(() {
        _selectedProducts.add({
          'id': 'manual_${DateTime.now().millisecondsSinceEpoch}',
          'name': _newProductNameController.text,
          'price': double.parse(_newProductPriceController.text),
          'image': _newProductImage?.path,
          'isManual': true,
        });
        _newProductNameController.clear();
        _newProductPriceController.clear();
        _newProductImage = null;
        _updateOriginalPrice();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir le nom et le prix du produit'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateOriginalPrice() {
    final totalPrice = _selectedProducts.fold<double>(
      0,
          (sum, product) => sum + (product['price'] as double),
    );
    _originalPriceController.text = totalPrice.toStringAsFixed(2);
  }

  Future<void> _showProductSelectionBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Sélectionner des produits',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _products.isEmpty
                  ? const Center(child: Text('Aucun produit disponible'))
                  : ListView.builder(
                controller: scrollController,
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  final isSelected = _selectedProducts.any((p) => p['id'] == product['id']);
                  return CheckboxListTile(
                    title: Text(product['name']),
                    subtitle: Text('${product['price']} DT'),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedProducts.add(product);
                        } else {
                          _selectedProducts.removeWhere((p) => p['id'] == product['id']);
                        }
                        _updateOriginalPrice();
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GradientButton(
                onPressed: () => Navigator.pop(context),
                gradient: SupplierTheme.blueGradient,
                child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _originalPriceController.dispose();
    _promotionalPriceController.dispose();
    _videoLinkController.dispose();
    _newProductNameController.dispose();
    _newProductPriceController.dispose();
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
                _buildProductSelectionStep(),
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

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                          Text('Téléchargez vos images *', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildProductSelectionStep() {
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
                        colors: [Colors.blue[400]!, Colors.cyan[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_bag, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Produits de la Promotion',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Manual Product Entry
              const Text(
                'Ajouter un nouveau produit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newProductNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit *',
                  prefixIcon: Icon(Icons.label),
                  hintText: 'Iphone 15, Samsung S21...',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newProductPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix du produit (DT) *',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '99.99',
                ),
                onChanged: (value) => _updateOriginalPrice(),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickProductImage,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue[300]!, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue[50],
                  ),
                  child: _newProductImage == null
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 30, color: Colors.blue),
                        SizedBox(height: 8),
                        Text('Ajouter une image (optionnel)', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                      : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_newProductImage!.path),
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _newProductImage = null),
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
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                onPressed: _addNewProduct,
                gradient: SupplierTheme.blueGradient,
                child: const Text('Ajouter le produit', style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 24),

              // Existing Products Selection
              const Text(
                'Ou sélectionner des produits existants',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              GradientButton(
                onPressed: _showProductSelectionBottomSheet,
                gradient: SupplierTheme.blueGradient,
                child: const Text('Choisir des produits', style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 24),

              // Selected Products Display
              if (_selectedProducts.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produits sélectionnés',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedProducts.length,
                        itemBuilder: (context, index) {
                          final product = _selectedProducts[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      if (product['image'] != null)
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                          child: product['isManual'] == true
                                              ? Image.file(
                                            File(product['image']),
                                            height: 60,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          )
                                              : Image.network(
                                            product['image'],
                                            height: 60,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else
                                        Container(
                                          height: 60,
                                          width: 100,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          product['name'],
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedProducts.removeAt(index);
                                      _updateOriginalPrice();
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
              Column(
                children: [
                  TextFormField(
                    controller: _originalPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prix original (DT) *',
                      prefixIcon: Icon(Icons.price_change),
                      hintText: 'Somme des prix des produits',
                    ),
                    enabled: false,
                    validator: (value) => value?.isEmpty == true ? 'Prix original requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
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

              _buildDateField(
                "Fin de l'affiche *",
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
                  Text('Créer la promotion', style: TextStyle(color: Colors.white)),
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
        return _selectedType.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            _selectedImages.isNotEmpty;
      case 1:
        return _selectedCountry.isNotEmpty &&
            _selectedRegion.isNotEmpty &&
            _locationController.text.isNotEmpty;
      case 2:
        return _selectedProducts.isNotEmpty;
      case 3:
        final original = double.tryParse(_originalPriceController.text);
        final promotional = double.tryParse(_promotionalPriceController.text);
        return original != null &&
            promotional != null &&
            promotional < original;
      case 4:
        return _promotionStartDate != null && _promotionEndDate != null;
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
      final promotion = Promotion(
        type: _selectedType,
        description: _descriptionController.text,
        prixOriginal: double.parse(_originalPriceController.text),
        prixOffre: double.parse(_promotionalPriceController.text),
        dateDebut: _promotionStartDate!,
        dateFin: _promotionEndDate!,
        produits: _selectedProducts.map((p) => p['id']).toList(),
      );

      final createdPromotion = await _promotionService.createPromotion(promotion);

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

  void _resetForm() {
    _descriptionController.clear();
    _locationController.clear();
    _originalPriceController.clear();
    _promotionalPriceController.clear();
    _videoLinkController.clear();
    _newProductNameController.clear();
    _newProductPriceController.clear();

    setState(() {
      _selectedType = 'Biens';
      _selectedCountry = '';
      _selectedRegion = '';
      _promotionStartDate = null;
      _promotionEndDate = null;
      _selectedProducts = [];
      _selectedImages = [];
      _imageUrls = [];
      _newProductImage = null;
      _currentStep = 0;
    });

    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}