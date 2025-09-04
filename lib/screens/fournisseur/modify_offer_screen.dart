import 'package:flutter/material.dart';
import 'package:shop/services/categorie_service.dart';
import '../../models/promotion.dart';
import '../../services/promotion_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/gradient_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ModifyOfferScreen extends StatefulWidget {
  final String? promotionId;

  const ModifyOfferScreen({super.key, this.promotionId});

  @override
  State<ModifyOfferScreen> createState() => _ModifyOfferScreenState();
}

class _ModifyOfferScreenState extends State<ModifyOfferScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;
  bool _isSubmitting = false;
  bool _isLoading = true;
  Promotion? _promotion;

  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _promotionalPriceController = TextEditingController();
  final _videoLinkController = TextEditingController();
  final _newProductNameController = TextEditingController();
  final _newProductPriceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _newProductImage;

  String _selectedType = 'Biens';
  String _selectedCountry = '';
  String _selectedRegion = '';
  DateTime? _promotionStartDate;
  DateTime? _promotionEndDate;
  DateTime? _afficheEndDate;
  List<Map<String, dynamic>> _selectedProducts = [];
  List<String> _affichesToRemove = [];

  final List<String> _types = ['Biens', 'Services'];
  final List<String> _countries = ['Tunisie'];
  final List<String> _tunisianGovernorates = [
    'Tunis', 'Ariana', 'Ben Arous', 'Manouba', 'Nabeul', 'Zaghouan',
    'Bizerte', 'Béja', 'Jendouba', 'Kef', 'Siliana', 'Sousse',
    'Monastir', 'Mahdia', 'Sfax', 'Kairouan', 'Kasserine', 'Sidi Bouzid',
    'Gabès', 'Médenine', 'Tataouine', 'Gafsa', 'Tozeur', 'Kebili',
  ];
  List<Map<String, dynamic>> _products = [];
  List<dynamic> _categories = [];
  String? _selectedCategoryId;

  final PromotionService _promotionService = PromotionService();
  final CategoriesService _categoriesService = CategoriesService();
  final AuthService _authService = AuthService();
  List<XFile> _afficheImages = [];

  // Cache for image bytes to prevent blinking
  final Map<String, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _fetchPromotionData();
    _fetchCategories();
  }

  Future<void> _fetchPromotionData() async {
    try {
      final promotionData = await _promotionService.fetchPromotionById(widget.promotionId);
      if (promotionData.isNotEmpty) {
        setState(() {
          _promotion = Promotion.fromJson(promotionData);
          _initializeForm();
          _products = List<Map<String, dynamic>>.from(promotionData['produits'] ?? []);
          _selectedProducts = List<Map<String, dynamic>>.from(promotionData['produits'] ?? []);
          _isLoading = false;
        });
        _updateOriginalPrice();
      } else {
        throw Exception('Promotion not found');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement de la promotion: $e')),
      );
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoriesService.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des catégories: $e')),
      );
    }
  }

  void _initializeForm() {
    if (_promotion == null) return;
    final promotion = _promotion!;
    _titreController.text = promotion.titre;
    _descriptionController.text = promotion.description;
    _originalPriceController.text = promotion.prixOriginal.toStringAsFixed(2);
    _promotionalPriceController.text = promotion.prixOffre.toStringAsFixed(2);
    _selectedType = promotion.type;
    _promotionStartDate = promotion.dateDebut;
    _promotionEndDate = promotion.dateFin;
    _afficheEndDate = promotion.dateAffiche;

    final locationParts = ["Tunisie", "Ariana", "Test"];
    if (locationParts.length >= 3) {
      _selectedCountry = locationParts[0];
      _selectedRegion = locationParts[1];
      _locationController.text = locationParts[2];
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final fournisseurId = await _authService.getUserId();
      if (fournisseurId != null) {
        final products = await _promotionService.fetchProductsByFournisseur(fournisseurId);
        setState(() {
          _products = products;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des produits: $e')),
      );
    }
  }

  Widget _buildImageFromXFile(XFile imageFile, {required double width, required double height, BoxFit fit = BoxFit.cover}) {
    final cacheKey = imageFile.path;

    // Check if image bytes are already cached
    if (_imageCache.containsKey(cacheKey)) {
      return Image.memory(
        _imageCache[cacheKey]!,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return FutureBuilder<Uint8List>(
      future: imageFile.readAsBytes().then((bytes) {
        // Cache the bytes after reading
        _imageCache[cacheKey] = bytes;
        return bytes;
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
          );
        } else if (snapshot.hasError) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          );
        } else {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Future<void> _pickAfficheImage() async {
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
                      _afficheImages.add(image);
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
                      _afficheImages.add(image);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choisir plusieurs images'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile> images = await _picker.pickMultiImage(
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (images.isNotEmpty) {
                    setState(() {
                      _afficheImages.addAll(images);
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

  void _removeAfficheImage(int index) {
    setState(() {
      final removedImage = _afficheImages.removeAt(index);
      _imageCache.remove(removedImage.path); // Clear cache for removed image
    });
  }

  void _markAfficheUrlForRemoval(String url) {
    setState(() {
      _affichesToRemove.add(url);
    });
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
        _newProductPriceController.text.isNotEmpty &&
        _selectedCategoryId != null) {
      setState(() {
        _selectedProducts.add({
          '_id': 'manual_${DateTime.now().millisecondsSinceEpoch}',
          'nom': _newProductNameController.text,
          'name': _newProductNameController.text,
          'prix': double.parse(_newProductPriceController.text),
          'description': _newProductNameController.text,
          'imageFile': _newProductImage,
          'image': _newProductImage?.path,
          'imageUrl': _newProductImage?.path,
          'category': _selectedCategoryId,
          'isManual': true,
          'verified': false,
          'views': 0,
          'tags': [_selectedType.toLowerCase()],
          'fournisseur': _authService.getUserId(),
        });
        _newProductNameController.clear();
        _newProductPriceController.clear();
        if (_newProductImage != null) {
          _imageCache.remove(_newProductImage!.path); // Clear cache for product image
        }
        _newProductImage = null;
        _selectedCategoryId = null;
        _updateOriginalPrice();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateOriginalPrice() {
    final totalPrice = _selectedProducts.fold<double>(
      0,
          (sum, product) {
        if (product['isManual'] == true) {
          return sum + (product['prix'] as double);
        } else {
          final price = product['prix'] ?? product['prix'] ?? 0;
          return sum + (price is String ? double.tryParse(price) ?? 0 : price.toDouble());
        }
      },
    );
    _originalPriceController.text = totalPrice.toStringAsFixed(2);
  }

  void _editProduct(int index) {
    final product = _selectedProducts[index];
    if (product['isManual'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seuls les produits manuels peuvent être modifiés'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _newProductNameController.text = product['nom'] ?? product['name'] ?? '';
    _newProductPriceController.text = product['prix'].toString();
    _newProductImage = product['imageFile'] as XFile?;
    final categoryId = product['category']?.toString();
    if (categoryId != null && _categories.any((cat) => cat['_id']?.toString() == categoryId)) {
      _selectedCategoryId = categoryId;
    } else {
      _selectedCategoryId = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le produit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newProductNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newProductPriceController,
                decoration: const InputDecoration(
                  labelText: 'Prix',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Catégorie *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.where((category) =>
                category['_id'] != null && category['_id'].toString().isNotEmpty
                ).map((category) {
                  return DropdownMenuItem<String>(
                    value: category['_id'].toString(),
                    child: Text(category['nom'] ?? category['name'] ?? 'Sans nom'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      if (_newProductImage != null) {
                        _imageCache.remove(_newProductImage!.path); // Clear cache for old product image
                      }
                      _newProductImage = pickedImage;
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: Text(_newProductImage != null ? 'Image sélectionnée' : 'Sélectionner une image'),
              ),
              if (_newProductImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildImageFromXFile(_newProductImage!, width: 100, height: 100),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newProductNameController.clear();
              _newProductPriceController.clear();
              if (_newProductImage != null) {
                _imageCache.remove(_newProductImage!.path); // Clear cache
              }
              _newProductImage = null;
              _selectedCategoryId = null;
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_newProductNameController.text.isNotEmpty &&
                  _newProductPriceController.text.isNotEmpty &&
                  _selectedCategoryId != null) {
                setState(() {
                  if (product['imageFile'] != null && product['imageFile'] != _newProductImage) {
                    _imageCache.remove((product['imageFile'] as XFile).path); // Clear cache for old image
                  }
                  _selectedProducts[index] = {
                    '_id': product['_id'] ?? product['id'],
                    'nom': _newProductNameController.text,
                    'name': _newProductNameController.text,
                    'prix': double.parse(_newProductPriceController.text),
                    'description': _newProductNameController.text,
                    'imageFile': _newProductImage,
                    'image': _newProductImage?.path,
                    'imageUrl': _newProductImage?.path,
                    'category': _selectedCategoryId,
                    'isManual': true,
                    'verified': false,
                    'views': 0,
                    'tags': [_selectedType.toLowerCase()],
                    'fournisseur': product['fournisseur'] ?? _authService.getUserId(),
                  };
                  _updateOriginalPrice();
                });

                Navigator.of(context).pop();

                _newProductNameController.clear();
                _newProductPriceController.clear();
                if (_newProductImage != null) {
                  _imageCache.remove(_newProductImage!.path); // Clear cache
                }
                _newProductImage = null;
                _selectedCategoryId = null;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produit modifié avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs obligatoires'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.cyan[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_basket, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sélectionner des produits',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _products.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Aucun produit disponible',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              )
                  : Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final isSelected = _selectedProducts.any((p) => p['_id'] == product['_id']);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedProducts.removeWhere((p) => p['_id'] == product['_id']);
                          } else {
                            _selectedProducts.add(product);
                          }
                          _updateOriginalPrice();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: product['imageUrl'] != null
                                          ? Image.network(
                                        product['imageUrl'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.image_not_supported,
                                                color: Colors.grey, size: 32),
                                          ),
                                        ),
                                      )
                                          : Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(Icons.image_not_supported,
                                              color: Colors.grey, size: 32),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['nom'] ?? product['name'] ?? 'Produit sans nom',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${product['prix'] ?? product['price'] ?? 'Prix non défini'} DT',
                                          style: TextStyle(
                                            color: Colors.blue[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            if (!isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    '${_selectedProducts.length} produit(s) sélectionné(s)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GradientButton(
                    onPressed: () => Navigator.pop(context),
                    gradient: SupplierTheme.blueGradient,
                    child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
                  ),
                ],
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
    _titreController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _originalPriceController.dispose();
    _promotionalPriceController.dispose();
    _videoLinkController.dispose();
    _newProductNameController.dispose();
    _newProductPriceController.dispose();
    _imageCache.clear(); // Clear cache on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_promotion == null) {
      return Scaffold(
        body: Center(
          child: Text('Erreur: Promotion non trouvée'),
        ),
      );
    }
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
                      'Modifier une Promotion',
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
                  controller: _titreController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    prefixIcon: Icon(Icons.title),
                    hintText: 'Titre de la promotion...',
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Titre requis' : null,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Images de promotion *',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_afficheImages.isNotEmpty) ...[
                      Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _afficheImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildImageFromXFile(
                                      _afficheImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeAfficheImage(index),
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
                      const SizedBox(height: 8),
                    ],
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[300]!, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue[50],
                      ),
                      child: InkWell(
                        onTap: _pickAfficheImage,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40, color: Colors.blue),
                              SizedBox(height: 8),
                              Text('Ajouter des images de promotion *', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('Vous pouvez ajouter plusieurs images', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_promotion?.afficheUrls != null && _promotion!.afficheUrls.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Images existantes',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _promotion!.afficheUrls.length,
                              itemBuilder: (context, index) {
                                final url = _promotion!.afficheUrls[index];
                                final isMarkedForRemoval = _affichesToRemove.contains(url);
                                if (isMarkedForRemoval) return SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          url,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: Icon(Icons.image_not_supported, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _markAfficheUrlForRemoval(url),
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
              const Text(
                'Ajouter un nouveau produit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Catégorie *',
                  prefixIcon: Icon(Icons.category),
                  hintText: 'Sélectionnez une catégorie',
                ),
                items: _categories.where((category) =>
                category['_id'] != null && category['_id'].toString().isNotEmpty
                ).map((category) {
                  return DropdownMenuItem<String>(
                    value: category['_id'].toString(),
                    child: Text(category['nom'] ?? category['name'] ?? 'Sans nom'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
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
                        child: _buildImageFromXFile(
                          _newProductImage!,
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            if (_newProductImage != null) {
                              _imageCache.remove(_newProductImage!.path); // Clear cache
                            }
                            _newProductImage = null;
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
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                onPressed: _addNewProduct,
                gradient: SupplierTheme.blueGradient,
                child: const Text('Ajouter le produit', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 24),
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
                                GestureDetector(
                                  onTap: () => _editProduct(index),
                                  child: Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        if (product['image'] != null || product['imageUrl'] != null || product['imageFile'] != null)
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                            child: product['isManual'] == true && product['imageFile'] != null
                                                ? _buildImageFromXFile(
                                              product['imageFile'] as XFile,
                                              width: 100,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                                : Image.network(
                                              product['imageUrl'] ?? product['image'] ?? 'https://example.com/default.jpg',
                                              height: 60,
                                              width: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                height: 60,
                                                width: 100,
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                                                ),
                                              ),
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
                                            product['name'] ?? product['nom'] ?? 'Produit',
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      if (product['imageFile'] != null) {
                                        _imageCache.remove((product['imageFile'] as XFile).path); // Clear cache
                                      }
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
                'Date affichage',
                _afficheEndDate,
                    (date) => setState(() => _afficheEndDate = date),
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
                  Text('Modification...', style: TextStyle(color: Colors.white)),
                ],
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Modifier la promotion', style: TextStyle(color: Colors.white)),
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
            _titreController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            (_afficheImages.isNotEmpty || (_promotion!.afficheUrls.isNotEmpty && _affichesToRemove.length < _promotion!.afficheUrls.length));
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
        return _promotionStartDate != null &&
            _promotionEndDate != null &&
            _afficheEndDate != null;
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
      final fournisseurId = await _authService.getUserId();
      if (fournisseurId == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (_selectedProducts.isEmpty) {
        throw Exception('Au moins un produit doit être sélectionné');
      }

      if (_promotionStartDate == null || _promotionEndDate == null) {
        throw Exception('Les dates de début et fin sont requises');
      }

      print('DEBUG: Checking ${_selectedProducts.length} selected products');
      for (int i = 0; i < _selectedProducts.length; i++) {
        var product = _selectedProducts[i];
        print('DEBUG: Product $i: ${product.toString()}');
        if (product['category'] == null || product['category'].toString().isEmpty) {
          throw Exception('Une catégorie doit être sélectionnée pour tous les produits');
        }
      }

      List<XFile> manualProductImages = [];
      print('DEBUG: Collecting product images from ${_selectedProducts.length} products');
      for (var product in _selectedProducts) {
        print('DEBUG: Product ${product['name']} - hasImageFile: ${product['imageFile'] != null}');
        if (product['imageFile'] != null) {
          print('Adding product image: ${product['imageFile'].name}');
          manualProductImages.add(product['imageFile'] as XFile);
        }
      }

      print('Total product images collected: ${manualProductImages.length}');

      final List<Map<String, dynamic>> productsData = _selectedProducts.map((product) {
        return {
          'nom': product['nom'] ?? product['name'],
          'description': product['description'] ?? 'Produit ajouté pour la promotion: ${product['nom'] ?? product['name']}',
          'prix': product['prix'],
          'verified': false,
          'views': 0,
          'tags': product['tags'] ?? [_selectedType.toLowerCase()],
          'category': product['category'],
          'fournisseur': fournisseurId,
          'imageUrl': product['imageUrl'],
        };
      }).toList();

      final location = '${_locationController.text}, $_selectedRegion, $_selectedCountry';

      print('Updating promotion with:');
      print('Type: $_selectedType');
      print('Titre: ${_titreController.text}');
      print('Description: ${_descriptionController.text}');
      print('Products count: ${productsData.length}');
      print('Product images count: ${manualProductImages.length}');
      print('Location: $location');
      print('Original price: ${_originalPriceController.text}');
      print('Promotional price: ${_promotionalPriceController.text}');
      print('productsData: $productsData');
      print('Selected products raw: $_selectedProducts');
      print('Existing affiche URLs: ${_promotion!.afficheUrls}');
      print('Affiches to remove: $_affichesToRemove');

      final updatedPromotion = await _promotionService.updatePromotion(
        promotionId: widget.promotionId!,
        type: _selectedType,
        titre: _titreController.text,
        description: _descriptionController.text,
        prixOriginal: double.parse(_originalPriceController.text),
        prixOffre: double.parse(_promotionalPriceController.text),
        dateDebut: _promotionStartDate!,
        dateFin: _promotionEndDate!,
        fournisseurId: fournisseurId,
        statut: _promotion!.statut ?? 'ATT_VER',
        produits: productsData,
        afficheImages: _afficheImages,
        productImages: manualProductImages,
        dateAffiche: _afficheEndDate,
        existingAfficheUrls: _promotion!.afficheUrls.where((url) => !_affichesToRemove.contains(url)).toList(),
        //affichesToRemove: _affichesToRemove,
      );

      print('Promotion updated successfully: ${updatedPromotion.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Promotion mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Return the updated promotion
        Navigator.of(context).pop(updatedPromotion);
      }
    } catch (e) {
      print('Error updating promotion: $e');
      if (mounted) {
        String errorMessage = 'Erreur lors de la modification de la promotion';

        if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = 'Erreur de connexion. Vérifiez votre connexion internet.';
        } else if (e.toString().contains('validation')) {
          errorMessage = 'Erreur de validation des données. Vérifiez les informations saisies.';
        } else if (e.toString().contains('unauthorized') || e.toString().contains('401')) {
          errorMessage = 'Session expirée. Veuillez vous reconnecter.';
        } else if (e.toString().contains('file') || e.toString().contains('image')) {
          errorMessage = 'Erreur lors du téléchargement de l\'image. Réessayez avec une autre image.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Détails: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () => _submitOffer(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}