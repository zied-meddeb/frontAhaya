import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/screens/discover/views/all_products_screen.dart';
import 'package:shop/screens/favoris/views/favoris_screen.dart';
import 'package:shop/services/auth_service.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  // Define enum for PopupMenu choices
  static const String aPropos = 'À propos';
  static const String contact = 'Contact';
  static const String language = 'Language';

  static const List<String> choices = <String>[aPropos, contact, language];

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool isLoggedIn = false;
  bool _isLoading = true;
  final AuthService _auth = AuthService();
  List<Widget> _pages = [];
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      isLoggedIn = await _auth.isLoggedIn();
      setState(() {
        _pages = [
          HomeScreen(),
          ProductListingScreen(),
          isLoggedIn?FavoriteScreen() :ProfileNotConnected(),
          isLoggedIn ? ProfileScreen() : ProfileNotConnected(),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _pages = [
          HomeScreen(),
          ProductListingScreen(),
          ProfileNotConnected(),
          ProfileNotConnected(), // Fallback if auth check fails
        ];
        _isLoading = false;
      });
    }
  }

  SvgPicture svgIcon(String src, {Color? color}) {
    return SvgPicture.asset(
      src,
      height: 24,
      colorFilter: ColorFilter.mode(
          color ??
              Theme.of(context).iconTheme.color!.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
          BlendMode.srcIn),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      // Navigate to the product listing screen with search results
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductListingScreen(initialSearchTerm: query.trim()),
        ),
      );
      _searchController.clear();
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Ensure current index is within bounds
    final safeIndex = _currentIndex.clamp(0, _pages.length - 1);
    if (_currentIndex != safeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentIndex = safeIndex);
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: blackColor40),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onSubmitted: _performSearch,
              )
            : const Text(
                "Ahaya",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                  letterSpacing: -0.5,
                  height: 1.2,
                  fontFamily: 'Comfortaa',
                ),
              ),
        actions: [
          IconButton(
            onPressed: _isSearching ? () => _performSearch(_searchController.text) : _toggleSearch,
            icon: SvgPicture.asset(
              "assets/icons/Search.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).textTheme.bodyLarge!.color!,
                BlendMode.srcIn,
              ),
            ),
          ),
          if (_isSearching)
            IconButton(
              onPressed: _toggleSearch,
              icon: const Icon(Icons.close),
            ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, notificationsScreenRoute),
            icon: SvgPicture.asset(
              "assets/icons/Notification.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).textTheme.bodyLarge!.color!,
                BlendMode.srcIn,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String choice) {
              // Handle menu item selection
              if (choice == EntryPoint.aPropos) {
                // Navigate to À propos screen or show dialog
              } else if (choice == EntryPoint.contact) {
                // Navigate to Contact screen or show dialog
              } else if (choice == EntryPoint.language) {
                Navigator.pushNamed(context, selectLanguageScreenRoute);
              }
            },
            itemBuilder: (BuildContext context) {
              return EntryPoint.choices.map((String choice) {
                Widget icon;
                if (choice == EntryPoint.aPropos) {
                  icon = const Icon(Icons.info_outline);
                } else if (choice == EntryPoint.contact) {
                  icon = const Icon(Icons.contact_mail_outlined);
                } else if (choice == EntryPoint.language) {
                  icon = const Icon(Icons.language_outlined);
                } else {
                  icon = const SizedBox.shrink(); // Default empty icon
                }
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      icon,
                      const SizedBox(width: 8), // Add some spacing between icon and text
                      Text(choice),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages.isNotEmpty ? _pages[safeIndex] : SizedBox.shrink(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: defaultPadding / 2),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() => _currentIndex = index.clamp(0, _pages.length - 1));
            }
          },
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF101015),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          selectedItemColor: primaryColor,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_outlined, color: primaryColor),
              label: "Acceuil",
            ),
            BottomNavigationBarItem(
              icon: svgIcon("assets/icons/Bag.svg"),
              activeIcon: svgIcon("assets/icons/Bag.svg", color: primaryColor),
              label: "Shop",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_outlined),
              activeIcon: Icon(Icons.favorite_border_outlined, color: primaryColor),
              label: "Favoris",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_outline, color: primaryColor),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
