import 'package:flutter/material.dart';
import 'package:shop/services/fournisseur_service.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/theme/app_theme.dart';
import '../../models/fournisseur.dart';
import '../../route/route_constants.dart';

class FournisseurProfileScreen extends StatefulWidget {
  const FournisseurProfileScreen({super.key});

  @override
  State<FournisseurProfileScreen> createState() => _FournisseurProfileScreenState();
}

class _FournisseurProfileScreenState extends State<FournisseurProfileScreen> {
  final FournisseurService _fournisseurService = FournisseurService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _fournisseurService.getProfile();
      setState(() {
        _profileData = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.clearCredentials();
      if (mounted) {
        Navigator.pushReplacementNamed(context, onbordingScreenRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SupplierTheme.lightGray,
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: SupplierTheme.primaryWhite,
        foregroundColor: SupplierTheme.primaryBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _errorMessage != null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_profileData == null) return const SizedBox.shrink();

    final nom = _profileData!['nom'] ?? 'N/A';
    final email = _profileData!['email'] ?? 'N/A';
    final telephone = _profileData!['telephone'] ?? 'N/A';
    final addresses = _profileData!['addresses'] as List? ?? [];
    final storeInfo = _profileData!['storeInfo'] as Map<String, dynamic>?;
    final isVerified = _profileData!['isVerified'] ?? false;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header Card
            _buildHeaderCard(nom, email, isVerified),
            const SizedBox(height: 16),

            // Contact Information Card
            _buildContactCard(telephone, email),
            const SizedBox(height: 16),

            // Store Information Card
            if (storeInfo != null) _buildStoreInfoCard(storeInfo),
            if (storeInfo != null) const SizedBox(height: 16),

            // Addresses Card
            _buildAddressesCard(addresses),
            const SizedBox(height: 16),

            // Edit Profile Button
            _buildEditButton(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String nom, String email, bool isVerified) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF424242)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Text(
                  nom.isNotEmpty ? nom[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              nom,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            
            // Email
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            
            // Verified Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isVerified ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVerified ? Icons.verified : Icons.pending,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isVerified ? 'Vérifié' : 'En attente',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(String telephone, String email) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.contact_phone, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.phone, 'Téléphone', telephone),
            const Divider(height: 24),
            _buildInfoRow(Icons.email, 'Email', email),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfoCard(Map<String, dynamic> storeInfo) {
    final description = storeInfo['description'] as String?;
    final website = storeInfo['website'] as String?;
    final socialMedia = storeInfo['socialMedia'] as Map<String, dynamic>?;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informations du Magasin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            if (website != null && website.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.language, 'Site web', website),
            ],
            if (socialMedia != null) ...[
              const Divider(height: 24),
              const Text(
                'Réseaux sociaux',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (socialMedia['facebook'] != null)
                    _buildSocialChip(Icons.facebook, 'Facebook'),
                  if (socialMedia['instagram'] != null)
                    _buildSocialChip(Icons.camera_alt, 'Instagram'),
                  if (socialMedia['twitter'] != null)
                    _buildSocialChip(Icons.flutter_dash, 'Twitter'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesCard(List addresses) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Adresses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (addresses.isEmpty)
              Text(
                'Aucune adresse enregistrée',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              ...addresses.asMap().entries.map((entry) {
                final index = entry.key;
                final address = entry.value as Map<String, dynamic>;
                return Column(
                  children: [
                    if (index > 0) const Divider(height: 24),
                    _buildAddressItem(address),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(Map<String, dynamic> address) {
    final type = address['type'] ?? 'N/A';
    final street = address['street'] ?? '';
    final city = address['city'] ?? '';
    final state = address['state'] ?? '';
    final postalCode = address['postalCode'] ?? '';
    final country = address['country'] ?? '';
    final isDefault = address['isDefault'] ?? false;

    String typeLabel = '';
    IconData typeIcon = Icons.location_on;
    
    switch (type) {
      case 'primary':
        typeLabel = 'Principal';
        typeIcon = Icons.home;
        break;
      case 'warehouse':
        typeLabel = 'Entrepôt';
        typeIcon = Icons.warehouse;
        break;
      case 'office':
        typeLabel = 'Bureau';
        typeIcon = Icons.business;
        break;
      case 'secondary':
        typeLabel = 'Secondaire';
        typeIcon = Icons.location_city;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isDefault ? Border.all(color: Colors.black, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeIcon, size: 18),
              const SizedBox(width: 8),
              Text(
                typeLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (isDefault) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Par défaut',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$street, $city $postalCode',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          Text(
            '$state, $country',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_profileData != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditFournisseurProfileScreen(
                  profileData: _profileData!,
                ),
              ),
            ).then((updated) {
              if (updated == true) {
                _loadProfile(); // Reload profile after edit
              }
            });
          }
        },
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Modifier le profil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Edit Profile Screen
class EditFournisseurProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditFournisseurProfileScreen({
    super.key,
    required this.profileData,
  });

  @override
  State<EditFournisseurProfileScreen> createState() => _EditFournisseurProfileScreenState();
}

class _EditFournisseurProfileScreenState extends State<EditFournisseurProfileScreen> {
  final FournisseurService _fournisseurService = FournisseurService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nomController;
  late TextEditingController _telephoneController;
  late TextEditingController _storeDescriptionController;
  late TextEditingController _websiteController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _nomController = TextEditingController(text: widget.profileData['nom']);
    _telephoneController = TextEditingController(text: widget.profileData['telephone']);
    
    final storeInfo = widget.profileData['storeInfo'] as Map<String, dynamic>?;
    _storeDescriptionController = TextEditingController(text: storeInfo?['description'] ?? '');
    _websiteController = TextEditingController(text: storeInfo?['website'] ?? '');
    
    final socialMedia = storeInfo?['socialMedia'] as Map<String, dynamic>?;
    _facebookController = TextEditingController(text: socialMedia?['facebook'] ?? '');
    _instagramController = TextEditingController(text: socialMedia?['instagram'] ?? '');
    _twitterController = TextEditingController(text: socialMedia?['twitter'] ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _storeDescriptionController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updateData = {
        'nom': _nomController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'storeInfo': {
          'description': _storeDescriptionController.text.trim(),
          'website': _websiteController.text.trim(),
          'socialMedia': {
            'facebook': _facebookController.text.trim(),
            'instagram': _instagramController.text.trim(),
            'twitter': _twitterController.text.trim(),
          },
        },
      };

      await _fournisseurService.updateProfile(
        widget.profileData['_id'],
        updateData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SupplierTheme.lightGray,
      appBar: AppBar(
        title: const Text('Modifier le profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: SupplierTheme.primaryWhite,
        foregroundColor: SupplierTheme.primaryBlack,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations de base',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          labelText: 'Nom / Nom d\'entreprise',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telephoneController,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le téléphone est requis';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Store Information Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations du magasin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _storeDescriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: InputDecoration(
                          labelText: 'Site web',
                          prefixIcon: const Icon(Icons.language),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Social Media Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Réseaux sociaux',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _facebookController,
                        decoration: InputDecoration(
                          labelText: 'Facebook',
                          prefixIcon: const Icon(Icons.facebook),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _instagramController,
                        decoration: InputDecoration(
                          labelText: 'Instagram',
                          prefixIcon: const Icon(Icons.camera_alt),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _twitterController,
                        decoration: InputDecoration(
                          labelText: 'Twitter',
                          prefixIcon: const Icon(Icons.flutter_dash),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
