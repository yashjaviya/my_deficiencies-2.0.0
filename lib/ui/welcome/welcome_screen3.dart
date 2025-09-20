import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/assets/assets_data.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/ui/welcome/welcome_screen2.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';

class PremiumHelperScreen extends StatelessWidget {
  final List<Map<String, dynamic>> premiumPoints = [
    {"icon": "✅", "text": "Confirmed Inputs"},
    {"icon": "🧬", "text": "Combined Depletion Report"},
    {"icon": "📉", "text": "Depletions by Substance"},
    {"icon": "📊", "text": "Cumulative Depletion Summary"},
    {"icon": "🧠", "text": "Functional Physiological Implications"},
    {"icon": "⚡", "text": "Mitochondrial Burden Assessment"},
    {"icon": "💥", "text": "Oxidative Stress Score"},
    {"icon": "⚖️", "text": "Copper–Iron Balance Analysis"},
    {"icon": "🌿", "text": "Gut Microbiome & Dysbiosis Risk"},
    {"icon": "💧", "text": "Oxygen Transport & ATP Output"},
    {"icon": "📰", "text": "Combined Summary Report"},
    {"icon": "🧪", "text": "Drug Interaction Analysis"},
    {"icon": "🧭", "text": "Call To Action"},
    {"icon": "🧬", "text": "Peer-reviewed science and citations"},
  ];

  PremiumHelperScreen({super.key});

  final LightDarkController controller = Get.put(LightDarkController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        toolbarHeight: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header Image (like WelcomeScreen1 top section)
          ImageWidget(
            imageUrl: ImageData.onBoarding1, // 👉 replace with premium image if you have
            height: Get.height * 0.40,
            width: Get.width,
            // alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),

          // Bottom Container
          Expanded(
            child: Container(
              width: Get.width,
              color: AppColor.bgColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          appText(
                            title: "Premium Experience Awaits",
                            color: AppColor.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                          10.toDouble().hs,
                          appText(
                            title: "Unlock advanced features and insights tailored to your deficiencies without ADs.",
                            color: AppColor.bEC0C7,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          20.toDouble().hs,

                          // Premium Points
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: premiumPoints.length,
                              itemBuilder: (context, index) {
                                final item = premiumPoints[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["icon"],
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: appText(
                                          title: "${index + 1}. ${item["text"]}",
                                          color: AppColor.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          20.toDouble().hs,

                          SizedBox(
                            height: 28,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ImageWidget(
                                  imageUrl: SvgAssetsData.onBoardingUnSelected,
                                  color: controller.isLight ? Color(0xFF0A0D14) : AppColor.white,
                                ),
                                5.toDouble().ws,
                                ImageWidget(
                                  imageUrl: SvgAssetsData.onBoardingSelected,
                                  color: controller.isLight ? Color(0xFF0A0D14) : AppColor.white,
                                ),
                                5.toDouble().ws,
                                ImageWidget(
                                  imageUrl: SvgAssetsData.onBoardingUnSelected,
                                  color: controller.isLight ? Color(0xFF0A0D14) : AppColor.white,
                                ),
                                // ImageWidget(imageUrl: SvgAssetsData.onBoardingUnSelected),
                                5.toDouble().hs,
                              ],
                            ),
                          ),

                          // Upgrade Button
                          GestureDetector(
                            onTap: () {
                              // handle premium upgrade
                              Get.to(WelcomeScreen2());
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColor.btnColor,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: AppColor.white),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.white.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: appText(
                                title: "Next",
                                color: AppColor.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Padding
                  (Get.mediaQuery.padding.bottom + 20).hs,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
