import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _photoUrlController;
  bool _isLoading = false;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _photoUrlController = TextEditingController(text: user?.photoURL ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update Firebase Auth Profile
        String? photoUrl = _photoUrlController.text.trim();

        if (_imageFile != null) {
          photoUrl = await _uploadImage(_imageFile!);
        }

        if (photoUrl != null && photoUrl.isNotEmpty) {
          await user.updatePhotoURL(photoUrl);
        }
        await user.updateDisplayName(_nameController.text.trim());

        // Sync to Firestore
        await _firestoreService.saveUser(user);

        if (mounted) {
          SnackbarUtils.showSuccess(
            context,
            'Success',
            'Profile updated successfully',
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Error',
          'Failed to update profile: $e',
        );
      }
      developer.log(
        'Update profile error',
        error: e,
        name: 'ThoughtVault.Profile',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Beautiful Photo Upload Box
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : (_photoUrlController.text.isNotEmpty
                              ? Image.network(
                                  _photoUrlController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white54,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.white54,
                                )),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tap to change photo',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // Show source selection dialog
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (status.isPermanentlyDenied) {
          if (mounted) {
            _showSettingsDialog();
          }
          return;
        }
        if (!status.isGranted) return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Optimize size
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      developer.log(
        'Error picking image',
        error: e,
        name: 'ThoughtVault.Profile',
      );
      if (mounted) {
        SnackbarUtils.showError(context, 'Error', 'Error picking image: $e');
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'This app needs camera access to take profile photos. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Create storage ref: users/UID/profile.jpg
      final storageRef = FirebaseStorage.instance.ref().child(
        'users/${user.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Upload
      await storageRef.putFile(image);

      // Get URL
      return await storageRef.getDownloadURL();
    } catch (e) {
      developer.log(
        'Error uploading image',
        error: e,
        name: 'ThoughtVault.Profile',
      );
      rethrow;
    }
  }
}
