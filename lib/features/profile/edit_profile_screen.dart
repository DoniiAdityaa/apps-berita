import 'package:app_berita/config/constant.dart';
import 'package:flutter/material.dart';
import 'package:app_berita/ui/color.dart';
import 'package:app_berita/ui/typography.dart';
import 'package:app_berita/config/service_locator.dart';
import 'package:app_berita/config/user_preference.dart';
import 'package:app_berita/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedAvatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    final userPref = serviceLocator.get<UserPreference>();
    final savedUser = userPref.getUser();

    setState(() {
      _fullNameController.text = user?.displayName ?? savedUser.name ?? '';
      _usernameController.text = savedUser.username?.replaceAll('@', '') ?? '';
      _bioController.text = savedUser.bio ?? '';
      _selectedAvatarUrl = savedUser.photo ?? user?.photoURL;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      // 1. Update ke Firebase Auth
      if (user != null) {
        await user.updateDisplayName(_fullNameController.text.trim());
        if (_selectedAvatarUrl != null) {
          await user.updatePhotoURL(_selectedAvatarUrl);
        }
      }

      // 2. Update ke UserPreference (Lokal)
      final userPref = serviceLocator.get<UserPreference>();
      final currentUserModel = userPref.getUser();

      final updatedUserModel = UserModel(
        id: currentUserModel.id ?? user?.uid,
        email: currentUserModel.email ?? user?.email,
        name: _fullNameController.text.trim(),
        username: '@${_usernameController.text.trim()}',
        bio: _bioController.text.trim(),
        photo: _selectedAvatarUrl,
      );

      await userPref.setUser(updatedUserModel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(
          context,
          true,
        ); // Kembali dan beri sinyal sukses untuk refresh halaman
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildAvatarSection(),
                        const SizedBox(height: 32),

                        _buildFieldLabel('Full Name'),
                        const SizedBox(height: 8),
                        _buildProfileTextField(
                          controller: _fullNameController,
                          hintText: 'Full Name',
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 24),

                        _buildFieldLabel('Username'),
                        const SizedBox(height: 8),
                        _buildProfileTextField(
                          controller: _usernameController,
                          hintText: 'Username',
                          keyboardType: TextInputType.text,
                          prefixText: '@',
                          enabled: false,
                        ),
                        const SizedBox(height: 24),

                        _buildFieldLabel('Bio'),
                        const SizedBox(height: 8),
                        _buildProfileTextField(
                          controller: _bioController,
                          hintText: 'Describe yourself...',
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET HELPER METHODS
  // ===========================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontFamily: 'poppins',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textNeutralPrimary,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: textNeutralPrimary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showAvatarPicker,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: _selectedAvatarUrl == null
                    ? Container(
                        color: bgSurfaceNeutral,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: iconNeutralSecondary,
                        ),
                      )
                    : Image.network(
                        _selectedAvatarUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: bgSurfaceNeutral,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: iconNeutralSecondary,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showAvatarPicker,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textNeutralPrimary,
      ),
    );
  }
  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    int maxLines = 1,
    String? prefixText,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(
        fontFamily: 'poppins',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: enabled ? textNeutralPrimary : textNeutralSecondary.withValues(alpha: 0.6),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: smRegular.copyWith(
          color: textNeutralSecondary.withValues(alpha: 0.4),
        ),
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontFamily: 'poppins',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: enabled ? textNeutralPrimary : textNeutralSecondary.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : bgSurfaceNeutral,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderNeutral),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderNeutral),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderNeutral),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      validator: (value) {
        if (enabled && (value == null || value.trim().isEmpty)) {
          return '$hintText cannot be empty';
        }
        return null;
      },
    );
  }
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String tempAvatarUrl = _selectedAvatarUrl ?? supportedAvatars[0];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 20.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: borderNeutral,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose Your Persona',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textNeutralPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select an avatar that represents you',
                      style: smRegular.copyWith(color: textNeutralSecondary),
                    ),
                    const SizedBox(height: 24),

                    // Cute Live Preview Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          tempAvatarUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: bgSurfaceNeutral,
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 50,
                                  color: iconNeutralSecondary,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid selection
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: supportedAvatars.length,
                      itemBuilder: (context, index) {
                        final avatarUrl = supportedAvatars[index];
                        final isSelected = tempAvatarUrl == avatarUrl;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempAvatarUrl = avatarUrl;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ClipOval(
                                child: Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.white),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: bgSurfaceNeutral,
                                        child: const Icon(
                                          Icons.person_rounded,
                                          color: iconNeutralSecondary,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Cute save button inside bottom sheet
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedAvatarUrl = tempAvatarUrl;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Avatar',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
