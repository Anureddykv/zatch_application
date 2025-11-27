import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> contentWidgets;
  final Widget? bottomText;

  const BaseScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.contentWidgets,
    this.bottomText,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = constraints.maxWidth;
        final sh = constraints.maxHeight;

        return Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Container(
              width: double.infinity,
              height: sh,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(sh * 0.045),
                ),
              ),
              child: Stack(
                children: [
                  // ---- Static background (does not scroll) ----
                  Positioned.fill(
                    child: Stack(
                      children: [
                        Positioned(
                          left: -sw * 0.7,
                          top: sh * 0.67,
                          child: Transform.rotate(
                            angle: 0.47,
                            child: Container(
                              width: sw * 0.95,
                              height: sw * 0.95,
                              decoration: BoxDecoration(
                                border: Border.all(width: 2, color: const Color(0xFFF1F4FF)),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -sw * 0.7,
                          top: sh * 0.66,
                          child: Container(
                            width: sw * 0.95,
                            height: sw * 0.95,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: const Color(0xFFF1F4FF)),
                            ),
                          ),
                        ),
                        Positioned(
                          left: sw * 0.1,
                          top: -sw * 0.7,
                          child: Container(
                            width: sw * 1.5,
                            height: sw * 1.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 3, color: const Color(0x99CCF656)),
                            ),
                          ),
                        ),
                        Positioned(
                          left: sw * 0.4,
                          top: -sw * 0.45,
                          child: Container(
                            width: sw * 1.0,
                            height: sw * 1.0,
                            decoration: BoxDecoration(
                              color: const Color(0x4CCCF656),
                              shape: BoxShape.circle,
                              border: Border.all(width: 1, color: const Color(0x99CCF656)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- Scrollable foreground content ----
                  SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: sh * 0.15,
                      left: sw * 0.08,
                      right: sw * 0.08,
                      bottom: sh * 0.2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 70,
                            width: 70,
                          ),
                        ),
                        // Title & Subtitle
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: sw * 0.06,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF494949),
                            fontSize: sw * 0.035,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Your page-specific widgets
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: contentWidgets,
                        ),
                      ],
                    ),
                  ),

                  // ---- Bottom text fixed at bottom (does NOT lift above keyboard) ----
                  if (bottomText != null)
                    Positioned(
                      left: sw * 0.08,
                      right: sw * 0.08,
                      bottom: 16, // stays fixed; may be covered by keyboard if it opens
                      child: bottomText!,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
