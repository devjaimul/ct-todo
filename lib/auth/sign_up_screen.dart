import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../Controller/auth/auth_controller.dart';
import '../../global_widgets/app_logo.dart';
import '../../global_widgets/custom_text.dart';
import '../../global_widgets/custom_text_button.dart';
import '../../global_widgets/custom_text_field.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constant.dart';
import '../../utils/app_icons.dart';
import '../profile/setting/app_data.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController userNameTEController = TextEditingController();

  final TextEditingController genderTEController = TextEditingController();

  final TextEditingController emailTEController = TextEditingController();

  final TextEditingController passTEController = TextEditingController();

  final TextEditingController confirmPassTEController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final sizeH = MediaQuery.of(context).size.height;
    final sizeW = MediaQuery.of(context).size.width;
    RxBool rememberMe = false.obs;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppLogo(),
            Padding(
              padding: EdgeInsets.all(sizeH * .02),
              child: Form(
                key: formKey,
                child: Column(
                  spacing: sizeH * .02,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: CustomTextOne(text: "Sign Up")),
                    Center(
                        child: CustomTextTwo(
                            text:
                                "Save and share precious life memories. Sign up for free today")),

                    //userName
                    CustomTextField(
                      controller: userNameTEController,
                      hintText: "Enter a Unique User Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "User Name cannot be empty";
                        }
                        return null;
                      },
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                            left: sizeW * .03, right: sizeW * .01),
                        child: Icon(
                          Icons.person,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    //gender
                    CustomTextField(
                      readOnly: true,
                      controller: genderTEController,
                      hintText: "Select Gender",
                      suffixIcon: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          color: Colors.white,
                        ),
                        onSelected: (String selectedGender) {
                          genderTEController.text = selectedGender;
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: "male",
                            child: Text("Male"),
                          ),
                          const PopupMenuItem<String>(
                            value: "female",
                            child: Text("Female"),
                          ),
                          const PopupMenuItem<String>(
                            value: "other",
                            child: Text("Others"),
                          ),
                        ],
                      ),
                      prefixIcon: Padding(
                        padding:  EdgeInsets.symmetric(horizontal: sizeW*.02),
                        child: Icon(FontAwesomeIcons.venus,size: sizeH*.024,color: Colors.white,),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Gender cannot be empty";
                        }
                        return null;
                      },
                    ),
                    //email
                    CustomTextField(
                      controller: emailTEController,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      hintText: "Enter E-mail",
                      isEmail: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email cannot be empty";
                        }
                        if (!AppConstants.emailValidate.hasMatch(value)) {
                          return "Invalid email address";
                        }
                        return null;
                      },
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                            left: sizeW * .03, right: sizeW * .01),
                        child: Image.asset(
                          AppIcons.email,
                          height: sizeH * .02,
                        ),
                      ),
                    ),
                    //password
                    CustomTextField(
                      controller: passTEController,
                      hintText: "Enter Password",
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password cannot be empty";
                        }
                        if (value.length < 8) {
                          return "Password must be at least 8 characters and include uppercase, lowercase, numbers, and special characters (e.g., Abc123@!)";
                        }
                        return null;
                      },
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                            left: sizeW * .03, right: sizeW * .01),
                        child: Image.asset(
                          AppIcons.password,
                          height: sizeH * .02,
                        ),
                      ),
                    ),
                    //confirm password
                    CustomTextField(
                      controller: confirmPassTEController,
                      hintText: "Re-enter your password",
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm your password";
                        }
                        if (value != passTEController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                            left: sizeW * .03, right: sizeW * .01),
                        child: Image.asset(
                          AppIcons.password,
                          height: sizeH * .02,
                        ),
                      ),
                    ),
                    Obx(() => Row(
                          children: [
                            Checkbox(
                              value: rememberMe.value,
                              checkColor: Colors.white,
                              activeColor: AppColors.secondaryColor,
                              onChanged: (value) {
                                rememberMe.value = value!;
                              },
                            ),
                            const CustomTextTwo(text: "Agree with"),
                            InkWell(
                                onTap: () {
                                  Get.to(() => AppData(type: "terms"));
                                },
                                child: const CustomTextTwo(
                                  text: " Terms of Services",
                                  textDecoration: TextDecoration.underline,
                                )),
                          ],
                        )),

                    // sign up button
                    Obx(() => CustomTextButton(
                          text: "Register",
                          isLoading: controller.signUpLoading.value,
                          onTap: () {
                            if (formKey.currentState?.validate() ?? false) {
                              controller.handleSignUp(
                                emailTEController.text,
                                passTEController.text,
                                userNameTEController.text,
                                genderTEController.text

                              );
                            }
                          },
                        )),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomTextTwo(text: "Already have an account?"),
                        StyleTextButton(
                          text: "Login",
                          textDecoration: TextDecoration.underline,
                          onTap: () {
                            Get.toNamed(AppRoutes.signInScreen);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: sizeH * .01,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userNameTEController.dispose();
    genderTEController.dispose();
    passTEController.dispose();
    emailTEController.dispose();
    confirmPassTEController.dispose();
  }
}
