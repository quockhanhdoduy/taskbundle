import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../services/storage_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with RouteAware {
  late final AuthController _authController;
  late final UserController _userController;
  bool _isLoading = true;
  bool _isUpdatingName = false;
  bool _isChangingPassword = false;
  Map<String, dynamic>? _userData;

  // Form controllers
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form keys
  final _nameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _userController = Get.put(UserController());
    _loadUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always reload when returning to this screen
    if (mounted) {
      // Add a small delay to ensure the route is fully loaded
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _loadUserProfile();
        }
      });
    }
  }

  @override
  void didUpdateWidget(ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when widget is updated
    _loadUserProfile();
  }

  // Method to reload profile data
  void reloadProfile() {
    _loadUserProfile();
  }

  // Method to force refresh profile from server
  Future<void> forceRefreshProfile() async {
    setState(() => _isLoading = true);
    await _loadUserProfile();
  }

  @override
  void didPopNext() {
    // Called when returning to this route from another route
    super.didPopNext();
    _loadUserProfile();
  }

  @override
  void didPushNext() {
    // Called when navigating away from this route
    super.didPushNext();
  }


  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      // Always fetch fresh data from server first
      final serverData = await _userController.loadUserProfile();

      if (serverData != null && serverData.isNotEmpty) {
        // Use server data if available
        setState(() {
          _userData = {
            'name': serverData['name'] ?? 'Unknown User',
            'email': serverData['email'] ?? 'No email',
            'createdAt': serverData['createdAt'],
          };
        });
        _nameController.text = serverData['name']?.toString() ?? '';

        // Update auth controller with fresh data
        if (serverData['name'] != null || serverData['email'] != null) {
          final currentUser = _authController.currentUser.value;
          if (currentUser != null) {
            final updatedUser = currentUser.copyWith(
              name: serverData['name'],
              email: serverData['email'],
            );
            _authController.currentUser.value = updatedUser;

            // Update storage with fresh data
            final storageService = StorageService();
            await storageService.saveUserData(serverData);
          }
        }
      } else {
        // Fallback to local data if server request fails
        final user = _authController.currentUser.value;
        if (user != null) {
          setState(() {
            _userData = {
              'name': user.name,
              'email': user.email,
              'createdAt': user.createdAt,
            };
          });
          _nameController.text = user.name;
        } else {
          // Last resort: try to load from storage directly
          final storageService = StorageService();
          final userData = await storageService.getUserData();

          if (userData != null) {
            setState(() {
              _userData = {
                'name': userData['name'] ?? 'Unknown User',
                'email': userData['email'] ?? 'No email',
                'createdAt': userData['createdAt'],
              };
            });
            _nameController.text = userData['name']?.toString() ?? '';
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: ${e.toString()}');

      // Fallback to local data on error
      final user = _authController.currentUser.value;
      if (user != null) {
        setState(() {
          _userData = {
            'name': user.name,
            'email': user.email,
            'createdAt': user.createdAt,
          };
        });
        _nameController.text = user.name;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildEditNameSection(),
                    const SizedBox(height: 24),
                    _buildChangePasswordSection(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[400],
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Name - Use reactive approach for real-time updates
          Obx(() => Text(
            _userController.userProfileData.isNotEmpty
                ? (_userController.userProfileData['name'] ?? _userData?['name'] ?? 'Unknown User')
                : (_userData?['name'] ?? 'Unknown User'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )),
          const SizedBox(height: 4),
          // Email - Use reactive approach for real-time updates
          Obx(() => Text(
            _userController.userProfileData.isNotEmpty
                ? (_userController.userProfileData['email'] ?? _userData?['email'] ?? 'No email')
                : (_userData?['email'] ?? 'No email'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEditNameSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Name',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _nameFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length > 150) {
                      return 'Name must be less than 150 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUpdatingName ? null : _updateName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isUpdatingName
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Update Name'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _passwordFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter current password';
                    }
                    if (value.length < 8) {
                      return 'Current password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    // Check for strong password: min 1 lowercase, 1 uppercase, 1 number, 1 symbol
                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
                      return 'Password must contain: 1 lowercase, 1 uppercase, 1 number, 1 symbol';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please confirm new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChangingPassword ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isChangingPassword
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Change Password'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateName() async {
    if (!_nameFormKey.currentState!.validate()) return;

    setState(() => _isUpdatingName = true);
    try {
      final updatedData = await _userController.updateUserProfile({
        'name': _nameController.text.trim(),
      });

      if (updatedData != null) {
        // Update local UI data with server response
        setState(() {
          _userData = {
            'name': updatedData['name'] ?? _nameController.text.trim(),
            'email': updatedData['email'] ?? _userData?['email'] ?? 'No email',
            'createdAt': updatedData['createdAt'] ?? _userData?['createdAt'],
          };
        });

        // Update auth controller with fresh data from server
        final user = _authController.currentUser.value;
        if (user != null) {
          final updatedUser = user.copyWith(
            name: updatedData['name'] ?? _nameController.text.trim(),
            email: updatedData['email'] ?? user.email,
          );
          _authController.currentUser.value = updatedUser;

          // Update storage with fresh data from server
          final storageService = StorageService();
          await storageService.saveUserData(updatedData);
        }

        // UserController.userProfileData is already updated by updateUserProfile method
        // UI will automatically update via Obx reactive widgets
        Get.snackbar('Success', 'Name updated successfully');
      } else {
        // Show error message from UserController
        final errorMsg = _userController.errorMessage.value;
        if (errorMsg.isNotEmpty) {
          Get.snackbar('Error', errorMsg);
        } else {
          Get.snackbar('Error', 'Failed to update name');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update name: ${e.toString()}');
    } finally {
      setState(() => _isUpdatingName = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isChangingPassword = true);
    try {
      final success = await _userController.changePassword(
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );

      if (success) {
        // Clear password fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        Get.snackbar('Success', 'Password changed successfully');
      } else {
        // Show error message from UserController
        final errorMsg = _userController.errorMessage.value;
        if (errorMsg.isNotEmpty) {
          Get.snackbar('Error', errorMsg);
        } else {
          Get.snackbar('Error', 'Failed to change password');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to change password: ${e.toString()}');
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }
}