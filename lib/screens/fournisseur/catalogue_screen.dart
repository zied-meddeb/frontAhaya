import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/catalogue_service.dart';
import '../../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  final AuthService _authService = AuthService();
  final CatalogueService _catalogueService = CatalogueService();
  
  List<Map<String, dynamic>> _catalogues = [];
  bool _isLoading = true;
  bool _isCreating = false;
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _catalogueNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCatalogues();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _catalogueNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogues() async {
    try {
      setState(() => _isLoading = true);
      final fournisseurId = await _authService.getUserId();
      if (fournisseurId != null) {
        final catalogues = await _catalogueService.fetchCataloguesByFournisseur(fournisseurId);
        setState(() {
          _catalogues = catalogues;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des catalogues: $e');
    }
  }

  Future<void> _refreshCatalogues() async {
    await _loadCatalogues();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _createNewCatalogue() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau Catalogue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Donnez un nom à votre nouveau catalogue'),
            const SizedBox(height: 16),
            TextField(
              controller: _catalogueNameController,
              decoration: const InputDecoration(
                hintText: 'Nom du catalogue',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _catalogueNameController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _catalogueNameController.text.trim();
              if (name.isNotEmpty) {
                _catalogueNameController.clear();
                Navigator.of(context).pop(name);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      setState(() => _isCreating = true);
      
      try {
        final fournisseurId = await _authService.getUserId();
        if (fournisseurId != null) {
          final newCatalogue = await _catalogueService.createCatalogue(
            fournisseurId: fournisseurId,
            name: name,
          );
          
          setState(() {
            _catalogues.add(newCatalogue);
            _isCreating = false;
          });
          
          _showSuccessSnackBar('Catalogue "$name" créé avec succès!');
        }
      } catch (e) {
        setState(() => _isCreating = false);
        _showErrorSnackBar('Erreur lors de la création du catalogue: $e');
      }
    }
  }

  Future<void> _deleteCatalogue(int index) async {
    final catalogue = _catalogues[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le catalogue'),
        content: Text('Êtes-vous sûr de vouloir supprimer le catalogue "${catalogue['name']}"? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _catalogueService.deleteCatalogue(catalogue['_id']);
        setState(() {
          _catalogues.removeAt(index);
        });
        _showSuccessSnackBar('Catalogue "${catalogue['name']}" supprimé');
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la suppression: $e');
      }
    }
  }

  void _openCatalogue(Map<String, dynamic> catalogue) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _IndividualCatalogueScreen(
          catalogue: catalogue,
          onCatalogueUpdated: (updatedCatalogue) {
            // Update the catalogue in the list
            final index = _catalogues.indexWhere((c) => c['id'] == catalogue['id']);
            if (index != -1) {
              setState(() {
                _catalogues[index] = updatedCatalogue;
              });
            }
          },
        ),
      ),
    );
  }

  void _previewCatalogue(Map<String, dynamic> catalogue) {
    final pages = List<Map<String, dynamic>>.from(catalogue['pages'] ?? []);
    if (pages.isEmpty) {
      _showErrorSnackBar('Ce catalogue ne contient aucune page');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CatalogueBookPreview(
          catalogue: catalogue,
        ),
      ),
    );
  }

  Widget _buildCatalogueCard(Map<String, dynamic> catalogue, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openCatalogue(catalogue),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Catalogue Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SupplierTheme.primaryBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          catalogue['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${catalogue['pageCount']} page${catalogue['pageCount'] > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'preview') {
                        _previewCatalogue(catalogue);
                      } else if (value == 'delete') {
                        _deleteCatalogue(index);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'preview',
                        child: Row(
                          children: [
                            Icon(Icons.preview, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Aperçu'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.more_vert, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Catalogue Info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Créé le ${_formatDate(catalogue['createdDate'])}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Modifié le ${_formatDate(catalogue['updatedDate'])}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: SupplierTheme.primaryBlack.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility, size: 16, color: SupplierTheme.primaryBlack),
                    SizedBox(width: 8),
                    Text(
                      'Ouvrir le catalogue',
                      style: TextStyle(
                        color: SupplierTheme.primaryBlack,
                        fontWeight: FontWeight.w500,
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

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    DateTime dateTime;
    if (date is String) {
      try {
        dateTime = DateTime.parse(date);
      } catch (e) {
        return 'N/A';
      }
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'N/A';
    }
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _buildCreateCatalogueButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _isCreating ? null : _createNewCatalogue,
        icon: _isCreating 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add),
        label: Text(_isCreating ? 'Création en cours...' : 'Nouveau Catalogue'),
        style: ElevatedButton.styleFrom(
          backgroundColor: SupplierTheme.primaryBlack,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun catalogue créé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier catalogue pour organiser vos produits en pages comme un magazine',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewCatalogue,
            icon: const Icon(Icons.add),
            label: const Text('Créer mon premier catalogue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SupplierTheme.primaryBlack,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Catalogues',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: SupplierTheme.primaryBlack,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshCatalogues,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _catalogues.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshCatalogues,
                  child: Column(
                    children: [
                      // Create catalogue button
                      _buildCreateCatalogueButton(),
                      
                      // Header with catalogue count
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Colors.white,
                        child: Text(
                          '${_catalogues.length} catalogue${_catalogues.length > 1 ? 's' : ''} créé${_catalogues.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // Catalogues list
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _catalogues.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCatalogueCard(_catalogues[index], index),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// Individual Catalogue Screen - Manage pages within a catalogue
class _IndividualCatalogueScreen extends StatefulWidget {
  final Map<String, dynamic> catalogue;
  final Function(Map<String, dynamic>) onCatalogueUpdated;

  const _IndividualCatalogueScreen({
    required this.catalogue,
    required this.onCatalogueUpdated,
  });

  @override
  State<_IndividualCatalogueScreen> createState() => _IndividualCatalogueScreenState();
}

class _IndividualCatalogueScreenState extends State<_IndividualCatalogueScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final CatalogueService _catalogueService = CatalogueService();
  late Map<String, dynamic> _catalogue;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _catalogue = Map<String, dynamic>.from(widget.catalogue);
  }

  Future<void> _addCataloguePage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isUploading = true);
        
        try {
          final updatedCatalogue = await _catalogueService.addPageToCatalogue(
            catalogueId: _catalogue['_id'],
            imageFile: image,
          );
          
          setState(() {
            _catalogue = updatedCatalogue;
            _isUploading = false;
          });
          
          widget.onCatalogueUpdated(_catalogue);
          _showSuccessSnackBar('Page ajoutée au catalogue avec succès!');
        } catch (e) {
          setState(() => _isUploading = false);
          _showErrorSnackBar('Erreur lors de l\'ajout de la page: $e');
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorSnackBar('Erreur lors de l\'ajout de la page: $e');
    }
  }

  Future<void> _deleteCataloguePage(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la page'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette page du catalogue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final updatedCatalogue = await _catalogueService.removePageFromCatalogue(
          catalogueId: _catalogue['_id'],
          pageIndex: index,
        );
        
        setState(() {
          _catalogue = updatedCatalogue;
        });
        
        widget.onCatalogueUpdated(_catalogue);
        _showSuccessSnackBar('Page supprimée du catalogue');
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la suppression de la page: $e');
      }
    }
  }

  void _viewCataloguePage(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CataloguePageViewer(
          pages: List<Map<String, dynamic>>.from(_catalogue['pages'] ?? []),
          initialIndex: index,
        ),
      ),
    );
  }

  Widget _buildCataloguePageCard(Map<String, dynamic> page, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Image
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: () => _viewCataloguePage(index),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    children: [
                      _buildImageWidget(page['imageUrl']),
                      // Overlay with zoom icon
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Page Info and Actions
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SupplierTheme.primaryBlack.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Page ${page['pageNumber']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: SupplierTheme.primaryBlack,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Upload Date
                Text(
                  'Ajoutée le ${_formatDate(page['uploadDate'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Delete Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _deleteCataloguePage(index),
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        tooltip: 'Supprimer',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    DateTime dateTime;
    if (date is String) {
      try {
        dateTime = DateTime.parse(date);
      } catch (e) {
        return 'N/A';
      }
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'N/A';
    }
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _buildImageWidget(String imageUrl) {
    // Check if it's a URL or local file path
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
          ),
        ),
      );
    }
  }

  Widget _buildAddPageButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _isUploading ? null : _addCataloguePage,
        icon: _isUploading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add_photo_alternate),
        label: Text(_isUploading ? 'Ajout en cours...' : 'Ajouter une page'),
        style: ElevatedButton.styleFrom(
          backgroundColor: SupplierTheme.primaryBlack,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Ce catalogue est vide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des pages à ce catalogue pour créer un magazine numérique',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addCataloguePage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Ajouter la première page'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SupplierTheme.primaryBlack,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _catalogue['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: SupplierTheme.primaryBlack,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Refresh functionality could be added here
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: _catalogue['pages'].isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Add page button
                _buildAddPageButton(),
                
                // Header with page count
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Text(
                    '${_catalogue['pages'].length} page${_catalogue['pages'].length > 1 ? 's' : ''} dans ce catalogue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Pages grid
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _catalogue['pages'].length,
                            itemBuilder: (context, index) {
                              return _buildCataloguePageCard(_catalogue['pages'][index], index);
                            },
                          ),
                        ),
              ],
            ),
    );
  }
}

// Catalogue Page Viewer - Full screen image viewer
class _CataloguePageViewer extends StatefulWidget {
  final List<Map<String, dynamic>> pages;
  final int initialIndex;

  const _CataloguePageViewer({
    required this.pages,
    required this.initialIndex,
  });

  @override
  State<_CataloguePageViewer> createState() => _CataloguePageViewerState();
}

class _CataloguePageViewerState extends State<_CataloguePageViewer> {
  late PageController _pageController;
  late TransformationController _transformationController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Widget _buildPageViewerImage(String imageUrl) {
    // Check if it's a URL or local file path
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.white, size: 64),
                SizedBox(height: 16),
                Text(
                  'Impossible de charger l\'image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.white, size: 64),
                SizedBox(height: 16),
                Text(
                  'Impossible de charger l\'image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Page ${_currentIndex + 1} sur ${widget.pages.length}'),
        actions: [
          IconButton(
            onPressed: _resetZoom,
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Réinitialiser le zoom',
          ),
          IconButton(
            onPressed: () {
              // Share functionality could be added here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité de partage à venir')),
              );
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _resetZoom(); // Reset zoom when changing pages
        },
        itemCount: widget.pages.length,
        itemBuilder: (context, index) {
          final page = widget.pages[index];
          return Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.3,
              maxScale: 5.0,
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              constrained: false,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height - 200,
                ),
                child: _buildPageViewerImage(page['imageUrl']),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.black,
        child: Column(
          children: [
            // Zoom controls
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out, color: Colors.white),
                    onPressed: () {
                      final Matrix4 current = _transformationController.value;
                      final Matrix4 newMatrix = Matrix4.identity()..scale(0.8);
                      _transformationController.value = current * newMatrix;
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.zoom_in, color: Colors.white),
                    onPressed: () {
                      final Matrix4 current = _transformationController.value;
                      final Matrix4 newMatrix = Matrix4.identity()..scale(1.2);
                      _transformationController.value = current * newMatrix;
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.center_focus_strong, color: Colors.white),
                    onPressed: _resetZoom,
                    tooltip: 'Centrer',
                  ),
                ],
              ),
            ),
            // Navigation controls
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                    onPressed: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.pages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 30),
                    onPressed: _currentIndex < widget.pages.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogueBookPreview extends StatefulWidget {
  final Map<String, dynamic> catalogue;

  const _CatalogueBookPreview({
    required this.catalogue,
  });

  @override
  State<_CatalogueBookPreview> createState() => _CatalogueBookPreviewState();
}

class _CatalogueBookPreviewState extends State<_CatalogueBookPreview> {
  late PageController _pageController;
  late TransformationController _transformationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Widget _buildPageImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.white, size: 64),
                SizedBox(height: 16),
                Text(
                  'Impossible de charger l\'image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.white, size: 64),
                SizedBox(height: 16),
                Text(
                  'Impossible de charger l\'image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.catalogue['name'],
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Page ${_currentIndex + 1} sur ${(widget.catalogue['pages'] as List).length}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _resetZoom,
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Réinitialiser le zoom',
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _resetZoom(); // Reset zoom when changing pages
        },
        itemCount: (widget.catalogue['pages'] as List).length,
        itemBuilder: (context, index) {
          final pages = List<Map<String, dynamic>>.from(widget.catalogue['pages'] ?? []);
          final page = pages[index];
          return Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.3,
              maxScale: 5.0,
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              constrained: false,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height - 200,
                ),
                child: _buildPageImage(page['imageUrl']),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.black,
        child: Column(
          children: [
            // Zoom controls
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out, color: Colors.white),
                    onPressed: () {
                      final Matrix4 current = _transformationController.value;
                      final Matrix4 newMatrix = Matrix4.identity()..scale(0.8);
                      _transformationController.value = current * newMatrix;
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.zoom_in, color: Colors.white),
                    onPressed: () {
                      final Matrix4 current = _transformationController.value;
                      final Matrix4 newMatrix = Matrix4.identity()..scale(1.2);
                      _transformationController.value = current * newMatrix;
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.center_focus_strong, color: Colors.white),
                    onPressed: _resetZoom,
                    tooltip: 'Centrer',
                  ),
                ],
              ),
            ),
            // Navigation controls
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                    onPressed: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${(widget.catalogue['pages'] as List).length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 30),
                    onPressed: _currentIndex < (widget.catalogue['pages'] as List).length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
