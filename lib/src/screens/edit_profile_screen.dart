import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/store_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _imagePicker = ImagePicker();
  String? _profileImageBase64;
  bool _isSaving = false;
  bool _didLoadInitialValues = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialValues) {
      return;
    }
    final controller = StoreScope.of(context);
    _profileImageBase64 = controller.profileImageBase64;
    _didLoadInitialValues = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    _EditableAvatar(imageBase64: _profileImageBase64),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.brand,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _pickImage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Choose Image'),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _isSaving ? 'Saving...' : 'Save Changes',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<_ImageSourceOption>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Photo Library'),
              onTap: () =>
                  Navigator.of(context).pop(_ImageSourceOption.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Choose from Files'),
              onTap: () => Navigator.of(context).pop(_ImageSourceOption.files),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      return;
    }

    if (source == _ImageSourceOption.gallery) {
      await _pickFromGallery();
      return;
    }

    await _pickFromFiles();
  }

  Future<void> _pickFromGallery() async {
    if (!Platform.isIOS) {
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) {
        return;
      }
    }

    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _profileImageBase64 = base64Encode(bytes);
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      final message = Platform.isIOS
          ? 'Unable to open iPhone photo library right now. Please allow Photos access and try again.'
          : 'Unable to open photo library right now.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      debugPrint('Gallery pick failed: ${error.code} ${error.message}');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Platform.isIOS
                ? 'Unable to open iPhone photo library right now. Please try again.'
                : 'Unable to open photo library right now.',
          ),
        ),
      );
    }
  }

  Future<bool> _requestGalleryPermission() async {
    PermissionStatus status;

    if (Platform.isIOS) {
      return true;
    } else if (Platform.isAndroid) {
      status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) {
        status = await Permission.storage.request();
      }
    } else {
      return true;
    }

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Photo permission is blocked. Please allow it in Settings.',
          ),
          action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
        ),
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please allow photo permission to choose an image from gallery.',
        ),
      ),
    );
    return false;
  }

  Future<void> _pickFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final selectedFile = result.files.single;
      Uint8List? bytes = selectedFile.bytes;
      final path = selectedFile.path;
      if ((bytes == null || bytes.isEmpty) && path != null && path.isNotEmpty) {
        bytes = await File(path).readAsBytes();
      }

      if (bytes == null || bytes.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to read the selected image.')),
        );
        return;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _profileImageBase64 = base64Encode(bytes!);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Platform.isIOS
                ? 'Unable to open Files on iPhone right now.'
                : 'Unable to open files right now.',
          ),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final controller = StoreScope.of(context);
    final user = controller.currentUser;
    await controller.saveProfile(
      firstName: user?.firstName ?? '',
      lastName: user?.lastName ?? '',
      email: user?.email ?? '',
      phone: user?.phone ?? '',
      profileImageBase64: _profileImageBase64,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
    Navigator.of(context).pop();
  }
}

enum _ImageSourceOption { gallery, files }

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({required this.imageBase64});

  final String? imageBase64;

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeBytes(imageBase64);

    return CircleAvatar(
      radius: 52,
      backgroundColor: Colors.white,
      child: bytes != null
          ? ClipOval(
              child: Image.memory(
                bytes,
                width: 104,
                height: 104,
                fit: BoxFit.cover,
              ),
            )
          : const Icon(Icons.engineering, size: 54, color: AppTheme.brand),
    );
  }

  Uint8List? _decodeBytes(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }
}
