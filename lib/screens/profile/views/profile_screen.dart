import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/l10n/app_localizations.dart';

import '../../../services/auth_service.dart';
import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatefulWidget {
   ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  Map<String, String> credentials = {};
  @override
  void initState() {
  super.initState();

  _auth.getCredentials().then((value) {
  setState(() {
  credentials = value;
  });
  });

  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: ListView(
        children: [
          ProfileCard(
            name: "${credentials['nom']}",
            email: "${credentials['email']}",
            imageSrc: "http://www.gravatar.com/avatar/?d=mp",
            // proLableText: "Sliver",
            // isPro: true, if the user is pro
            press: () {
              Navigator.pushNamed(context, profileDetailsScreenRoute);
            },
          ),

          const SizedBox(height: defaultPadding),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              l10n.myProfile,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: l10n.favorites,
            svgSrc: "assets/icons/Wishlist.svg",
            press: () {},
          ),
          ProfileMenuListTile(
            text: l10n.settings,
            svgSrc: "assets/icons/Preferences.svg",
            press: () {
              Navigator.pushNamed(context, preferencesScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: l10n.language,
            svgSrc: "assets/icons/Language.svg",
            press: () {
              Navigator.pushNamed(context, selectLanguageScreenRoute);
            },
          ),

          const SizedBox(height: defaultPadding),


          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              l10n.help,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: l10n.help,
            svgSrc: "assets/icons/Help.svg",
            press: () {
              Navigator.pushNamed(context, getHelpScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "FAQ",
            svgSrc: "assets/icons/FAQ.svg",
            press: () {},
            isShowDivider: false,
          ),
          const SizedBox(height: defaultPadding),

          // Log Out
          ListTile(
            onTap: () async {await _auth.clearCredentials();
              Navigator.pushNamed(context, entryPointScreenRoute);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnexion réussie'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ));},
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: const Text(
              "Log Out",
              style: TextStyle(color: errorColor, fontSize: 14, height: 1),
            ),
          )
        ],
      ),
    );
  }
}
