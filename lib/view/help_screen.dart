import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int expandedIndex = -1;
  String query = "";

  final List<Map<String, String>> faqs = [
    {"question": "What is Zatch?", "answer": "Zatch is your ultimate shopping companion."},
    {
      "question": "How does Zatch work?",
      "answer":
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque dictum augue arcu, hendrerit lobortis neque malesuada sit amet. "
          "Quisque scelerisque ut massa in convallis. Vivamus ut gravida elit. In pulvinar, mauris non commodo ultricies, est orci gravida leo, "
          "id mattis eros odio at ante. Nunc varius cursus mauris congue sagittis."
    },
    {"question": "Lorimipsum Lori asdjn jsadn?", "answer": "Sample answer text goes here..."},
    {"question": "Lorimipsum Lori ?asjdbcsdnc?", "answer": "Sample answer text goes here..."},
    {"question": "Lorimipsum Lori example?", "answer": "Sample answer text goes here..."},
  ];

  @override
  Widget build(BuildContext context) {
    // filter FAQs by query
    final filteredFaqs = faqs
        .where((faq) => faq["question"]!
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Help",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "We are here to help you with anything and Everything on Zatch",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque dictum augue arcu, hendrerit lobortis neque malesuada sit amet.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                  expandedIndex = -1;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Help",
                prefixIcon:
                const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("FAQ",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),

          // FAQ List
          Expanded(
            child: ListView.builder(
              itemCount: filteredFaqs.length,
              itemBuilder: (context, index) {
                final item = filteredFaqs[index];
                final isExpanded =
                    expandedIndex == index;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(item["question"]!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500)),
                      trailing:
                      Icon(isExpanded ? Icons.remove : Icons.add),
                      onTap: () {
                        setState(() {
                          expandedIndex =
                          isExpanded ? -1 : index;
                        });
                      },
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Text(item["answer"]!,
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 14)),
                      ),
                    Divider(height: 1, color: Colors.grey.shade300),
                  ],
                );
              },
            ),
          ),

          //Bottom message section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border:
              Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                const Text(
                  "Still Stuck? Help is a Mail away.",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3DD00),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Send a Message",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
