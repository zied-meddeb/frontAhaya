import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/screens/favoris/views/favoris_screen.dart';

import '../models/product_model.dart';
import '../providers/theme_provider.dart';
import '../screens/discover/views/all_products_screen.dart';
import '../screens/fournisseur/main_screen.dart';
import '../screens/preferences/views/pereference_screen.dart';
import '../screens/profile/views/profile_details.dart';
import 'screen_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<ThemeProvider>(context, listen: false).switchToAppTheme();
        });

        return const OnBordingScreen();
      });

    // case preferredLanuageScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const PreferredLanguageScreen(),
    //   );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
    case emailVerification:
      return MaterialPageRoute(
        builder: (context) {
          String email = settings.arguments as String;
          return EmailVerificationPage(email: email);
        },
      );

    case productDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          ProductModel product = settings.arguments as ProductModel;
          return ProductDetailsScreen(product: product);
        },
      );
    case productReviewsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProductReviewsScreen(),
      );
    // case addReviewsScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const AddReviewScreen(),
    //   );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );

    case discoverScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const DiscoverScreen(),
      );

    case searchScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      );
    // case searchHistoryScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SearchHistoryScreen(),
    //   );
    case bookmarkScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const FavoriteScreen(),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => ProfileScreen(),
      );
    case notificationsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      );
    case noNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NoNotificationScreen(),
      );
    case enableNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EnableNotificationScreen(),
      );
    case notificationOptionsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationOptionsScreen(),
      );

    case preferencesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const CategoriesSelectionPage(),
      );

    case emptyWalletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EmptyWalletScreen(),
      );
    case walletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const WalletScreen(),
      );
    case selectLanguageScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LanguageSelectorScreen(),
      );

    case allProductsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProductListingScreen(),
      );

    case profileDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(),
      );

    case supplierScreenRoute:
      return MaterialPageRoute(builder: (context) {
        // Set theme immediately before building the widget
        Provider.of<ThemeProvider>(context, listen: false)
            .setSupplierTheme(_isSupplierRoute(settings.name));

        return const MainScreen();
      });

    case fournissuerScreen:
      return MaterialPageRoute(builder: (context) {
        // Set theme immediately before building the widget
        Provider.of<ThemeProvider>(context, listen: false)
            .setSupplierTheme(_isSupplierRoute(settings.name));

        return const MainScreen();
      });


    default:
      return MaterialPageRoute(
        // Make a screen for undefine
        builder: (context) => const OnBordingScreen(),
      );
  }
}

bool _isSupplierRoute(String? routeName) {
  const supplierRoutes = [supplierScreenRoute, "supplier"];

  return supplierRoutes.contains(routeName);
}
