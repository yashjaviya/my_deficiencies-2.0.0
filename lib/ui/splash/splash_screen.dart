import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/assets/assets_data.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/firebase/realtime_database.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/purchase/purchase_controller.dart';
import 'package:my_deficiencies/services/auth_service.dart';
import 'package:my_deficiencies/ui/home/home_screen.dart';
import 'package:my_deficiencies/ui/login/login_screen.dart';
import 'package:my_deficiencies/ui/welcome/welcome_screen1.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // Get.put(PurchaseController()).onClickStartRestore();
    Get.put(LightDarkController());
    attDialog();
    super.initState();
  }

  Future<void> attDialog() async {
    await AppTrackingTransparency.requestTrackingAuthorization().then((value) async {
      if(value == TrackingStatus.notDetermined) {
        attDialog();
      } else {
        await RealtimeDatabase().init();
        moveNext();
      }
    });
  }

  void moveNext() {
    Future.delayed(
      Duration(seconds: 2),
          () async {
        // _auth.signOut();
        SharedPreferences preferences = await SharedPreferences.getInstance();
        if (kDebugMode) {
          print('SharedPreferences ${preferences.getBool('isOnBoard')}');
        }
        bool isOnBoard = preferences.getBool('isOnBoard') ?? false;
        var user = FirebaseAuth.instance.currentUser;
        bool loggedIn = await AuthUtils.isLoggedIn();

        if (!isOnBoard) {
          // FirebaseAuth.instance.signOut();
          // await AuthUtils.logout();
          Get.offAll(WelcomeScreen1());
          return;
        }

        FirebaseAuth.instance.authStateChanges().listen((User? tmpU) async {
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> this is called ${loggedIn} ');
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> this is called ${tmpU} ');
          user = tmpU;
          if(loggedIn && tmpU != null) {
            Get.offAll(HomeScreen());
          } else {
            Get.offAll(LoginScreen());
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LightDarkController>(
      builder: (lightDarkController) {
        return Scaffold(
          backgroundColor: AppColor.bgColor,
          appBar: AppBar(
            backgroundColor: AppColor.bgColor,
            toolbarHeight: 0,
          ),
          body: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 80),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: ImageWidget(
                  imageUrl: lightDarkController.isLight ? ImageData.logoTransparentLight : ImageData.logoTransparent,
                  height: 175,
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
