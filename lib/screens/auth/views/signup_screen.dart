import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shop/services/user_service.dart';
import 'package:shop/services/fournisseur_service.dart';

import '../../../route/route_constants.dart';
import '../../../constants.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  bool _showPassword = false;
  bool isLoading = false;
  String _activeTab = 'utilisateur';
  bool _isAnimating = false;

  late AnimationController _animationController;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final UserService _userService = UserService();
  final FournisseurService _fournisseurService = FournisseurService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleTabChange(String value) async {
    if (_activeTab == value || _isAnimating) return;

    // If switching to fournisseur, navigate to the dedicated signup screen
    if (value == 'fournisseur') {
      Navigator.pushNamed(context, fournisseurSignupScreenRoute);
      return;
    }

    setState(() {
      _isAnimating = true;
    });

    await _animationController.forward();

    setState(() {
      _activeTab = value;
    });

    // Clear form fields when switching tabs
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();

    await _animationController.reverse();

    setState(() {
      _isAnimating = false;
    });
  }

  Future<void> signUp() async {
    try {
      setState(() {
        isLoading = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;
      String name = _nameController.text;
      String phone = _phoneController.text;
      String addressText = _addressController.text;

      // Validate required fields
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires'),
            backgroundColor: warningColor,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (_activeTab == 'fournisseur' && (phone.isEmpty || addressText.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le numéro de téléphone et l\'adresse sont obligatoires pour les partenaires'),
            backgroundColor: warningColor,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      bool response;
      if (_activeTab == 'utilisateur') {
        response = await _userService.signUp(
          email: email,
          password: password,
          name: name,
        );
      } else {
        // Create address object for fournisseur
        Map<String, dynamic> address = {
          'type': 'primary',
          'street': addressText,
          'city': 'Unknown', // Will be updated in onboarding
          'state': 'Unknown', // Will be updated in onboarding
          'postalCode': '00000', // Will be updated in onboarding
          'country': 'Unknown', // Will be updated in onboarding
          'isDefault': true,
        };
        
        response = await _fournisseurService.signUp(
          email: email,
          password: password,
          name: name,
          phone: phone,
          address: address,
        );
      }

      if (response == true) {
        Navigator.pushReplacementNamed(context, emailVerification, arguments: {
          'email': email,
          'userType': _activeTab,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'inscription"),
            backgroundColor: errorColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue: ${e.toString()}"),
          backgroundColor: errorColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildSignupForm() {
    return Column(
      children: [
        // Social Login Buttons
        SizedBox(
          width: double.infinity,
          height: kIsWeb ? 52 : 57,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Container(
              width: 20,
              height: 20,
              child: Image.asset(
                'assets/logo/google.png',
                fit: BoxFit.contain,
              ),
            ),
            label: const Text(
              'Continuer avec Google',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Divider
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OU',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),

        // Name Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nom complet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Votre nom',
                prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Phone Field (only for fournisseur)
        if (_activeTab == 'fournisseur') ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Téléphone',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Votre numéro de téléphone',
                  prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Address Field (only for fournisseur)
        if (_activeTab == 'fournisseur') ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adresse',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Votre adresse',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'votre@email.com',
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mot de passe',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Sign Up Button
        SizedBox(
          width: double.infinity,
          height: kIsWeb ? 52 : 60,
          child: ElevatedButton(
            onPressed: isLoading ? null : signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
              _activeTab == 'utilisateur' ? 'S\'inscrire' : 'Créer un compte partenaire',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final cardWidth = isDesktop ? 400.0 : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(kIsWeb ? 16.0 : 20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: cardWidth,
              minHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Card(
              color: Colors.white,
              elevation: kIsWeb ? 4 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(kIsWeb ? 40.0 : 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          Container(
                            width: kIsWeb ? 100 : 150,
                            height: kIsWeb ? 100 : 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/logo/logo.png',
                              width: 320,
                              height: 300,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tab Switcher
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _handleTabChange('utilisateur'),
                              child: MouseRegion(
                                cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: kIsWeb ? 14 : 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _activeTab == 'utilisateur' && !_isAnimating
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: _activeTab == 'utilisateur' && !_isAnimating
                                        ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'Utilisateur',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _handleTabChange('fournisseur'),
                              child: MouseRegion(
                                cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: kIsWeb ? 14 : 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _activeTab == 'fournisseur' && !_isAnimating
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: _activeTab == 'fournisseur' && !_isAnimating
                                        ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.business_center, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'Partenaire',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content based on active tab
                    if (_isAnimating)
                      SizedBox(
                        height: kIsWeb ? 400 : 350,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        ),
                      )
                    else
                      _buildSignupForm(),
                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ? ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, logInScreenRoute);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Footer
                    const SizedBox(height: 32),
                    const Text(
                      '© 2025 Ahaya. Tous droits réservés.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
