import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/assets/assets_data.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/common/dialog/dialog_widget.dart';
import 'package:my_deficiencies/common/dialog/progress_dialog.dart';
import 'package:my_deficiencies/model/user_model.dart';
import 'package:my_deficiencies/ui/home/home_screen.dart';
import 'package:my_deficiencies/ui/sign_up/sign_up_screen.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isShowPassword = false;

  ProgressDialog progressDialog = ProgressDialog();

  String previousRoute = '';

  @override
  void initState() {
    previousRoute = Get.previousRoute;
    if (kDebugMode) {
      print('previousRoute $previousRoute');
    }
    super.initState();
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (validateEmail(_emailController.text) != null) {
          Fluttertoast.showToast(msg: "Please Enter Valid Email Address");
          return;
        }
        if (validatePassword(_passwordController.text) != null) {
          Fluttertoast.showToast(msg: "Please Enter Valid Password");
          return;
        }
        progressDialog.show();
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Fluttertoast.showToast(msg: "Login Successful");
        progressDialog.close();

        String uid = userCredential.user!.uid; // 👈 UID here
        String email = userCredential.user!.email ?? "";
        final userData = await UserModel.getById(uid);
        print('userData ---- $userData');

        SharedPreferences preferences = await SharedPreferences.getInstance();

        final Map<String, dynamic> userMap = {
          "uid": uid,
          "email": email,
          "token": userData?.remainingToken ?? 0,
          "subscriptionPlan": userData?.subscriptionPlan ?? 0,
          "isReferenceUser": userData?.isReferenceUser ?? false,
          "referenceId": userData?.referenceId ?? '',
          "isSubscribe": userData?.isSubscribe ?? false,
        };

        // convert to JSON
        final String userJson = jsonEncode(userMap);

        // save into SharedPreferences as one string
        await preferences.setString("userData", userJson);

        Get.dialog(
          name: '/DialogWidgetSuccessfully',
          DialogWidget(
            onTap: () {
              if (previousRoute != '/PremiumScreen' &&
                  previousRoute != '/SettingScreen') {
                Get.offAll(HomeScreen());
              } else {
                Get.back();
              }
            },
            imageUrl: ImageData.icSuccess,
            title: 'Successfully\nLogin',
            description:
                'Congratulations, your account registration successfully',
            btnText: 'Continue',
          ),
        );
        // Navigate to Home or Dashboard
      } on FirebaseAuthException catch (e) {
        progressDialog.close();
        if (kDebugMode) {
          print('code:- ${e.code} message:- ${e.message}');
        }
        String message;
        switch (e.code) {
          case 'invalid-email':
            message = 'Invalid email address.';
            break;
          case 'user-not-found':
            message = 'No user found for this email.';
            break;
          case 'wrong-password':
            message = 'Incorrect password.';
            break;
          case 'user-disabled':
            message = 'This user account has been disabled.';
            break;
          case 'too-many-requests':
            message = 'Too many attempts. Try again later.';
            break;
          case 'network-request-failed':
            message = 'Network error. Check your internet connection.';
            break;
          case 'invalid-credential':
            message = 'Please Enter valid credential';
            break;
          default:
            message = 'Login failed. ${e.message}';
        }
        loginFail(message);
      }
    }
  }

  Future<void> signInWithApple() async {
    try {
      progressDialog.show();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);

      // Optional: Update display name
      if (appleCredential.givenName != null) {
        await userCredential.user?.updateDisplayName(
          '${appleCredential.givenName} ${appleCredential.familyName ?? ""}',
        );
      }
      progressDialog.close();
      Fluttertoast.showToast(msg: 'Signed in with Apple');
      Get.dialog(
        name: '/DialogWidgetSuccessfully',
        DialogWidget(
          onTap: () {
            if (previousRoute != '/PremiumScreen' &&
                previousRoute != '/SettingScreen') {
              Get.offAll(HomeScreen());
            } else {
              Get.back();
            }
          },
          imageUrl: ImageData.icSuccess,
          title: 'Successfully\nLogin',
          description:
              'Congratulations, your account registration successfully',
          btnText: 'Continue',
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException: - $e');
      }

      progressDialog.close();
      if (kDebugMode) {
        print('code:- ${e.code} message:- ${e.message}');
      }
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-not-found':
          message = 'No user found for this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;
        case 'invalid-credential':
          message = 'Please Enter valid credential';
          break;
        default:
          message = 'Login failed. ${e.message}';
      }
      loginFail(message);
    } catch (e) {
      progressDialog.close();
      Fluttertoast.showToast(
        msg: kDebugMode ? 'Apple Sign-In Failed: $e' : 'Login Fail try again',
      );
    }
  }

  loginFail(String message) {
    Get.dialog(
      name: '/DialogWidgetFail',
      DialogWidget(
        onTap: () {},
        imageUrl: ImageData.icFail,
        title: 'Login Fail',
        description: message,
        // description: 'Your entered data is wrong or you cn',
        btnText: 'Re Enter',
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value == null) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: AppBar(backgroundColor: AppColor.bgColor, toolbarHeight: 0),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: appText(
                title: 'Hello Again!',
                color: AppColor.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            11.toDouble().hs,
            appText(
              title: 'Welcome Back Yo’ve been\nmissed',
              color: AppColor.white,
              fontSize: 14,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
            ),
            25.toDouble().hs,
            appTextField(
              controller: _emailController,
              textInputType: TextInputType.emailAddress,
              // errorText: validateEmail(_emailController.text),
              margin: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Enter Your mail id',
              obscureText: false,
              prefixIcon: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(left: 5),
                child: ImageWidget(
                  imageUrl: SvgAssetsData.icEmail,
                  // width: 38,
                  // height: 41,
                ),
              ),
            ),
            25.toDouble().hs,
            appTextField(
              margin: EdgeInsets.symmetric(horizontal: 24),
              hintText: '******',
              textInputType: TextInputType.visiblePassword,
              // errorText: validatePassword(_passwordController.text),
              controller: _passwordController,
              obscureText: isShowPassword,
              prefixIcon: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(left: 5),
                child: ImageWidget(
                  imageUrl: SvgAssetsData.icLock,
                  // width: 18,
                  // height: 21,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isShowPassword = !isShowPassword;
                  });
                },
                icon: Container(
                  padding: EdgeInsets.all(10),
                  child: ImageWidget(
                    imageUrl:
                        !isShowPassword
                            ? SvgAssetsData.icEye
                            : SvgAssetsData.icEyeClose,
                    // width: 18,
                    // height: 21,
                  ),
                ),
              ),
            ),
            25.toDouble().hs,
            GestureDetector(
              onTap: () {
                login();
              },
              child: Container(
                height: 60,
                width: Get.width,
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColor.btnColor,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppColor.white),
                ),
                alignment: Alignment.center,
                child: appText(
                  title: 'Login',
                  color: AppColor.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            25.toDouble().hs,
            GestureDetector(
              onTap: () {
                signInWithApple();
              },
              child: Container(
                height: 58,
                width: Get.width,
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.white.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 20,
                      child: ImageWidget(imageUrl: SvgAssetsData.icApple),
                    ),
                    Center(
                      child: appText(
                        title: 'Sign With Apple',
                        color: AppColor.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            25.toDouble().hs,
            appText(
              title: 'Or',
              color: AppColor.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            20.toDouble().hs,
            GestureDetector(
              onTap: () {
                Get.to(SignUpScreen(previousRoute: previousRoute));
              },
              child: Wrap(
                children: [
                  appText(
                    title: "Don't Have Account?",
                    color: AppColor.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  appText(
                    title: " Sign Up",
                    color: AppColor.appColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            Visibility(
              visible:
                  (previousRoute != '/PremiumScreen' &&
                      previousRoute != '/SettingScreen'),
              child: GestureDetector(
                onTap: () {
                  Get.offAll(HomeScreen());
                },
                child: Container(
                  padding: EdgeInsets.only(top: 5),
                  child: appText(
                    title: "Continue as Guest User",
                    color: AppColor.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
