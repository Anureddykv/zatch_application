
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zatch/sellersscreens/model/faq_item.dart';

class FaqScreen extends StatelessWidget {
  FaqScreen({super.key});

  final List<FaqItem> faqItems = [
    FaqItem(
      question: 'How do I unlock my seller access?',
      answer: 'This is the answer to how you unlock seller access.',
    ),
    FaqItem(
      question: 'Can I have a second selling account?',
      answer: "At this time, we are only allowing established sellers who've demonstrated consistency and reputability to have a second seller account based on the criteria outlined in our ",
      policyText: 'Policy',
    ),
    FaqItem(
      question: 'When can I schedule a show?',
      answer: 'This is the answer to when you can schedule a show.',
    ),
    FaqItem(
      question: 'How and when do I get paid?',
      answer: 'This is the answer to how and when you get paid.',
    ),
    FaqItem(
      question: 'Do I need to show my face on camera?',
      answer: 'This is the answer to whether you need to show your face.',
    ),
    FaqItem(
      question: 'Can I sell if I’m under 18?',
      answer: 'This is the answer regarding selling if you are under 18.',
    ),
    FaqItem(
      question: 'How does shipping work?',
      answer: 'This is the answer to how shipping works.',
    ),
    FaqItem(
      question: 'What are the fees?',
      answer: 'This is the answer about the fees.',
    ),
    FaqItem(
      question: 'What is your tax policy?',
      answer: 'This is the answer about the tax policy.',
    ),
  ];
  void _sendEmail(BuildContext context) async { // Pass BuildContext
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'Zatchshop@gmail.com',
      queryParameters: {
        'subject': 'Help Request from Zatch App',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email app. Is one installed?'),
        ),
      );
      print('Could not launch ${emailLaunchUri.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchField(),
            const SizedBox(height: 32),
            _buildFaqList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomHelpSection(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFDFDEDE)),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          ),
        ),
      ),
      title: const Text(
        "FAQ's",
        style: TextStyle(
          color: Color(0xFF121111),
          fontSize: 16,
          fontFamily: 'Encode Sans',
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We are here to help you with anything and\nEverything on Zatch',
          style: TextStyle(
            color: Color(0xFF191919),
            fontSize: 16,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque dictum augue arcu, hendrerit lobortis neque malesuada sit amet. Quisque scelerisque ut massa in convallis. Vivamus ut gravida elit. In pulvinar, ',
          style: TextStyle(
            color: Color(0xFF9A9A9A),
            fontSize: 12,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w500,
            height: 1.33,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search Help',
        hintStyle: const TextStyle(
          color: Color(0xFF182128),
          fontSize: 16,
          fontFamily: 'Encode Sans',
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
    );
  }

  Widget _buildFaqList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FAQ',
          style: TextStyle(
            color: Color(0xFF191919),
            fontSize: 16,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: faqItems.length,
          itemBuilder: (context, index) {
            final item = faqItems[index];
            return FaqExpansionTile(item: item);
          },
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEDEDED)),
        ),
      ],
    );
  }

  Widget _buildBottomHelpSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Still Stuck? Help is a Mail away.',
            style: TextStyle(
              color: Color(0xFF191919),
              fontSize: 16,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCF656),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _sendEmail(context),
            child: const Text(
              'Send a Message',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaqExpansionTile extends StatefulWidget {
  final FaqItem item;

  const FaqExpansionTile({super.key, required this.item});

  @override
  State<FaqExpansionTile> createState() => _FaqExpansionTileState();
}

class _FaqExpansionTileState extends State<FaqExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      // Use the onExpansionChanged callback to update the state
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      // Use the custom trailing icon based on the state
      trailing: Text(
        _isExpanded ? '-' : '+',
        style: TextStyle(
          color: const Color(0xFF191919),
          fontSize: 24,
          fontWeight: _isExpanded ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      title: Text(
        widget.item.question,
        style: const TextStyle(
          color: Color(0xFF191919),
          fontSize: 14,
          fontFamily: 'Encode Sans',
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, right: 30), // Added right padding to align text
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF9A9A9A),
                fontSize: 12,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
              children: [
                TextSpan(text: widget.item.answer),
                if (widget.item.policyText != null)
                  TextSpan(
                    text: widget.item.policyText!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO: Handle policy navigation
                        print("Navigate to Policy page");
                      },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
