import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/fournisseur_service.dart';
import 'dart:math' as math;

class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({super.key});

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  final AuthService _auth = AuthService();
  final FournisseurService _fournisseurService = FournisseurService();

  // Animation controllers
  late AnimationController _logoLoadingController;
  late AnimationController _couponController;
  late AnimationController _textLoadingController;
  late AnimationController _logoEntranceController;
  late AnimationController _textEntranceController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _mainSlide;
  late Animation<Offset> _textSlide;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _logoLoadingController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _couponController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _textLoadingController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoEntranceController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _textEntranceController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize animations
    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _logoEntranceController, curve: Curves.easeOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoEntranceController, curve: Curves.easeOut),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textEntranceController, curve: Curves.easeOut),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    _mainSlide = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _logoEntranceController, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _textEntranceController, curve: Curves.easeOut));

    _buttonSlide = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    // Start loading animations
    _logoLoadingController.repeat();
    _couponController.repeat();
    _textLoadingController.repeat();

    // Simulate loading time (3.5 seconds)
    Future.delayed(Duration(milliseconds: 3500), () {
      setState(() {
        isLoading = false;
      });
      _startEntranceAnimations();
      _checkAuthenticationStatus();
    });
  }

  void _startEntranceAnimations() async {
    // Stop loading animations
    _logoLoadingController.stop();
    _couponController.stop();
    _textLoadingController.stop();

    // Start entrance animations
    await _logoEntranceController.forward();
    await Future.delayed(Duration(milliseconds: 400));
    await _textEntranceController.forward();
    await Future.delayed(Duration(milliseconds: 400));
    await _buttonController.forward();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final isLoggedIn = await _auth.isLoggedIn();
      
      if (!isLoggedIn) {
        return; // Stay on onboarding screen
      }

      final userRole = await _auth.getUserRole();
      
      if (userRole == 'fournisseur') {
        // Check if fournisseur has completed onboarding
        try {
          final onboardingStatus = await _fournisseurService.getOnboardingStatus();
          
          if (onboardingStatus['isOnboardingCompleted'] == true) {
            // Redirect to fournisseur main screen
            if (mounted) {
              Navigator.pushReplacementNamed(context, fournissuerScreen);
            }
          } else {
            // Redirect to onboarding
            if (mounted) {
              Navigator.pushReplacementNamed(context, fournisseurOnboardingRoute);
            }
          }
        } catch (e) {
          // If error checking onboarding, redirect to onboarding
          if (mounted) {
            Navigator.pushReplacementNamed(context, fournisseurOnboardingRoute);
          }
        }
      } else if (userRole == 'user') {
        // Redirect to main app for users
        if (mounted) {
          Navigator.pushReplacementNamed(context, entryPointScreenRoute);
        }
      }
    } catch (e) {
      // Error checking authentication, stay on onboarding screen
      print('Error checking authentication: $e');
    }
  }

  @override
  void dispose() {
    _logoLoadingController.dispose();
    _couponController.dispose();
    _textLoadingController.dispose();
    _logoEntranceController.dispose();
    _textEntranceController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: isLoading ? _buildLoadingWidget() : _buildMainContent(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo with simple pulse animation
        AnimatedBuilder(
          animation: _logoLoadingController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 +
                  (0.02 * math.sin(_logoLoadingController.value * 2 * math.pi)),
              child: Image.asset(
                'assets/logo/logo.png',
                width: 320,
                height: 300,
              ),
            );
          },
        ),

        // Simple loading coupons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSimpleCoupon(0),
            SizedBox(width: 8),
            _buildSimpleCoupon(200),
            SizedBox(width: 8),
            _buildSimpleCoupon(400),
          ],
        ),

        SizedBox(height: 24),

        // Simple loading text
        AnimatedBuilder(
          animation: _textLoadingController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.5 +
                  0.5 * math.sin(_textLoadingController.value * 2 * math.pi),
              child: Text(
                'Chargement...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSimpleCoupon(int delayMs) {
    return AnimatedBuilder(
      animation: _couponController,
      builder: (context, child) {
        double animationValue =
            (_couponController.value * 1200 - delayMs) / 1200;
        if (animationValue < 0) animationValue = 0;
        if (animationValue > 1) animationValue = 1;

        double yOffset = -6 * math.sin(animationValue * 2 * math.pi);
        double opacity = 0.6 + 0.4 * math.sin(animationValue * 2 * math.pi);

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 24,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Simple notch
                  Positioned(
                    right: -3,
                    top: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[300]!),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Percentage symbol
                  Center(
                    child: Text(
                      '%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SlideTransition(
      position: _mainSlide,
      child: FadeTransition(
        opacity: _logoOpacity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple logo entrance
            AnimatedBuilder(
              animation: _logoEntranceController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScale.value,
                  child: GestureDetector(
                    onTap: () {
                      // Add hover effect simulation
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(1.0),
                      child: Image.asset(
                        'assets/logo/logo.png',
                        width: 320,
                        height: 300,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Simple welcome message
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    Text(
                      'Bienvenue sur Ahaya',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vos réductions vous attendent',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Discover button
            SlideTransition(
              position: _buttonSlide,
              child: FadeTransition(
                opacity: _buttonOpacity,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      child: SizedBox(
                        width: double.infinity,
                        height: kIsWeb ? 52 : 60,
                        child: MouseRegion(
                          cursor: kIsWeb
                              ? SystemMouseCursors.click
                              : MouseCursor.defer,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, entryPointScreenRoute);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Découvrir',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16), // Add spacing between buttons
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      child: SizedBox(
                        width: double.infinity,
                        height: kIsWeb ? 52 : 60,
                        child: MouseRegion(
                          cursor: kIsWeb
                              ? SystemMouseCursors.click
                              : MouseCursor.defer,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to espace fournisseur
                              Navigator.pushNamed(context, supplierScreenRoute);

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Espace Fournisseur',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
