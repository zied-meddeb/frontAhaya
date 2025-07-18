import 'package:flutter/material.dart';
import '../../../../models/user_profile.dart';
import '../../../../services/auth_service.dart';

class ProfileInfoTab extends StatefulWidget {
  final UserProfile profile;
  final PromoPreferences promoPrefs;
  final bool isEditing;
  final Function(UserProfile) onProfileChanged;
  final Function(PromoPreferences) onPromoPrefsChanged;

  const ProfileInfoTab({
    super.key,
    required this.profile,
    required this.promoPrefs,
    required this.isEditing,
    required this.onProfileChanged,
    required this.onPromoPrefsChanged,
  });

  @override
  State<ProfileInfoTab> createState() => _ProfileInfoTabState();
}

class _ProfileInfoTabState extends State<ProfileInfoTab> {
  late Map<String, String> credentials;
  bool isLoading = true;
  String? errorMessage;

  final AuthService authService = AuthService();

  Future<void> getCredentials() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final creds = await authService.getCredentials();

      if (mounted) {
        setState(() {
          credentials = creds;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load credentials';
          isLoading = false;
        });
      }
      debugPrint('Error loading credentials: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    credentials = {};
    getCredentials();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations personnelles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Gérez vos informations de profil',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Form fields grid
          _buildFormGrid(),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // Save button when in editing mode
          if (widget.isEditing) _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          // Save the updated profile information
          await authService.saveCredentials(
            widget.profile.email,
            widget.profile.name,
            await authService.getUserId() ?? '',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: $e')),
          );
        }
      },
      child: const Text('Save Profile'),
    );
  }

  Widget _buildFormGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Nom complet',
                credentials['nom'] ?? widget.profile.name,
                    (value) {
                  widget.onProfileChanged(UserProfile(
                    name: value,
                    username: widget.profile.username,
                    email: widget.profile.email,
                  ));
                  setState(() {
                    credentials['nom'] = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Email',
                credentials['email'] ?? widget.profile.email,
                    (value) {
                  widget.onProfileChanged(UserProfile(
                    name: widget.profile.name,
                    username: widget.profile.username,
                    email: value,
                  ));
                  setState(() {
                    credentials['email'] = value;
                  });
                },
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      String value,
      Function(String) onChanged, {
        TextInputType? keyboardType,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          enabled: widget.isEditing,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: !widget.isEditing,
            fillColor: widget.isEditing ? null : Colors.grey[100],
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
