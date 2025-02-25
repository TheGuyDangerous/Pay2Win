import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/dot_matrix_background.dart';
import '../providers/duo_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../main.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DuoManagementScreen extends StatefulWidget {
  const DuoManagementScreen({super.key});

  @override
  State<DuoManagementScreen> createState() => _DuoManagementScreenState();
}

class _DuoManagementScreenState extends State<DuoManagementScreen> {
  bool _isLoading = false;
  bool _confirmingLeave = false;
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final duoProvider = Provider.of<DuoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentDuo = duoProvider.currentDuo;
    final currentUser = authProvider.user;
    
    if (currentDuo == null || currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('DUO MANAGEMENT')),
        body: const Center(child: Text('No active duo found')),
      );
    }
    
    // Get the partner information
    final isUser1 = currentUser.id == currentDuo.user1Id;
    final partnerId = isUser1 ? currentDuo.user2Id : currentDuo.user1Id;
    final partnerName = isUser1 ? currentDuo.user2Name : currentDuo.user1Name;
    
    // Determine if the duo is complete (has 2 users)
    final isDuoComplete = currentDuo.isComplete;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('DUO MANAGEMENT', style: TextStyle(fontSize: 18, letterSpacing: 1.5),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          const DotMatrixBackground(),
          
          // Main Content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await duoProvider.initialize();
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Duo Connection Visualization
                    _buildDuoConnection(
                      context: context,
                      currentUser: currentUser,
                      partnerId: partnerId,
                      partnerName: partnerName,
                      isDuoComplete: isDuoComplete,
                    ),
                    const SizedBox(height: 40),
                    
                    // Duo Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: AppColors.white.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DUO INFORMATION',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Divider(color: AppColors.lightGrey),
                          const SizedBox(height: 8),
                          
                          // Duo Code
                          _buildInfoRow(
                            label: 'Duo Code', 
                            value: currentDuo.code,
                            copyable: true,
                          ),
                          
                          // Creation Date
                          _buildInfoRow(
                            label: 'Created On',
                            value: _formatDate(currentDuo.createdAt),
                          ),
                          
                          // Status
                          _buildInfoRow(
                            label: 'Status',
                            value: isDuoComplete ? 'Active' : 'Waiting for partner',
                            valueColor: isDuoComplete ? Colors.green : Colors.orange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Invite Link Section (only shown if duo is not complete)
                    if (!isDuoComplete) ...[
                      const Text(
                        'INVITE YOUR PARTNER',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Share this code with your friend to complete your duo:',
                        style: TextStyle(
                          color: AppColors.lightGrey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Invite Button
                      CustomButton(
                        text: 'SHARE INVITE CODE',
                        icon: Icons.share,
                        onPressed: () => _shareInviteCode(context, currentDuo.code),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Divider before actions
                    const Divider(color: AppColors.lightGrey),
                    const SizedBox(height: 16),
                    
                    // Management Actions
                    if (!_confirmingLeave) ...[
                      CustomButton(
                        text: 'LEAVE DUO',
                        icon: Icons.exit_to_app,
                        color: Colors.red.shade800,
                        
                        onPressed: () {
                          setState(() {
                            _confirmingLeave = true;
                          });
                        },
                      ),
                    ] else ...[
                      const Text(
                        'Are you sure you want to leave this duo?',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'CANCEL',
                              icon: Icons.close,
                              onPressed: () {
                                setState(() {
                                  _confirmingLeave = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: 'CONFIRM',
                              icon: Icons.check,
                              color: Colors.red.shade800,
                              isLoading: _isLoading,
                              onPressed: () => _leaveDuo(context, duoProvider),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the duo connection visualization with user profiles
  Widget _buildDuoConnection({
    required BuildContext context,
    required dynamic currentUser,
    required String? partnerId,
    required String? partnerName,
    required bool isDuoComplete,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Current User
            _buildUserProfile(
              name: currentUser.displayName,
              imageUrl: currentUser.profilePicture,
              isCurrentUser: true,
            ),
            
            // VS Text
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white.withOpacity(0.5)),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isDuoComplete)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Partner (or empty slot)
            _buildUserProfile(
              name: partnerName,
              imageUrl: null, // We don't have profile pics yet
              isCurrentUser: false,
              isEmpty: !isDuoComplete,
            ),
          ],
        ),
      ],
    );
  }
  
  // Build individual user profile display
  Widget _buildUserProfile({
    required String? name,
    required String? imageUrl,
    required bool isCurrentUser,
    bool isEmpty = false,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            // Profile avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isEmpty ? AppColors.lightGrey.withOpacity(0.5) : AppColors.white,
                  width: 1,
                ),
              ),
              child: isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.person_add_outlined,
                        color: AppColors.lightGrey,
                        size: 36,
                      ),
                    )
                  : ClipOval(
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  color: AppColors.white,
                                  size: 36,
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                name != null && name.isNotEmpty
                                    ? name.substring(0, 1).toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
            ),
            // Edit icon for current user
            if (isCurrentUser && !isEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _showProfilePictureOptions(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isEmpty ? 'Waiting...' : (name ?? 'Unknown'),
          style: TextStyle(
            color: isEmpty ? AppColors.lightGrey : AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isEmpty ? 'Share your code' : (isCurrentUser ? 'YOU' : 'PARTNER'),
          style: TextStyle(
            color: isEmpty ? AppColors.lightGrey.withOpacity(0.7) : AppColors.lightGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  // Build information row with label and value
  Widget _buildInfoRow({
    required String label,
    required String value,
    bool copyable = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.lightGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(
                Icons.copy,
                color: AppColors.lightGrey,
                size: 18,
              ),
              onPressed: () => _copyToClipboard(context, value),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
  
  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // Helper method to copy text to clipboard
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  // Helper method to share invite code
  void _shareInviteCode(BuildContext context, String code) async {
    await Share.share(
      'Join my Pay2Win savings duo! Use code: $code',
      subject: 'Pay2Win Duo Invitation',
    );
  }
  
  // Helper method to leave duo
  Future<void> _leaveDuo(BuildContext context, DuoProvider duoProvider) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await duoProvider.leaveDuo();
      
      if (!mounted) return;
      
      if (success) {
        navigator.pushReplacementNamed(AppConstants.routeDuoSelector);
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to leave duo: ${duoProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _confirmingLeave = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show bottom sheet for profile picture selection
  void _showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? Colors.white : Colors.black;
        
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Profile Picture Options',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: textColor),
                title: Text(
                  'Take a photo',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: textColor),
                title: Text(
                  'Choose from gallery',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageSource(ImageSource.gallery);
                },
              ),
              // Add a Delete option with a red icon for emphasis
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Remove profile picture',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Helper method to handle profile image selection
  Future<void> _selectImageSource(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _pickImage(source);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        // Show loading state
        setState(() {
          _isLoading = true;
        });
        
        String? downloadUrl;
        try {
          // Skip actual upload if using mock data
          if (useMockData) {
            await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
            downloadUrl = 'https://example.com/profile/${DateTime.now().millisecondsSinceEpoch}.jpg';
            debugPrint('Mock profile image upload: $downloadUrl');
          } else {
            // Upload to Firebase Storage
            final File imageFile = File(pickedFile.path);
            final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(pickedFile.path)}';
            final String storagePath = 'profile_images/${_authProvider!.user!.id}/$fileName';
            
            // Create reference to the file location in Firebase Storage
            final storageRef = FirebaseStorage.instance.ref().child(storagePath);
            
            // Upload the file
            final uploadTask = storageRef.putFile(imageFile);
            
            // Wait for upload to complete
            await uploadTask.whenComplete(() =>  debugPrint('Profile image upload complete'));
            
            // Get download URL
            downloadUrl = await storageRef.getDownloadURL();
            debugPrint('Profile image uploaded: $downloadUrl');
          }
          
          // Update the user's profile picture
          // ignore: unnecessary_null_comparison
          if (downloadUrl != null) {
            await _authProvider!.updateProfilePicture(downloadUrl);
          }
        } catch (e) {
          debugPrint('Error uploading profile image: $e');
          _showSnackBar('Failed to upload profile image: ${e.toString()}');
        } finally {
          // Hide loading state
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showSnackBar('Failed to select image: ${e.toString()}');
    }
  }
  
  // Remove profile picture
  Future<void> _removeProfilePicture() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Pass empty string to indicate profile picture removal
      if (_authProvider != null) {
        await _authProvider!.updateProfilePicture('');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture removed successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Could not access auth provider')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error removing profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove profile picture: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

// Custom button with icon support
class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  
  const CustomButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.transparent,
          foregroundColor: AppColors.white,
          side: BorderSide(color: color != null ? color! : AppColors.white, width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
} 