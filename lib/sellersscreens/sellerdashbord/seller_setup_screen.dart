import 'package:flutter/material.dart';
import 'package:zatch/sellersscreens/addproduct/add_product_screen.dart'; // Make sure this import is correct

/// This is the new, dedicated screen for the seller setup process.
class SellerSetupScreen extends StatelessWidget {
  const SellerSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // These lists would typically come from your app's state or a backend service.
    // For this example, we show a state where the user has completed some tasks.
    const allTasks = [
      'Upload first product',
      'Add product images (min 3)',
      'Set auto-accept bargain %',
      'Upload first reel',
      'Verify bank details',
      'Accept seller terms',
    ];
    const completedTasks = [
      'Upload first product',
      'Add product images (min 3)'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCF656),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDFDEDE)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            ),
          ),
        ),
        title: const Text(
          'Complete Your Setup', // Screen title
          style: TextStyle(
            color: Color(0xFF121111),
            fontSize: 16,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
        child: Column(
          children: [
            // The main content of this screen is the reusable SetupProgressCard.
            // It shows the user's current progress in detail.
            _SellerSetupDetailCard(
              allTasks: allTasks,
              completedTasks: completedTasks,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// This is the private, detailed version of the setup card for this screen.
class _SellerSetupDetailCard extends StatelessWidget {
  final List<String> allTasks;
  final List<String> completedTasks;

  const _SellerSetupDetailCard({
    required this.allTasks,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = allTasks.isNotEmpty ? completedTasks.length / allTasks.length : 0;
    String nextTask = allTasks.firstWhere(
          (task) => !completedTasks.contains(task),
      orElse: () => 'All Tasks Completed!',
    );

    return Card(
      elevation: 2,
      shadowColor: const Color(0x19000000),
      color: const Color(0xFFF8FAFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.75)),
      child: Padding(
        padding: const EdgeInsets.all(17.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Your Seller Setup',
              style: TextStyle(
                color: Color(0xFF101727),
                fontSize: 15.31,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0x19030112),
                      color: const Color(0xFFA2DC00),
                      minHeight: 7,
                    ),
                  ),
                ),
                const SizedBox(width: 10.5),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF495565),
                    fontSize: 12.30,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.5),
            const Text(
              'More complete profiles sell 3x faster',
              style: TextStyle(
                color: Color(0xFF697282),
                fontSize: 9.68,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 21),
            // Show the full checklist on this screen
            ...allTasks.map((task) {
              final bool isCompleted = completedTasks.contains(task);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.5),
                child: Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCompleted ? const Color(0xFFA2DC00) : const Color(0xFFE5E7EB),
                      size: 21,
                    ),
                    const SizedBox(width: 10.5),
                    Row(
                      children: [
                        Text(
                          task,
                          style: TextStyle(
                            color: const Color(0xFF101727),
                            fontSize: 11.34,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(color: Color(0xFFFA2B36), fontSize: 12.30),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 10.5),
            // Button to perform the next action
            ElevatedButton(
              onPressed: () {
                // If on the setup screen, perform the action for the next task.
                if (nextTask == 'Upload first product') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddProductScreen()),
                  );
                } else {
                  // TODO: Handle navigation for other tasks
                  print('Navigate to screen for: $nextTask');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA2DC00),
                minimumSize: const Size(double.infinity, 40.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.75)),
                elevation: 1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nextTask,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF101727),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF101727))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
