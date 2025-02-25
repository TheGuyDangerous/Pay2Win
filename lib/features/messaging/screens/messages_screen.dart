import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/message_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../duo/providers/duo_provider.dart';
import '../../expense/providers/expense_provider.dart';
import '../providers/messaging_provider.dart';
import '../../expense/screens/expense_details_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final duoProvider = Provider.of<DuoProvider>(context, listen: false);
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);

    if (duoProvider.currentDuo == null) {
      _showErrorSnackBar('No active duo found. Please join or create a duo first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await messagingProvider.getMessages(duoProvider.currentDuo!.id);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final duoProvider = Provider.of<DuoProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);

    if (duoProvider.currentDuo == null) {
      _showErrorSnackBar('No active duo found. Please join or create a duo first.');
      return;
    }

    if (authProvider.user == null) {
      _showErrorSnackBar('You must be logged in to send messages.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await messagingProvider.sendMessage(
        duoProvider.currentDuo!.id,
        authProvider.user!.id,
        text,
      );

      if (success) {
        _messageController.clear();
        // Scroll to the bottom after the message is sent
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else if (messagingProvider.error != null) {
        _showErrorSnackBar(messagingProvider.error!);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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

  void _showExpenseDetails(String expenseId) async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final duoProvider = Provider.of<DuoProvider>(context, listen: false);

    if (duoProvider.currentDuo == null) {
      _showErrorSnackBar('No active duo found.');
      return;
    }

    try {
      // Load the selected expense
      await expenseProvider.getExpenses(duoProvider.currentDuo!.id);
      
      // Find the expense with the matching ID
      final expense = expenseProvider.expenses.firstWhere(
        (e) => e.id == expenseId,
        orElse: () => throw Exception('Expense not found'),
      );
      
      // Set it as the selected expense
      expenseProvider.setSelectedExpense(expense);
      
      if (!mounted) return;
      
      // Navigate to the expense details screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ExpenseDetailsScreen(),
        ),
      );
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final messagingProvider = Provider.of<MessagingProvider>(context);
    final duoProvider = Provider.of<DuoProvider>(context);
    final messages = messagingProvider.messages;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Check if the duo exists
    final hasDuo = duoProvider.currentDuo != null;
    
    // Get colors based on theme
    final textColor = isDarkMode ? AppColors.white : AppColors.black;
    final borderColor = isDarkMode ? AppColors.white.withOpacity(0.3) : AppColors.black.withOpacity(0.3);
    final backgroundColor = isDarkMode ? AppColors.black : AppColors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MESSAGES"),
        centerTitle: true,
      ),
      body: !hasDuo
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off,
                    size: 64,
                    color: textColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No active duo found",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'SpaceMono',
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please join or create a duo first",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'SpaceMono',
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: "GO TO DUO SETUP",
                    onPressed: () {
                      // Navigate to duo setup screen
                      Navigator.of(context).pushNamed('/duo');
                    },
                    isLoading: false,
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Dot matrix pattern background
                Positioned.fill(
                  child: CustomPaint(
                    painter: DotMatrixPainter(
                      dotColor: textColor.withOpacity(0.03),
                      spacing: 20,
                    ),
                  ),
                ),
                Column(
                  children: [
                    // Messages list
                    Expanded(
                      child: _isLoading && messages.isEmpty
                          ? Center(
                              child: CircularProgressIndicator(
                                color: textColor,
                              ),
                            )
                          : messages.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: 64,
                                        color: textColor.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No messages yet",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'SpaceMono',
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Start the conversation!",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'SpaceMono',
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index];
                                    final prevMessage = index < messages.length - 1 ? messages[index + 1] : null;
                                    final showDateHeader = prevMessage == null || 
                                        !DateUtils.isSameDay(message.timestamp, prevMessage.timestamp);
                                    
                                    return Column(
                                      children: [
                                        if (showDateHeader)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            child: Center(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: borderColor),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  message.formattedDate,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'SpaceMono',
                                                    color: textColor.withOpacity(0.7),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        _buildMessageBubble(
                                          message,
                                          authProvider.user?.id == message.userId,
                                          textColor,
                                          borderColor,
                                          backgroundColor,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                    ),
                    
                    // Message input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border(
                          top: BorderSide(color: borderColor),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _messageController,
                              hintText: 'Type a message...',
                              maxLines: 4,
                              minLines: 1,
                              keyboardType: TextInputType.multiline,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _isLoading ? null : _sendMessage,
                            icon: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: textColor,
                                    ),
                                  )
                                : Icon(
                                    Icons.send,
                                    color: textColor,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    // Padding to handle keyboard
                    Padding(padding: MediaQuery.of(context).viewInsets),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
    bool isCurrentUser,
    Color textColor,
    Color borderColor,
    Color backgroundColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: borderColor,
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrentUser 
                        ? backgroundColor.withOpacity(0.1)
                        : backgroundColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontFamily: 'SpaceMono',
                        ),
                      ),
                      if (message.hasExpense && message.expenseId != null)
                        GestureDetector(
                          onTap: () => _showExpenseDetails(message.expenseId!),
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 16,
                                  color: AppColors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'View Expense',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textColor,
                                    fontFamily: 'SpaceMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Time stamp
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    message.formattedTime,
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor.withOpacity(0.6),
                      fontFamily: 'SpaceMono',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: borderColor,
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppColors.white,
              ),
            ),
          ],
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