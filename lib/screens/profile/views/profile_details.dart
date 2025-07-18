import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import 'components/privacy_tab.dart';
import 'components/profile_header.dart';
import 'components/profile_info_tab.dart';


class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;

  late UserProfile _profile;
  late NotificationSettings _notifications;
  late PrivacySettings _privacy;
  late PromoPreferences _promoPrefs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    _profile = UserProfile(
      name: "Marie Dubois",
      username: "@ahaya.user",
      email: "marie.dubois@email.com",

    );

    _notifications = NotificationSettings(
      email: true,
      push: true,
      sms: false,
    );

    _privacy = PrivacySettings(
      profilePublic: true,
      showEmail: false,
      showPhone: false,
    );

    _promoPrefs = PromoPreferences(
      category: "all",
      budget: "500",
      alertsEnabled: true,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
    if (!_isEditing) {
      _saveProfile();
    }
  }

  void _saveProfile() {
    // Logique de sauvegarde
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil sauvegardé avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareProfile() {
    // Logique de partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil partagé')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 800 : double.infinity,
              ),
              child: Column(
                children: [
                  // Header avec photo de profil
                  ProfileHeader(
                    profile: _profile,
                    isEditing: _isEditing,
                    onToggleEdit: _toggleEditing,
                    onShare: _shareProfile,
                    onImageUpload: () {
                      // Logique d'upload d'image
                      print('Upload image');
                    },
                  ),

                  const SizedBox(height: 24),

                  // Onglets
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Mon Profil'),
                            Tab(text: 'Confidentialité'),
                          ],
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                        ),
                        SizedBox(
                          height: 600,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ProfileInfoTab(
                                profile: _profile,
                                promoPrefs: _promoPrefs,
                                isEditing: _isEditing,
                                onProfileChanged: (updatedProfile) {
                                  setState(() {
                                    _profile = updatedProfile;
                                  });
                                },
                                onPromoPrefsChanged: (updatedPrefs) {
                                  setState(() {
                                    _promoPrefs = updatedPrefs;
                                  });
                                },
                              ),
                              PrivacyTab(
                                privacy: _privacy,
                                onPrivacyChanged: (updatedPrivacy) {
                                  setState(() {
                                    _privacy = updatedPrivacy;
                                  });
                                },
                                onChangePassword: _showChangePasswordDialog,
                                onDeleteAccount: _showDeleteAccountDialog,
                              ),
                            ],
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
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe actuel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mot de passe modifié')),
              );
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compte supprimé'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
