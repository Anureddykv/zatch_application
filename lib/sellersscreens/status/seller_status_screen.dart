
// Enum to define the possible registration states
import 'package:flutter/material.dart';
import 'package:zatch_app/sellersscreens/SellHomeScreen.dart';
import 'package:zatch_app/sellersscreens/addproduct/add_product_screen.dart';
import 'package:zatch_app/sellersscreens/sellerdashbord/SellerDashboardScreen.dart';
import 'package:zatch_app/sellersscreens/registration/seller_registration_screen.dart';

enum RegistrationStatus {
  resumeOnboarding,
  approved,
  unsuccessful,
  submitted,}

class SellerStatusScreen extends StatelessWidget {
  final RegistrationStatus status;
  final int? resumeStep;

  const SellerStatusScreen({
    super.key,
    required this.status,
    this.resumeStep,
  });


  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    void handleResumeBackNavigation() {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SellHomeScreen()),
            (route) => false,
      );
    }

    final VoidCallback backAction = status == RegistrationStatus.resumeOnboarding
        ? handleResumeBackNavigation // Use custom logic for resume
        : () => Navigator.of(context).pop(); // Use default pop for all others

    return WillPopScope(
      onWillPop: () async {
        backAction();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFA2DC00),
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), // Changed to standard back icon
                        onPressed:backAction,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Main Content Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  // The main layout is now a Column to separate content and buttons
                  child: Column(
                    children: [
                      // This makes the top content scrollable if it overflows
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 35),
                                // Title
                                Text(
                                  content['title']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF121111),
                                    fontSize: 24,
                                    fontFamily: 'Encode Sans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Subtitle
                                Text(
                                  content['subtitle']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF121111),
                                    fontSize: 14,
                                    fontFamily: 'Encode Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Main content card
                                _InfoCard(
                                  cardColor: content['cardColor'],
                                  borderColor: content['borderColor'],
                                  icon: content['icon'],
                                  mainText: content['mainText']!,
                                  description: content['description']!,
                                  actionButton: content['actionButton'],
                                  // Pass stepper widget only for the resume onboarding status
                                  stepper: status == RegistrationStatus.resumeOnboarding
                                      ? const _OnboardingStepper()
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // This is the buttons section, which will be at the bottom
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Column(
                          children: _buildBottomButtons(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to get dynamic content based on status
  Map<String, dynamic> _buildContent(BuildContext context) {
    switch (status) {
      case RegistrationStatus.resumeOnboarding:
        return {
          'title': 'Resume Onboarding',
          'subtitle': 'Complete your profile & start selling',
          'cardColor': const Color(0xFFFFFBED),
          'borderColor': const Color(0xFFFFD6A7),
          'icon': Icons.edit_document, // Placeholder icon
          'mainText': '“Let’s finish setting up your store',
          'description': 'just a few more steps to go!',
          'actionButton': null,
        };
      case RegistrationStatus.approved:
        return {
          'title': 'Registration Approved',
          'subtitle': 'Start your seller journey today.',
          'cardColor': const Color(0xFFF6FFED),
          'borderColor': const Color(0xFFA2DC00),
          'icon': Icons.check_circle, // Placeholder icon
          'mainText': 'You’re Approved!',
          'description':
          'We’re excited to have you on board. Begin your journey as a seller and unlock new opportunities.',
          'actionButton': null,
        };
      case RegistrationStatus.unsuccessful:
        return {
          'title': 'We\'re Reviewing Your Details',
          'subtitle': 'Thanks for submitting your information',
          'cardColor': const Color(0xFFFFEDED),
          'borderColor': const Color(0xFFFFD6A7),
          'icon': Icons.error, // Placeholder icon
          'mainText': 'Registration Unsuccessful',
          'description': 'Your GSTIN could not be verified.',
          'actionButton': ElevatedButton(
            onPressed: () {
              // TODO: Handle Update Details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
              const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
            ),
            child: const Text(
              'Update Details',
              style: TextStyle(
                  fontFamily: 'Encode Sans', fontWeight: FontWeight.w700),
            ),
          ),
        };
      case RegistrationStatus.submitted:
      default:
        return {
          'title': 'We\'re Reviewing Your Details',
          'subtitle': 'Thanks for submitting your information.',
          'cardColor': const Color(0xFFFFF2EC),
          'borderColor': const Color(0xFFFFD6A7),
          'icon': Icons.hourglass_top, // Placeholder icon
          'mainText': 'Under Review',
          'description':
          'KYC and bank verification typically take 1–2 business days.',
          'actionButton': null,
        };
    }
  }

  // Helper to build the bottom action buttons
  List<Widget> _buildBottomButtons(BuildContext context) {
    String mainButtonText;
    VoidCallback mainButtonAction;
    String? secondaryButtonText;
    VoidCallback? secondaryButtonAction;
    String? footerText;

    void navigateToAddProduct() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddProductScreen()),
      );
    }

    void navigateToDashboard() {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SellerDashboardScreen()),
            (route) => false,
      );
    }

    switch (status) {
      case RegistrationStatus.resumeOnboarding:
        mainButtonText = 'Resume Application';
        mainButtonAction = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerRegistrationScreen(
                // Pass the step number back to the registration screen
                initialStep: resumeStep ?? 0,
              ),
            ),
          );
        };
        secondaryButtonText = null;
        secondaryButtonAction = null;
        footerText = null;
        break;
      case RegistrationStatus.approved:
        mainButtonText = 'Add Products';
        mainButtonAction = navigateToAddProduct;
        secondaryButtonText = 'Start Selling';
        secondaryButtonAction = navigateToDashboard;
        footerText = null;
        break;
      case RegistrationStatus.unsuccessful:
        mainButtonText = 'Add Products';
        mainButtonAction = navigateToAddProduct;
        secondaryButtonText = 'Start Selling';
        secondaryButtonAction = navigateToDashboard;
        footerText = '*Payments will be on hold until verification is complete';
        break;
      case RegistrationStatus.submitted:
      mainButtonText = 'Add Products';
      mainButtonAction = navigateToAddProduct;
      secondaryButtonText = 'Start Selling';
      secondaryButtonAction = navigateToDashboard;
        footerText = '*Payments will be on hold until verification is complete';
    }

    return [
      if (status == RegistrationStatus.submitted ||
          status == RegistrationStatus.unsuccessful)
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'What you can do now:',
            style: TextStyle(
              color: Color(0xFF121111),
              fontSize: 16,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      if (status == RegistrationStatus.approved)
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Next Steps',
            style: TextStyle(
              color: Color(0xFF121111),
              fontSize: 16,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

      // Add a SizedBox only if there is a heading above the button
      if (status != RegistrationStatus.resumeOnboarding)
        const SizedBox(height: 18),

      // Main Button (Green) for 'approved' and 'resume' states
      if (status == RegistrationStatus.approved ||
          status == RegistrationStatus.resumeOnboarding)
        ElevatedButton(
          onPressed: mainButtonAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCCF656),
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 55),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            mainButtonText,
            style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w700),
          ),
        ),

      // Secondary Button (White with Border)
      if (secondaryButtonText != null) ...[
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: secondaryButtonAction,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 55),
            side: const BorderSide(color: Colors.black, width: 1),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            secondaryButtonText,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],

      // Main Button (Green) for 'submitted' and 'unsuccessful' states
      if (status == RegistrationStatus.submitted ||
          status == RegistrationStatus.unsuccessful) ...[
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: mainButtonAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCCF656),
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 55),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            mainButtonText,
            style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Encode Sans',
                fontWeight: FontWeight.w700),
          ),
        ),
      ],

      const SizedBox(height: 10), // Reduced bottom spacing a bit
      if (footerText != null)
        Text(
          footerText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF121111),
            fontSize: 12,
            fontFamily: 'Encode Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
    ];
  }
}

// Reusable widget for the main info card
class _InfoCard extends StatelessWidget {
  final Color cardColor;
  final Color borderColor;
  final IconData icon;
  final String mainText;
  final String description;
  final Widget? actionButton;
  final Widget? stepper;

  const _InfoCard({
    required this.cardColor,
    required this.borderColor,
    required this.icon,
    required this.mainText,
    required this.description,
    this.actionButton,
    this.stepper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: ShapeDecoration(
        color: cardColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2, color: borderColor),
          borderRadius: BorderRadius.circular(17),
        ),
      ),
      child: Column(
        children: [
          // Icon Container
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2))
              ],
            ),
            child: Icon(icon, size: 48, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          // Main Text
          Text(
            mainText,
            style: const TextStyle(
              color: Color(0xFF121111),
              fontSize: 20,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // Description Text
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF121111),
              fontSize: 14,
              fontFamily: 'Encode Sans',
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          if (stepper != null) ...[
            const SizedBox(height: 30),
            stepper!,
          ],
          if (actionButton != null) ...[
            const SizedBox(height: 24),
            actionButton!,
          ],
        ],
      ),
    );
  }
}

// Specific stepper widget for the 'Resume Onboarding' state
class _OnboardingStepper extends StatelessWidget {
  const _OnboardingStepper();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              _buildStepCircle(isComplete: true),
              Expanded(
                  child: _buildStepLine(
                      isComplete: true, isHalf: true, left: true)),
              Expanded(
                  child: _buildStepLine(
                      isComplete: true, isHalf: true, right: true)),
              _buildStepCircle(isComplete: true, isSmall: true),
              Expanded(
                  child: _buildStepLine(
                      isComplete: false, isHalf: true, left: true)),
              Expanded(
                  child: _buildStepLine(
                      isComplete: false, isHalf: true, right: true)),
              _buildStepCircle(isComplete: false, isSmall: true),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop & KYC\nInfo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'Bank Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'T&C',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStepCircle(
      {required bool isComplete, bool isSmall = false}) {
    if (isSmall) {
      return Container(
        width: 32,
        height: 32,
        decoration: ShapeDecoration(
          color: isComplete ? const Color(0xFFA2DC00) : const Color(0xFFDDDDDD),
          shape: const OvalBorder(),
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: ShapeDecoration(
              color: isComplete ? const Color(0xFFA2DC00) : const Color(0xFFD9D9D9),
              shape: const OvalBorder(
                side: BorderSide(
                  width: 4,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0xFFFFF6D9),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: const ShapeDecoration(
        color: Color(0xFFA2DC00),
        shape: OvalBorder(),
      ),
    );
  }

  Widget _buildStepLine(
      {required bool isComplete,
        bool isHalf = false,
        bool left = false,
        bool right = false}) {
    return Container(
      height: 2,
      margin: EdgeInsets.only(
          left: left && !isHalf ? 4 : 0, right: right && !isHalf ? 4 : 0),
      color: isComplete ? const Color(0xFFA2DC00) : const Color(0xFFDDDDDD),
    );
  }
}
