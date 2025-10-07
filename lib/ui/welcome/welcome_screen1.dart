// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:my_deficiencies/assets/assets_data.dart';
// import 'package:my_deficiencies/color/app_color.dart';
// import 'package:my_deficiencies/common/common.dart';
// import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
// import 'package:my_deficiencies/ui/welcome/welcome_screen2.dart';
// import 'package:my_deficiencies/ui/welcome/welcome_screen3.dart';
// import 'package:my_deficiencies/ui_widget/image_widget.dart';

// class WelcomeScreen1 extends StatefulWidget {
//   const WelcomeScreen1({super.key});

//   @override
//   State<WelcomeScreen1> createState() => _WelcomeScreen1State();
// }

// class _WelcomeScreen1State extends State<WelcomeScreen1> {

//   LightDarkController controller = Get.put(LightDarkController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.bgColor,
//       extendBodyBehindAppBar: false,
//       appBar: AppBar(
//         backgroundColor: AppColor.bgColor,
//         toolbarHeight: 0,
//       ),
//       body: Column(
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           ImageWidget(
//             imageUrl: ImageData.onBoarding1,
//             height: Get.height * 0.53,
//             width: Get.width,
//             alignment: Alignment.topCenter,
//             fit: BoxFit.fitWidth,
//           ),
//           Expanded(
//             child: Container(
//               width: Get.width,
//               color: AppColor.bgColor,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 34, vertical: 10),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               appText(
//                                 title: 'Welcome to\nMyDeficiencies',
//                                 color: AppColor.white,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 24,
//                               ),
//                               10.toDouble().hs,
//                               appText(
//                                 title: 'Decoding physiologic deficiencies created from pharmaceuticals and synthetic supplementation.',
//                                 color: AppColor.bEC0C7,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 16,
//                               ),
//                               10.toDouble().hs,
//                               SizedBox(
//                                 height: 28,
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     ImageWidget(
//                                       imageUrl: SvgAssetsData.onBoardingSelected,
//                                       color: controller.isLight ? Color(0xFF0A0D14) : AppColor.white,
//                                     ),
//                                     5.toDouble().ws,
//                                     ImageWidget(
//                                       imageUrl: SvgAssetsData.onBoardingUnSelected,
//                                       color: controller.isLight ? Color(0xFF0A0D14) : AppColor.white,
//                                     ),
//                                     5.toDouble().ws,
//                                     ImageWidget(
//                                       imageUrl: SvgAssetsData.onBoardingUnSelected,
//                                       color: controller.isLight ? Color(0xFF0A0D14) : AppColor.white,
//                                     ),
//                                     // ImageWidget(imageUrl: SvgAssetsData.onBoardingUnSelected),
//                                     5.toDouble().hs,
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 24),
//                           child: Row(
//                             children: [
//                               /*Expanded(
//                                 child: GestureDetector(
//                                   onTap: () async {
//                                     SharedPreferences preferences = await SharedPreferences.getInstance();
//                                     preferences.setBool('isOnBoard', true);
//                                     Get.offAll(PrivacyScreen());
//                                   },
//                                   child: Container(
//                                     height: 54,
//                                     constraints: BoxConstraints(
//                                       maxWidth: 157
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: AppColor.white.withValues(alpha: 0.1),
//                                       borderRadius: BorderRadius.circular(99),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: AppColor.white.withValues(alpha: 0.02),
//                                           spreadRadius: 0,
//                                           blurRadius: 44,
//                                           offset: Offset(0, 10),
//                                         )
//                                       ]
//                                     ),
//                                     alignment: Alignment.center,
//                                     child: appText(
//                                       title: 'Skip',
//                                       color: AppColor.c959DAE,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               11.toDouble().ws,*/
//                               Expanded(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     Get.to(PremiumHelperScreen());
//                                   },
//                                   child: Container(
//                                     height: 45,
//                                     constraints: BoxConstraints(
//                                       maxWidth: 157
//                                     ),
//                                     alignment: Alignment.center,
//                                     decoration: BoxDecoration(
//                                       color: AppColor.btnColor,
//                                       borderRadius: BorderRadius.circular(99),
//                                       border: Border.all(
//                                         color: AppColor.white
//                                       )
//                                     ),
//                                     child: appText(
//                                       title: 'Next',
//                                       color: AppColor.white,
//                                       fontWeight: FontWeight.w500
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   (Get.mediaQuery.padding.bottom + 20).hs
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/ui/login/login_screen.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isPageChanging = false; // ✅ FIX: Prevent double increment

  final List<String> images = [
    "assets/image/1.png",
    "assets/image/2.png",
    "assets/image/3.png",
    "assets/image/4.png",
    "assets/image/5.png",
  ];

  void _nextPage() async {
    if (_currentIndex < images.length - 1 && !_isPageChanging) {
      setState(() {
        _isPageChanging = true; // ✅ Prevent double calls
      });

      await _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      if (mounted) {
        setState(() {
          _currentIndex++; // ✅ Only increment once
          _isPageChanging = false;
        });
      }
    } else if (_currentIndex == images.length - 1) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool('isOnBoard', true);
      Get.offAll(LoginScreen());
    }
  }

  void _skipToEnd() async {
    if (!_isPageChanging) {
      setState(() {
        _isPageChanging = true;
      });

      await _pageController.animateToPage(
        images.length - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      if (mounted) {
        setState(() {
          _currentIndex = images.length - 1;
          _isPageChanging = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// ✅ Fullscreen PageView
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              // ✅ Only update if NOT triggered by button press
              if (!_isPageChanging) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            itemBuilder: (context, index) {
              if (index == images.length - 1) {
                // ✅ Last slide (Medical Disclaimer)
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    ImageWidget(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.topCenter,
                    ),

                    // Semi-transparent overlay for readability
                    Container(
                      color: Colors.black.withOpacity(0.6),
                    ),

                    // Scrollable Medical Disclaimer content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 100), // ✅ extra space for button
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Medical Disclaimer",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),

                                // 1. Purpose
                                Text(
                                  "1. Purpose of the My Deficiencies App",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "MyDeficiencies is a research-driven educational tool that highlights the nutrient-depletion risks and physiological effects associated with prescription drugs, over-the-counter medications, and synthetic vitamins. It is not medical advice and does not replace consultation with a qualified healthcare professional.",
                                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                ),
                                SizedBox(height: 16),

                                // 2. Data Integrity
                                Text(
                                  "2. Data Integrity & Citation Protocol",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "• Curate peer-reviewed evidence – All claims are drawn from trusted databases PubMed, NCBI, ScienceDirect, and the Cochrane Library.\n"
                                  "• Show our work – Every report contains clickable citations so you can inspect the original study yourself.\n"
                                  "• Refuse to guess – If no high-quality evidence exists for a requested substance, the app tells you directly.",
                                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                ),
                                SizedBox(height: 16),

                                // 3. What You'll See
                                Text(
                                  "3. What You’ll See in Each Report",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "• Risk severity badge: Severe | Moderate | Low | Balanced\n"
                                  "• Documented nutrient depletions (e.g., magnesium loss, B-vitamin demand)\n"
                                  "• Short- and long-term physiological effects (e.g., oxidative stress, Micro-biome)\n"
                                  "• Clickable peer-reviewed references for every claim",
                                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                ),
                                SizedBox(height: 16),

                                // 4. Source Alignment
                                Text(
                                  "4. Source-Alignment Verification",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Our four-step verification workflow ensures alignment:\n\n"
                                  "• Direct Evidence First – Studies that investigate the exact drug, vitamin, or nutrient you entered.\n"
                                  "• Mechanism Evidence Second – Research on biochemical pathways.\n"
                                  "• Adjacent Evidence Third – High-quality reviews or nutrient-focused papers.\n"
                                  "• Transparent Tagging – Each citation is marked as Direct, Mechanistic, or Adjacent.",
                                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                ),
                                SizedBox(height: 16),

                                // 5. Limitations
                                Text(
                                  "5. Limitations & User Responsibilities",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "• Evidence Gaps: Most clinical trials examine a single agent; stacking data are rare.\n"
                                  "• Evolving Science: New findings can change recommendations; check back for updates.\n"
                                  "• Personal Variation: Genetics, diet, and lifestyle alter nutrient needs. Always consult a medical professional.",
                                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                ),
                                SizedBox(height: 16),

                                // 6. Talk to Your Clinician
                                Text(
                                  "6. Talk to Your Clinician",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "MyDeficiencies is designed to inform discussions with your healthcare team. Do not start, stop, or change any medication or supplement regimen without professional guidance.",
                                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                ),
                                SizedBox(height: 16),

                                // 7. Verification
                                Text(
                                  "7. Need additional Verification?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Ask inside the app and it will supply the exact reference you request or tell you if one isn’t yet published.",
                                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                ),
                                SizedBox(height: 16),

                                // Final Disclaimer
                                Text(
                                  "Disclaimer:",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "MyDeficiencies is intended for educational and informational purposes only. It does not provide medical advice, diagnosis, or treatment, and is not a substitute for consultation with a qualified healthcare provider. Do not modify or discontinue any medication or supplement without first consulting a licensed medical professional. While we reference scientific studies, the app does not offer personalised medical recommendations. Use of this app is at your own discretion.",
                                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                                ),
                                SizedBox(height: 20),

                                Text(
                                  "© 2025 MyDeficiencies. All rights reserved.\nPrivacy Policy: https://balancednaturopathics.com/pages/mydeficiencies-privacy-policy",
                                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // ✅ Normal slides (1–4)
                return Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: ImageWidget(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.topCenter,
                  ),
                );
              }
            },
          ),

          /// ✅ Dots Indicator
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          images.length,
                          (index) {
                            bool isActive = _currentIndex == index;
                            return GestureDetector(
                              onTap: () async {
                                if (!_isPageChanging) {
                                  setState(() {
                                    _isPageChanging = true;
                                  });

                                  await _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );

                                  if (mounted) {
                                    setState(() {
                                      _currentIndex = index;
                                      _isPageChanging = false;
                                    });
                                  }
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                width: isActive ? 24.0 : 12.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  // ✅ FIXED: Use proper brand color
                                  color: isActive 
                                    ? const Color(0xFF6366F1) // Modern Blue
                                    : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ✅ FIXED BUTTON - Proper Colors
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // ✅ FIXED: Proper brand color (NOT white!)
                    color: const Color(0xFF6366F1), // Modern Blue
                    // Alternative colors you can use:
                    // color: const Color(0xFF8B5CF6), // Purple
                    // color: const Color(0xFF10B981), // Green
                    // color: const Color(0xFF3B82F6), // Blue
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        // ✅ Match shadow to button color
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _nextPage,
                      splashColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.1),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ WHITE ICON
                            AnimatedOpacity(
                              opacity: _currentIndex == images.length - 1 ? 0 : 1,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white, // ✅ WHITE
                                size: 18,
                              ),
                            ),
                            if (_currentIndex < images.length - 1) const SizedBox(width: 8),
                            
                            // ✅ WHITE TEXT
                            Text(
                              _currentIndex == images.length - 1 ? "Get Started" : "Next",
                              style: const TextStyle(
                                color: Colors.white, // ✅ WHITE
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// ✅ Skip Button
          if (_currentIndex < images.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
              right: 24,
              child: GestureDetector(
                onTap: _skipToEnd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          /// ✅ Page Counter
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                "${_currentIndex + 1}/${images.length}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
