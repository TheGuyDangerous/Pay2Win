import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/dot_matrix_background.dart';
import '../providers/duo_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class CreateDuoScreen extends StatefulWidget {
  const CreateDuoScreen({super.key});

  @override
  State<CreateDuoScreen> createState() => _CreateDuoScreenState();
}

class _CreateDuoScreenState extends State<CreateDuoScreen> {
  String? _generatedCode;
  bool _isLoading = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  // Generate a new code for the duo
  Future<void> _generateCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final duoProvider = Provider.of<DuoProvider>(context, listen: false);
      final code = await duoProvider.generateCode();
      
      setState(() {
        _generatedCode = code;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating code: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Create the duo with the generated code
  Future<void> _createDuo() async {
    if (_generatedCode == null) return;
    
    setState(() {
      _isCreating = true;
    });

    try {
      final duoProvider = Provider.of<DuoProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.user == null) {
        throw Exception("User is not authenticated");
      }
      
      await duoProvider.createDuo(
        authProvider.user!.id,
        authProvider.user!.displayName,
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating duo: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  // Share the generated code
  Future<void> _shareCode() async {
    if (_generatedCode == null) return;
    
    await Share.share(
      'Join my Pay2Win savings duo! Use code: $_generatedCode',
      subject: 'Pay2Win Duo Invitation',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Background
          const DotMatrixBackground(),
          
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.white.withOpacity(0.5), width: 1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      'CREATE A NEW DUO',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      'Generate a unique code and share it with your friend to start saving together.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Generated code section
                    if (_isLoading)
                      const CircularProgressIndicator(color: AppColors.white)
                    else if (_generatedCode != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: AppColors.white, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'YOUR CODE',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.lightGrey,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _generatedCode!,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 5.0,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(
                                    Icons.copy,
                                    color: AppColors.white,
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _generatedCode!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Code copied to clipboard'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 40),
                    
                    // Actions
                    if (_generatedCode != null) ...[
                      // Share button
                      _buildButton(
                        icon: Icons.share,
                        text: 'SHARE CODE',
                        onPressed: _shareCode,
                      ),
                      const SizedBox(height: 16),
                      
                      // Create button
                      _buildButton(
                        icon: Icons.check_circle_outline,
                        text: 'CREATE DUO',
                        onPressed: _isCreating ? null : _createDuo,
                        isLoading: _isCreating,
                      ),
                    ] else
                      _buildButton(
                        icon: Icons.refresh,
                        text: 'GENERATE NEW CODE',
                        onPressed: _generateCode,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.white, width: 1),
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
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
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