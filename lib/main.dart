import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/firebase/remote_config.dart';
import 'package:my_deficiencies/firebase_options.dart';
import 'package:my_deficiencies/purchase/purchase_controller.dart';
import 'package:my_deficiencies/ui/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    await Firebase.initializeApp();
  }

  await Get.put(RemoteConfig()).init();
  Get.put(PurchaseController()).fetchSkuDetail();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
        ),
        primaryColor: Colors.blue,
        useMaterial3: true,
      ),

      themeMode: ThemeMode.system,

      // 👇 This is the fix: it overrides system font scaling
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaleFactor: 1.0), // Lock font scaling
          child: child ?? const SizedBox(),
        );
      },

      home: SplashScreen(),
    );
  }
}
