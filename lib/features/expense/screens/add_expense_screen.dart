import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../duo/providers/duo_provider.dart';
import '../providers/expense_provider.dart';
import '../../../main.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = AppConstants.expenseCategories[0];
  String _selectedPaymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _receiptImage;
  bool _isSubmitting = false;

  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'UPI',
    'Bank Transfer',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
                    primary: AppColors.white,
                    onPrimary: AppColors.black,
                    surface: AppColors.black,
                    onSurface: AppColors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.black,
                    onPrimary: AppColors.white,
                    surface: AppColors.white,
                    onSurface: AppColors.black,
                  ),
            dialogTheme: DialogTheme(
              backgroundColor: isDarkMode ? AppColors.black : AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // No need to update a controller as we're directly displaying the formatted date in the UI
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
                    primary: AppColors.white,
                    onPrimary: AppColors.black,
                    surface: AppColors.black,
                    onSurface: AppColors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.black,
                    onPrimary: AppColors.white,
                    surface: AppColors.white,
                    onSurface: AppColors.black,
                  ),
            dialogTheme: DialogTheme(
              backgroundColor: isDarkMode ? AppColors.black : AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        // Update the date to include the new time
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _getReceiptImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _receiptImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadReceipt(String userId, String expenseId) async {
    if (_receiptImage == null) return null;
    
    try {
      // Skip actual upload if using mock data
      if (useMockData) {
        debugPrint('Mock image upload for: ${_receiptImage!.path}');
        return 'https://example.com/receipts/$userId/$expenseId.jpg';
      }
      
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_receiptImage!.path)}';
      final String storagePath = 'receipts/$userId/$fileName';
      
      // Create reference to the file location in Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      // Upload the file
      final uploadTask = storageRef.putFile(_receiptImage!);
      
      // Show upload progress if needed
      // uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      //   final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      //   print('Upload progress: $progress');
      // });
      
      // Wait for upload to complete
      await uploadTask.whenComplete(() => debugPrint('Receipt upload complete'));
      
      // Get download URL
      final String downloadUrl = await storageRef.getDownloadURL();
      debugPrint('Receipt uploaded: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
        debugPrint('Error uploading receipt: $e');
      // Return null on error, but don't fail the whole expense creation
      return null;
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final duoProvider = Provider.of<DuoProvider>(context, listen: false);

    // Create a DateTime that combines the selected date and time
    final timestamp = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      // Get the current duo ID from the DuoProvider
      final currentDuo = duoProvider.currentDuo;
      if (currentDuo == null) {
        throw Exception('No active duo found. Please join or create a duo first.');
      }
      
      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      // Upload receipt if it exists
      String? receiptUrl;
      if (_receiptImage != null) {
        receiptUrl = await _uploadReceipt(authProvider.user!.id, "temp_id");
      }

      final success = await expenseProvider.addExpense(
        currentDuo.id,
        authProvider.user!.id,
        double.parse(_amountController.text),
        _selectedCategory,
        _descriptionController.text,
        receiptUrl,
        _selectedPaymentMethod,
        timestamp,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      } else if (expenseProvider.error != null) {
        _showErrorSnackBar(expenseProvider.error!);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final borderColor = isDarkMode ? AppColors.white : AppColors.black;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD EXPENSE'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Dot matrix pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: DotMatrixPainter(
                dotColor: borderColor.withOpacity(0.03),
                spacing: 20,
              ),
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount field
                    Text(
                      'AMOUNT',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontFamily: 'SpaceMono',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      hintText: 'Enter amount',
                      prefixText: '₹ ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Category selector
                    Text(
                      'CATEGORY',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontFamily: 'SpaceMono',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          icon: Icon(Icons.arrow_drop_down, color: textColor),
                          dropdownColor: isDarkMode ? AppColors.black : AppColors.white,
                          items: AppConstants.expenseCategories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SpaceMono',
                                  color: textColor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date and Time pickers
                    Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DATE',
                                style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                  fontFamily: 'SpaceMono',
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'SpaceMono',
                                          color: textColor,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: textColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Time picker
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TIME',
                                style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                  fontFamily: 'SpaceMono',
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedTime.format(context),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'SpaceMono',
                                          color: textColor,
                                        ),
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: textColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Description field
                    Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontFamily: 'SpaceMono',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Enter description',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment method selector
                    Text(
                      'PAYMENT METHOD',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontFamily: 'SpaceMono',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedPaymentMethod,
                          icon: Icon(Icons.arrow_drop_down, color: textColor),
                          dropdownColor: isDarkMode ? AppColors.black : AppColors.white,
                          items: _paymentMethods.map((String method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(
                                method,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SpaceMono',
                                  color: textColor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedPaymentMethod = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Receipt image selector
                    Text(
                      'RECEIPT (OPTIONAL)',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontFamily: 'SpaceMono',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _getReceiptImage,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _receiptImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(
                                  _receiptImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 32,
                                    color: textColor.withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add receipt image',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'SpaceMono',
                                      color: textColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit button
                    CustomButton(
                      text: 'ADD EXPENSE',
                      onPressed: () {
                        if (!_isSubmitting) {
                          _submitExpense();
                        }
                      },
                      isLoading: _isSubmitting,
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
}

// Custom painter for dot matrix pattern
class DotMatrixPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;

  DotMatrixPainter({
    required this.dotColor,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double dotSize = 1.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final paint = Paint()
          ..color = dotColor
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
} 