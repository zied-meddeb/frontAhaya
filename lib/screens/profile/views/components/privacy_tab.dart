import 'package:flutter/material.dart';

import '../../../../models/user_profile.dart';


class PrivacyTab extends StatelessWidget {
  final PrivacySettings privacy;
  final Function(PrivacySettings) onPrivacyChanged;
  final VoidCallback onChangePassword;
  final VoidCallback onDeleteAccount;

  const PrivacyTab({
    super.key,
    required this.privacy,
    required this.onPrivacyChanged,
    required this.onChangePassword,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Actions du compte
          _buildAccountActions(context),
        ],
      ),
    );
  }



  Widget _buildAccountActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions du compte',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onChangePassword,
            child: const Text('Changer le mot de passe'),
          ),
        ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDeleteAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer le compte'),
          ),
        ),
      ],
    );
  }
}
