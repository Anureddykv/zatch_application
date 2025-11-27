import 'package:flutter/material.dart';

class BaseScreenAlt extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> contentWidgets;
  final Widget? bottomText;

  const BaseScreenAlt({
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
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.black,
            resizeToAvoidBottomInset: false,
            body: Container(
              width: double.infinity,
              height: sh,
              color: Colors.white,
              child: Stack(
                children: [
                  // ---- Circles TOP LEFT ----
                  Positioned(
                    right: sw * 0.45,
                    top: -sw * 0.9,
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
                    right: sw * 0.6,
                    top: -sw * 0.6,
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

                  // ---- Squares BOTTOM LEFT ----
                  Positioned(
                    left: -sw * 0.7,
                    bottom: -sh * 0.2,
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
                    bottom: -sh * 0.25,
                    child: Container(
                      width: sw * 0.95,
                      height: sw * 0.95,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: const Color(0xFFF1F4FF)),
                      ),
                    ),
                  ),

                  // ---- Foreground Content ----
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(left: sw * 0.04, right: sw * 0.04),
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: sw * 0.07 + (bottomText != null ? 60 : 0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title & subtitle
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: sw * 0.06,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF494949),
                                fontSize: sw * 0.035,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Scrollable content
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: contentWidgets,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ---- Bottom Button ----
                  if (bottomText != null)
                    Positioned(
                      left: sw * 0.04,
                      right: sw * 0.04,
                      bottom: sw * 0.04,
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
