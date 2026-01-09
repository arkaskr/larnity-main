import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/path_extension.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/phone_number_input.dart';
import 'package:larnity/src/features/group/data/datasource/country_list_with_code.dart';
import 'package:larnity/src/features/group/data/models/country_model.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/profile/presentation/provider/profile_provider.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;

  // Password fields controllers
  late TextEditingController currentPasswordCtrl;
  late TextEditingController newPasswordCtrl;
  late TextEditingController confirmPasswordCtrl;

  bool _isUpdatingProfile = false;
  bool _isUpdatingPassword = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();

    final currentUser = ref.read(authProvider).user;

    firstNameCtrl = TextEditingController(text: currentUser?.firstName ?? "");
    lastNameCtrl = TextEditingController(text: currentUser?.lastName ?? "");
    phoneCtrl = TextEditingController(text: currentUser?.phoneNumber ?? "");

    // Initialize password controllers
    currentPasswordCtrl = TextEditingController();
    newPasswordCtrl = TextEditingController();
    confirmPasswordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => context.go(Routes.explore.p),
        ),
        title: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Back',
            style: AppTextStyles.bodyText2().copyWith(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.xs.ph,
              Text(
                'Profile Settings',
                style: AppTextStyles.headline1().copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSizes.lg.ph,

              // Profile Image Section
              _buildProfileImageSection(currentUser),

              AppSizes.lg.ph,

              // Name Row
              _buildNameFields(),

              AppSizes.lg.ph,

              // Phone Number Section
              _buildPhoneNumberSection(),

              AppSizes.lg.ph,

              // Update Profile Button
              _buildUpdateProfileButton(currentUser),

              AppSizes.xxlg.ph,

              // Change Password Section
              _buildChangePasswordSection(),

              AppSizes.xxlg.ph,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(UserModel? currentUser) {
    String getInitials() {
      String initials = "";
      if (currentUser?.firstName?.isNotEmpty == true) {
        initials += currentUser!.firstName![0];
      }
      if (currentUser?.lastName?.isNotEmpty == true) {
        initials += currentUser!.lastName![0];
      }
      if (initials.isEmpty) {
        initials = "U";
      }
      return initials.toUpperCase();
    }

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: _selectedImage != null
                      ? FileImage(File(_selectedImage!.path))
                      : (currentUser?.image != null
                            ? NetworkImage(currentUser!.image!) as ImageProvider
                            : null),
                  child: (_selectedImage == null && currentUser?.image == null)
                      ? Text(
                          getInitials(),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSizes.xs.ph,
          Text(
            'Profile Image',
            style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
          ),
          AppSizes.xxxs.ph,
          Text(
            'Tap to change',
            style: AppTextStyles.caption().copyWith(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateProfileButton(UserModel? currentUser) {
    return AppButton(
      onPressed: _isUpdatingProfile
          ? null
          : () async {
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("User not found"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Validate fields
              if (firstNameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("First name is required"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() => _isUpdatingProfile = true);

              try {
                String? imageUrl;

                // ✅ Upload image if selected
                if (_selectedImage != null) {
                  final supabase = ref.read(supabaseClientProvider);
                  final timestamp = DateTime.now().millisecondsSinceEpoch;
                  final fileName = 'profile_${currentUser.id}_$timestamp.jpg';
                  final filePath = 'profiles/$fileName';

                  final bytes = await File(_selectedImage!.path).readAsBytes();

                  await supabase.storage
                      .from('images')
                      .uploadBinary(
                        filePath,
                        bytes,
                        fileOptions: const FileOptions(
                          contentType: 'image/jpeg',
                          upsert: true,
                        ),
                      );

                  imageUrl = supabase.storage
                      .from('images')
                      .getPublicUrl(filePath);
                }

                final updatedUser = currentUser.copyWith(
                  firstName: firstNameCtrl.text.trim(),
                  lastName: lastNameCtrl.text.trim(),
                  phoneNumber: phoneCtrl.text.trim(),
                  image: imageUrl ?? currentUser.image, // ✅ Include image URL
                );

                await ref
                    .read(profileProvider.notifier)
                    .updateProfile(
                      user: updatedUser,
                      successCallBack: () {
                        // Update auth provider with new user data
                        ref.read(authProvider.notifier).updateUser(updatedUser);

                        // Clear selected image after successful upload
                        setState(() {
                          _selectedImage = null;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profile updated successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      failureCallBack: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $error"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error uploading image: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() => _isUpdatingProfile = false);
                }
              }
            },
      label: _isUpdatingProfile ? "Updating..." : "Update Profile",
      bgColor: _isUpdatingProfile ? Colors.grey[500]! : Colors.grey[300]!,
      labelStyle: AppTextStyles.button().copyWith(
        color: Colors.black,
        fontSize: 16,
      ),
      radius: AppSizes.xs,
      isExpanded: true,
      height: 48,
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: firstNameCtrl,
            style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
            decoration: _inputDecoration("First Name"),
          ),
        ),
        AppSizes.xs.pw,
        Expanded(
          child: TextFormField(
            controller: lastNameCtrl,
            style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
            decoration: _inputDecoration("Last Name"),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone Number",
          style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
        ),
        AppSizes.xxxs.ph,
        PhoneNumberInput(
          countries: CountryListWithCode.countries,
          initialCountry: CountryModel(
            name: "India",
            code: "+91",
            flag: "🇮🇳",
            codeAbbreviation: "IN",
            states: [],
          ),
          initialPhoneNumber: phoneCtrl.text,
          onPhoneNumberChanged: (phoneNumber, country) {
            setState(() {
              phoneCtrl.text = phoneNumber;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChangePasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Change Password Title
        Row(
          children: [
            Text(
              'Change Password',
              style: AppTextStyles.headline2().copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppSizes.xxs.ph,
        Text(
          'Update your account password securely.',
          style: AppTextStyles.bodyText2().copyWith(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        AppSizes.lg.ph,

        // Current Password
        _buildPasswordField(
          controller: currentPasswordCtrl,
          label: 'Current Password',
          hint: 'Enter current password',
          isFirst: true,
        ),
        AppSizes.lg.ph,

        // New Password
        _buildPasswordField(
          controller: newPasswordCtrl,
          label: 'New Password',
          hint: 'Enter new password',
        ),
        AppSizes.lg.ph,

        // Confirm Password
        _buildPasswordField(
          controller: confirmPasswordCtrl,
          label: 'Confirm Password',
          hint: 'Confirm new password',
          isLast: true,
        ),
        AppSizes.xlg.ph,

        // Update Password Button
        AppButton(
          onPressed: _isUpdatingPassword
              ? null
              : () async {
                  if (_validatePasswordFields()) {
                    setState(() => _isUpdatingPassword = true);

                    try {
                      // Call password update API
                      // This depends on your authentication implementation
                      // Example: await ref.read(authProvider.notifier).updatePassword(...)

                      await Future.delayed(
                        const Duration(seconds: 1),
                      ); // Simulate API call

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password updated successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Clear password fields after successful update
                      currentPasswordCtrl.clear();
                      newPasswordCtrl.clear();
                      confirmPasswordCtrl.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error updating password: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isUpdatingPassword = false);
                      }
                    }
                  }
                },
          label: _isUpdatingPassword ? "Updating..." : "Update Password",
          bgColor: _isUpdatingPassword ? Colors.grey[500]! : Colors.grey[300]!,
          labelStyle: AppTextStyles.button().copyWith(
            color: Colors.black,
            fontSize: 16,
          ),
          radius: AppSizes.xs,
          isExpanded: true,
          height: 48,
        ),
      ],
    );
  }

  // Add this method after initState
  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyText2().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSizes.xxxs.ph,
        TextFormField(
          controller: controller,
          obscureText: true,
          style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.darkBgContainer,
            hintText: hint,
            hintStyle: AppTextStyles.bodyText2().copyWith(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.sm,
            ),
          ),
        ),
      ],
    );
  }

  bool _validatePasswordFields() {
    if (currentPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter current password"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (newPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter new password"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (newPasswordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.darkBgContainer,
      hintText: hint,
      hintStyle: AppTextStyles.bodyText2().copyWith(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
    );
  }
}
