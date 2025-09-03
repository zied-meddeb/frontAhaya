import 'package:flutter/material.dart';
import '../../../../models/user_profile.dart';
import '../../../../services/auth_service.dart';
import '../../../../constants.dart';

class ProfileHeader extends StatefulWidget {
  final UserProfile profile;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final VoidCallback onShare;
  final VoidCallback onImageUpload;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onShare,
    required this.onImageUpload,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
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
    credentials = {}; // Initialize with empty map
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

    final isWeb = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isWeb
          ? _buildWebLayout(context)
          : _buildMobileLayout(context),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: _buildProfileImage(),
        ),
        const SizedBox(width: 32),
        Flexible(
          flex: 3,
          child: _buildProfileInfo(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildProfileImage(),
        const SizedBox(height: 24),
        _buildProfileInfo(context),
      ],
    );
  }

  Widget _buildProfileImage() {
    final initials = credentials['nom']?.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join() ?? '?';

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: blackColor10,
            backgroundImage: widget.profile.profileImageUrl != null
                ? NetworkImage(widget.profile.profileImageUrl!)
                : null,
            child: widget.profile.profileImageUrl == null
                ? Text(
              initials,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          if (widget.isEditing)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: widget.onImageUpload,
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          credentials['nom'] ?? 'No name',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          credentials['email'] ?? 'No email',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: blackColor40,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton.icon(
            onPressed: widget.onToggleEdit,
            icon: Icon(widget.isEditing ? Icons.save : Icons.edit),
            label: Text(widget.isEditing ? 'Save' : 'Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isEditing ? successColor : primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
