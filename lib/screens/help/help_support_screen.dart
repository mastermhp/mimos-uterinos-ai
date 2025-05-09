import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  final List<Map<String, dynamic>> _faqs = [
    {
      "question": "How accurate is the cycle prediction?",
      "answer": "Our cycle prediction uses advanced algorithms based on your historical data. The more cycles you track, the more accurate the predictions become. Typically, after tracking 3 cycles, the accuracy significantly improves.",
      "isExpanded": false,
    },
    {
      "question": "Can I export my data?",
      "answer": "Yes, you can export your data in various formats including PDF, CSV, and JSON. Go to Profile > Export Data to download your information.",
      "isExpanded": false,
    },
    {
      "question": "How do I set up reminders?",
      "answer": "You can set up reminders by going to Profile > Reminders. There you can customize which notifications you want to receive and at what time.",
      "isExpanded": false,
    },
    {
      "question": "What is Doctor Mode?",
      "answer": "Doctor Mode is a feature that generates a comprehensive report of your cycle data that you can share with your healthcare provider. It includes cycle length, symptoms, and other relevant information.",
      "isExpanded": false,
    },
    {
      "question": "How do I cancel my premium subscription?",
      "answer": "To cancel your premium subscription, go to your device's subscription settings. For iOS, go to Settings > Apple ID > Subscriptions. For Android, go to Google Play Store > Subscriptions.",
      "isExpanded": false,
    },
  ];
  
  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFAQs(),
                const SizedBox(height: 24),
                _buildContactForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Help & Support",
          style: TextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          "Find answers to common questions or contact our support team.",
          style: TextStyles.subtitle1,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildFAQs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Frequently Asked Questions",
            style: TextStyles.heading4,
          ),
          const SizedBox(height: 16),
          ExpansionPanelList(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (index, isExpanded) {
              setState(() {
                _faqs[index]["isExpanded"] = !isExpanded;
              });
            },
            children: _faqs.map<ExpansionPanel>((faq) {
              return ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      faq["question"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faq["answer"],
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                isExpanded: faq["isExpanded"],
                backgroundColor: Colors.white,
                canTapOnHeader: true,
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contact Support",
              style: TextStyles.heading4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(
                  Icons.subject,
                  color: AppColors.primary,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a subject";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(
                  Icons.message,
                  color: AppColors.primary,
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              minLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a message";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            AnimatedGradientButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Submit form
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Your message has been sent. We'll get back to you soon!"),
                    ),
                  );
                  _subjectController.clear();
                  _messageController.clear();
                }
              },
              text: "Send Message",
              icon: Icons.send_rounded,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  "Email: support@mimosapp.com",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  "Phone: +1 (555) 123-4567",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms);
  }
}
