import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/offer_provider.dart';
import 'package:shop/providers/transaction_provider.dart';
import 'package:shop/providers/theme_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthService authService = AuthService();
  bool isLoggedIn = await authService.isLoggedIn();

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
  ));
}

// Thanks for using our template. You are using the free version of the template.
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shop Template by The Flutter Way',
            theme: themeProvider.getTheme(context),
            // Dark theme is inclided in the Full template
            themeMode: ThemeMode.light,
            onGenerateRoute: router.generateRoute,
            initialRoute: onbordingScreenRoute,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  viewInsets: EdgeInsets.zero,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}