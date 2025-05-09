import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/models/user_data.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/services/ai_service.dart';
import 'package:menstrual_health_ai/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final AIService _aiService = AIService();
  
  // Chat messages
  final List<Map<String, dynamic>> _messages = [];
  
  // Suggested questions
  final List<String> _suggestedQuestions = [
    "How can I manage my ovulation symptoms?",
    "What foods should I eat during my period?",
    "Why am I feeling more tired than usual?",
    "How can I reduce period pain naturally?",
    "What exercise is best during my luteal phase?",
  ];

  @override
  void initState() {
    super.initState();
    // Add initial AI greeting with a slight delay to allow the screen to build
    Future.delayed(const Duration(milliseconds: 300), () {
      _addInitialGreeting();
    });
  }
  
  void _addInitialGreeting() async {
    final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
    
    setState(() {
      _isTyping = true;
    });
    
    String greeting = "Hello! I'm your Mimos Uterinos AI health coach. How can I help you today?";
    
    if (userData != null) {
      greeting = "Hello ${userData.name}! I'm your Mimos Uterinos AI health coach. I'm here to provide personalized insights based on your cycle data. How can I help you today?";
    }
    
    // Simulate AI typing delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _messages.add({
        'isUser': false,
        'message': greeting,
        'timestamp': DateTime.now(),
      });
      _isTyping = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
    
    // If no user data, show an error message
    if (userData == null) {
      setState(() {
        _messages.add({
          'isUser': false,
          'message': "I'm sorry, but I don't have your profile data yet. Please complete the onboarding process to get personalized insights.",
          'timestamp': DateTime.now(),
        });
      });
      return;
    }
    
    setState(() {
      // Add user message
      _messages.add({
        'isUser': true,
        'message': message,
        'timestamp': DateTime.now(),
      });
      
      // Clear input field
      _messageController.clear();
      
      // Show typing indicator
      _isTyping = true;
    });
    
    // Scroll to bottom
    _scrollToBottom();
    
    try {
      // Get AI response using the AI service
      final response = await _aiService.generateCoachResponse(
        message,
        userData,
      );
      
      setState(() {
        _isTyping = false;
        
        // Add AI response
        _messages.add({
          'isUser': false,
          'message': response,
          'timestamp': DateTime.now(),
        });
      });
      
      // Scroll to bottom after response
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isTyping = false;
        
        // Add error message
        _messages.add({
          'isUser': false,
          'message': "I'm sorry, I encountered an error processing your request. Please try again later.",
          'timestamp': DateTime.now(),
        });
      });
      
      // Scroll to bottom after error
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: "Mimos Uterinos AI Coach",
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Typing indicator
                  return _buildTypingIndicator();
                }
                
                final message = _messages[index];
                return _buildMessageBubble(
                  message: message['message'],
                  isUser: message['isUser'],
                  timestamp: message['timestamp'],
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 10, end: 0);
              },
            ),
          ),
          
          // Suggested questions
          if (_messages.length < 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Suggested Questions",
                    style: TextStyles.subtitle2,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedQuestions.map((question) {
                      return GestureDetector(
                        onTap: () {
                          _sendMessage(question);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            question,
                            style: TextStyles.caption.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 800.ms)
            .slideY(delay: 500.ms, begin: 20, end: 0),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyles.body2,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Ask Mimos AI...",
                          hintStyle: TextStyles.body2.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.mic_rounded,
                              color: AppColors.primary,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _sendMessage(_messageController.text);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isUser,
    required DateTime timestamp,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
            ),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyles.body2.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          if (isUser)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(delay: 300),
                const SizedBox(width: 4),
                _buildDot(delay: 600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({int delay = 0}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
    )
    .animate(
      onPlay: (controller) => controller.repeat(),
    )
    .scale(
      begin: const Offset(0.5, 0.5),
      end: const Offset(1, 1),
      duration: 600.ms,
      delay: Duration(milliseconds: delay),
      curve: Curves.easeInOut,
    )
    .then()
    .scale(
      begin: const Offset(1, 1),
      end: const Offset(0.5, 0.5),
      duration: 600.ms,
      curve: Curves.easeInOut,
    );
  }
}
