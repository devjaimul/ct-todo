import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/routes/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controller/auth_controller.dart';

/// Sign Up screen with name, email, password fields,
/// full validation, AutofillGroup, and loading state.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext(shouldSave: true);

    final success = await _authController.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );
    if (success && mounted) {
      context.goNamed(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                children: [
                  SizedBox(height: 32.h),

                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      AppImages.appLogo,
                      height: 40.h,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  Text(
                    'Create Account',
                    style: GoogleFonts.inter(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Fill in the details to get started',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  CustomTextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    autofillHints: const [AutofillHints.name],
                    hintText: 'Full name',
                    prefixIcon: Icon(
                      Icons.person_outlined,
                      color: AppColors.iconColor,
                      size: 20.sp,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  CustomTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    hintText: 'Email address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.iconColor,
                      size: 20.sp,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!AppConstants.isValidEmail(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  CustomTextField(
                    controller: _passwordController,
                    isPassword: true,
                    autofillHints: const [AutofillHints.newPassword],
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      color: AppColors.iconColor,
                      size: 20.sp,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!AppConstants.isValidPassword(value)) {
                        return 'Must include uppercase, lowercase, number & special character (e.g., Abc123@!)';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 28.h),

                  Obx(
                    () => CustomButton(
                      text: 'Create Account',
                      isLoading: _authController.signUpLoading.value,
                      onTap: _handleSignUp,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      StyledTextButton(
                        text: 'Sign In',
                        onTap: () => context.goNamed(AppRouter.signIn),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
