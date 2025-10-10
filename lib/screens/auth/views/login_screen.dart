import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shop/services/fournisseur_service.dart';
import 'package:shop/services/user_service.dart' hide AuthException;

import 'dart:math' as math;

import '../../../route/route_constants.dart';
import '../../../services/auth_service.dart';
import '../../../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _showPassword = false;
  String _activeTab = 'utilisateur';
  bool _isAnimating = false;
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Check if we received an activeTab argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['activeTab'] != null) {
        setState(() {
          _activeTab = args['activeTab'];
        });
      }
    });
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5),
    ));
    _checkIfLoggedIn();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleTabChange(String value) async {
    if (_activeTab == value || _isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    await _animationController.forward();

    setState(() {
      _activeTab = value;
    });

    await _animationController.reverse();

    setState(() {
      _isAnimating = false;
    });
  }



  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  final FournisseurService _fournisseurService = FournisseurService();

  Future<void> _checkIfLoggedIn() async {
    bool loggedIn = await _auth.isLoggedIn();
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> login() async {
    // Validate fields first
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: warningColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      bool success;
      if (_activeTab == 'utilisateur') {
        success = await _userService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        success = await _fournisseurService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_activeTab == 'utilisateur'
                ? 'Connexion utilisateur réussie'
                : 'Connexion partenaire réussie'),
            backgroundColor: successColor,
            duration: Duration(seconds: 2),
          ),
        );
        if(_activeTab == 'utilisateur'){
          Navigator.pushReplacementNamed(context, entryPointScreenRoute);
        }
        else{
          // Go directly to main fournisseur screen (signup now collects all info)
          Navigator.pushReplacementNamed(context, fournissuerScreen);
        }

      }
    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: errorColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Login error: $e\n$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur inattendue est survenue'),
          backgroundColor: errorColor,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_rotationAnimation.value * math.pi),
                  child: Opacity(
                    opacity: _isAnimating ? (1.0 - _opacityAnimation.value) : 1.0,
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
                                                : const Color.fromARGB(0, 0, 0, 0),
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
                            if (_isAnimating)
                              SizedBox(
                                height: kIsWeb ? 250 : 200,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            else if (_activeTab == 'utilisateur')
                              _buildUserContent()
                            else
                              _buildProviderContent(),
                            Container(
                              margin: const EdgeInsets.only(top: 24),
                              child: Column(
                                children: [
                                  MouseRegion(
                                    cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    children: [
                                      const Text(
                                        'Pas encore de compte ? ',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      MouseRegion(
                                        cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
                                        child: TextButton(
                                          onPressed: () {
                                            // Navigate to appropriate signup screen based on active tab
                                            if (_activeTab == 'fournisseur') {
                                              Navigator.pushNamed(context, fournisseurSignupScreenRoute);
                                            } else {
                                              Navigator.pushNamed(context, signUpScreenRoute);
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Text(
                                            'S\'inscrire',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  const Text(
                                    '© 2025 Ahaya. Tous droits réservés.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserContent() {
    return Column(
      children: [
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: kIsWeb ? 52 : 57,
              child: MouseRegion(
                cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (kDebugMode) {
                      print('Connexion Google');
                    }
                  },
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
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
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
        _buildForm('votre@email.com'),
      ],
    );
  }

  Widget _buildProviderContent() {
    return Column(
      children: [
        _buildForm('contact@entreprise.com'),
      ],
    );
  }

  Widget _buildForm(String emailPlaceholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activeTab == 'fournisseur' ? 'Email professionnel' : 'Email',
              style: TextStyle(
                fontSize: kIsWeb ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: emailPlaceholder,
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),

                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: kIsWeb ? 18 : 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mot de passe',
              style: TextStyle(
                fontSize: kIsWeb ? 16 : 14,
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
                suffixIcon: MouseRegion(
                  cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
                  child: IconButton(
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
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: kIsWeb ? 18 : 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: kIsWeb ? 52 : 60,
          child: MouseRegion(
            cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
            child: ElevatedButton(
              onPressed: () {
                login();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}