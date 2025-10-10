import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shop/services/fournisseur_service.dart';
import 'package:shop/models/fournisseur.dart';
import '../../../route/route_constants.dart';
import '../../../constants.dart';

// Import AuthException
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}

class FournisseurSignupScreen extends StatefulWidget {
  const FournisseurSignupScreen({super.key});

  @override
  State<FournisseurSignupScreen> createState() => _FournisseurSignupScreenState();
}

class _FournisseurSignupScreenState extends State<FournisseurSignupScreen> {
  final PageController _pageController = PageController();
  final FournisseurService _fournisseurService = FournisseurService();
  
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Basic Information
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // Step 2: Address Information
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  String _addressType = 'primary';

  // Step 3: Store Information (Optional)
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeDescriptionController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telephoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _storeNameController.dispose();
    _storeDescriptionController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  bool _validateStep1() {
    if (_nomController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre nom');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre email');
      return false;
    }
    if (!_emailController.text.contains('@')) {
      _showError('Veuillez entrer un email valide');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Veuillez entrer un mot de passe');
      return false;
    }
    if (_passwordController.text.length < 8) {
      _showError('Le mot de passe doit contenir au moins 8 caractères');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Les mots de passe ne correspondent pas');
      return false;
    }
    if (_telephoneController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre numéro de téléphone');
      return false;
    }
    if (_telephoneController.text.length < 8) {
      _showError('Le numéro de téléphone doit contenir au moins 8 chiffres');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_streetController.text.trim().isEmpty) {
      _showError('Veuillez entrer l\'adresse de la rue');
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      _showError('Veuillez entrer la ville');
      return false;
    }
    if (_stateController.text.trim().isEmpty) {
      _showError('Veuillez entrer la région/état');
      return false;
    }
    if (_postalCodeController.text.trim().isEmpty) {
      _showError('Veuillez entrer le code postal');
      return false;
    }
    if (_countryController.text.trim().isEmpty) {
      _showError('Veuillez entrer le pays');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeSignup() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Create address object
      final address = FournisseurAddress(
        type: _addressType,
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        isDefault: true,
      );

      // Create store info if provided
      StoreInfo? storeInfo;
      if (_storeNameController.text.trim().isNotEmpty ||
          _storeDescriptionController.text.trim().isNotEmpty) {
        storeInfo = StoreInfo(
          description: _storeDescriptionController.text.trim().isEmpty
              ? _storeNameController.text.trim()
              : _storeDescriptionController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          socialMedia: (_facebookController.text.trim().isNotEmpty ||
                  _instagramController.text.trim().isNotEmpty ||
                  _twitterController.text.trim().isNotEmpty)
              ? SocialMedia(
                  facebook: _facebookController.text.trim().isEmpty
                      ? null
                      : _facebookController.text.trim(),
                  instagram: _instagramController.text.trim().isEmpty
                      ? null
                      : _instagramController.text.trim(),
                  twitter: _twitterController.text.trim().isEmpty
                      ? null
                      : _twitterController.text.trim(),
                )
              : null,
        );
      }

      final response = await _fournisseurService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nomController.text.trim(),
        phone: _telephoneController.text.trim(),
        address: address.toJson(),
      );

      if (!mounted) return;

      if (response == true) {
        // Show success message briefly
        _showSuccess('Compte créé avec succès ! Vérifiez votre email.');
        
        // Small delay to show the success message, then navigate
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        // Navigate to email verification
        Navigator.pushReplacementNamed(
          context,
          emailVerification,
          arguments: {
            'email': _emailController.text.trim(),
            'userType': 'fournisseur',
          },
        );
      } else {
        _showError('Erreur lors de l\'inscription. Veuillez réessayer.');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 600 : double.infinity,
              ),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with back button
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Inscription Partenaire',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Step Progress Indicator
                      _buildStepIndicator(),
                      const SizedBox(height: 32),

                      // Page View for Steps
                      SizedBox(
                        height: isDesktop ? 500 : 600,
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() => _currentStep = index);
                          },
                          children: [
                            _buildStep1BasicInfo(),
                            _buildStep2Address(),
                            _buildStep3StoreInfo(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Navigation Buttons
                      _buildNavigationButtons(),

                      const SizedBox(height: 16),

                      // Login Link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Déjà un compte ? ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, logInScreenRoute);
                              },
                              child: const Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(1, 'Infos'),
        _buildStepLine(0),
        _buildStepCircle(2, 'Adresse'),
        _buildStepLine(1),
        _buildStepCircle(3, 'Magasin'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step - 1;
    final isCompleted = _currentStep > step - 1;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.black
                  : isActive
                      ? Colors.black
                      : Colors.grey[300],
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      step.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? Colors.black : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isActive ? Colors.black : Colors.grey[300],
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de Base',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par les informations essentielles',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          // Name Field
          _buildTextField(
            controller: _nomController,
            label: 'Nom complet ou nom d\'entreprise',
            icon: Icons.business,
            hint: 'Ex: Boutique Mode Tunisie',
          ),
          const SizedBox(height: 16),

          // Email Field
          _buildTextField(
            controller: _emailController,
            label: 'Email professionnel',
            icon: Icons.email_outlined,
            hint: 'contact@votreentreprise.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Phone Field
          _buildTextField(
            controller: _telephoneController,
            label: 'Numéro de téléphone',
            icon: Icons.phone_outlined,
            hint: '20123456',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Password Field
          _buildTextField(
            controller: _passwordController,
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            hint: 'Minimum 8 caractères',
            obscureText: !_showPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirmer le mot de passe',
            icon: Icons.lock_outline,
            hint: 'Retapez votre mot de passe',
            obscureText: !_showConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Address() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adresse Principale',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Où se trouve votre entreprise ?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Address Type Selector
          const Text(
            'Type d\'adresse',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildAddressTypeChip('primary', 'Principal'),
              _buildAddressTypeChip('warehouse', 'Entrepôt'),
              _buildAddressTypeChip('office', 'Bureau'),
              _buildAddressTypeChip('secondary', 'Secondaire'),
            ],
          ),
          const SizedBox(height: 24),

          // Street Field
          _buildTextField(
            controller: _streetController,
            label: 'Adresse complète',
            icon: Icons.location_on_outlined,
            hint: 'Rue, numéro, bâtiment...',
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // City and Postal Code Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _cityController,
                  label: 'Ville',
                  icon: Icons.location_city,
                  hint: 'Ex: Tunis',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _postalCodeController,
                  label: 'Code Postal',
                  icon: Icons.numbers,
                  hint: '1000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // State Field
          _buildTextField(
            controller: _stateController,
            label: 'Région / Gouvernorat',
            icon: Icons.map_outlined,
            hint: 'Ex: Tunis',
          ),
          const SizedBox(height: 16),

          // Country Field
          _buildTextField(
            controller: _countryController,
            label: 'Pays',
            icon: Icons.public,
            hint: 'Ex: Tunisie',
          ),
        ],
      ),
    );
  }

  Widget _buildStep3StoreInfo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations du Magasin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optionnel - Vous pouvez compléter cela plus tard',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Store Name Field
          _buildTextField(
            controller: _storeNameController,
            label: 'Nom du magasin (optionnel)',
            icon: Icons.store,
            hint: 'Le nom de votre boutique en ligne',
          ),
          const SizedBox(height: 16),

          // Store Description Field
          _buildTextField(
            controller: _storeDescriptionController,
            label: 'Description (optionnel)',
            icon: Icons.description_outlined,
            hint: 'Décrivez votre activité...',
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Website Field
          _buildTextField(
            controller: _websiteController,
            label: 'Site web (optionnel)',
            icon: Icons.language,
            hint: 'https://votresite.com',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),

          // Social Media Section
          const Text(
            'Réseaux Sociaux (optionnel)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _facebookController,
            label: 'Facebook',
            icon: Icons.facebook,
            hint: 'URL de votre page Facebook',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _instagramController,
            label: 'Instagram',
            icon: Icons.camera_alt,
            hint: 'URL de votre profil Instagram',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _twitterController,
            label: 'Twitter',
            icon: Icons.flutter_dash,
            hint: 'URL de votre profil Twitter',
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTypeChip(String value, String label) {
    final isSelected = _addressType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _addressType = value);
        }
      },
      selectedColor: Colors.black,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : _previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.black),
              ),
              child: const Text(
                'Précédent',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          flex: _currentStep == 0 ? 1 : 2,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : _currentStep < 2
                    ? _nextStep
                    : _completeSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                : Text(
                    _currentStep < 2 ? 'Continuer' : 'Créer mon compte',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
