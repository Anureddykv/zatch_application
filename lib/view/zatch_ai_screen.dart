import 'package:flutter/material.dart';

// Main stateful widget for the AI Chat screen
class ZatchAiScreen extends StatefulWidget {
  const ZatchAiScreen({super.key});

  @override
  State<ZatchAiScreen> createState() => _ZatchAiScreenState();
}

class _ZatchAiScreenState extends State<ZatchAiScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isAwaitingResponse = false;

  // Handles sending a message
  void _sendMessage() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(text);
        _isAwaitingResponse = true; // Show loading indicator
        _controller.clear();
      });

      // Simulate an AI response after a delay
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isAwaitingResponse = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9, // Covers 90% of the screen
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // --- Header ---
            const _AiHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Show initial suggestions or the response
                  if (_messages.isEmpty)
                    const _InitialSuggestionsView()
                  else
                    _ChatResponseView(query: _messages.last, isLoading: _isAwaitingResponse),

                  // Add Prompt Library section at the bottom of the scroll view
                  const SizedBox(height: 30),
                  const _PromptLibrary(),
                  const SizedBox(height: 100), // Space for the text field
                ],
              ),
            ),
            // --- Text Input Field ---
            _AiTextInput(controller: _controller, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}

// MARK: - Sub-Widgets

// --- Header Widget ---
class _AiHeader extends StatelessWidget {
  const _AiHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Zatch AI',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Initial View with Suggestions ---
class _InitialSuggestionsView extends StatelessWidget {
  const _InitialSuggestionsView();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggestions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              // Dummy data, replace with real data
              _SuggestionCard(
                imageUrl: 'https://picsum.photos/seed/jacket/200/300',
                title: 'Men\'s Harrington Jacket',
                price: '\$148.00',
              ),
              SizedBox(width: 12),
              _SuggestionCard(
                imageUrl: 'https://picsum.photos/seed/slides/200/300',
                title: 'Max Cirro Men\'s Slides',
                price: '\$50.00',
              ),
              SizedBox(width: 12),
              _SuggestionCard(
                imageUrl: 'https://picsum.photos/seed/shoes/200/300',
                title: 'Running Shoes',
                price: '\$95.00',
              ),
            ],
          ),
        )
      ],
    );
  }
}

// --- Chat Response View (after sending a message) ---
class _ChatResponseView extends StatelessWidget {
  final String query;
  final bool isLoading;
  const _ChatResponseView({required this.query, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // User's message bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const ShapeDecoration(
            color: Color(0xFFCCF656),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          child: Text(
            query,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
        const SizedBox(height: 24),
        // AI's response (or loading state)
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
            childAspectRatio: 0.55,
            children: const [
              // Dummy response data, replace with API data based on the query
              _SuggestionCard(
                  imageUrl: 'https://picsum.photos/seed/dress1/200/300',
                  title: 'Maroon Dark Top',
                  price: '\$194.99'),
              _SuggestionCard(
                  imageUrl: 'https://picsum.photos/seed/dress2/200/300',
                  title: 'Modern Light Clothes',
                  price: '\$212.99'),
            ],
          ),
      ],
    );
  }
}

// --- Prompt Library Section ---
class _PromptLibrary extends StatelessWidget {
  const _PromptLibrary();
  @override
  Widget build(BuildContext context) {
    // List of prompts
    final prompts = [
      'Best Sneakers', 'Low Cost Sneakers', 'Jackets',
      'Mens Jackets', 'Slides', 'Tech Products',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prompt Library',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: prompts.map((prompt) => _PromptChip(label: prompt)).toList(),
        ),
      ],
    );
  }
}

// --- Reusable card for suggestions/products ---
class _SuggestionCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  const _SuggestionCard({required this.imageUrl, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- Chip for the Prompt Library ---
class _PromptChip extends StatelessWidget {
  final String label;
  const _PromptChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ShapeDecoration(
        color: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF272727),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// --- Bottom Text Input Field ---
class _AiTextInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _AiTextInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: onSend,
              child: Container(
                width: 52,
                height: 52,
                decoration: const ShapeDecoration(
                  color: Color(0xFFA2DC00),
                  shape: OvalBorder(),
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
