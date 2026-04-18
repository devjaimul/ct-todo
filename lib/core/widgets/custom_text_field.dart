import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';


/// Reusable text form field 

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool isPassword;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final double? borderRadius;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onTap,
    this.isPassword = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.borderRadius,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  void _toggleVisibility() => setState(() => _obscureText = !_obscureText);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      obscureText: widget.isPassword ? _obscureText : false,
      obscuringCharacter: '•',
      readOnly: widget.readOnly,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      autofillHints: widget.autofillHints,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      validator: widget.validator,
      cursorColor: AppColors.primary,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        hintStyle: TextStyle(
          color: AppColors.textFieldHint,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: AppColors.textFieldFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: BoxConstraints(minWidth: 48.w),
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: _toggleVisibility,
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.iconColor,
                    size: 20.sp,
                  ),
                ),
              )
            : widget.suffixIcon,
        border: _buildBorder(AppColors.textFieldBorder),
        enabledBorder: _buildBorder(AppColors.textFieldBorder),
        focusedBorder: _buildBorder(AppColors.textFieldFocusBorder, width: 1.5),
        errorBorder: _buildBorder(AppColors.error),
        focusedErrorBorder: _buildBorder(AppColors.error, width: 1.5),
        errorMaxLines: 3,
        errorStyle: TextStyle(fontSize: 11.sp),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius?.r ?? 12.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
