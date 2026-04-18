import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

/// Primary action button 
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final double? fontSize;
  final double? radius;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.fontSize,
    this.radius,
    this.height,
    this.padding,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final btnRadius = BorderRadius.circular(radius ?? 12.r);

    return SizedBox(
      width: double.infinity,
      height: height ?? 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient != null
              ? LinearGradient(colors: gradient!)
              : LinearGradient(
                  colors: [
                    color ?? AppColors.primary,
                    color ?? AppColors.primaryLight,
                  ],
                ),
          borderRadius: btnRadius,
          boxShadow: [
            BoxShadow(
              color: (color ?? AppColors.primary).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: MaterialButton(
          onPressed: isLoading ? null : onTap,
          shape: RoundedRectangleBorder(borderRadius: btnRadius),
          padding: padding ?? EdgeInsets.symmetric(vertical: 12.h),
          child: isLoading
              ? SizedBox(
                  height: 22.h,
                  width: 22.h,
                  child: CircularProgressIndicator(
                    color: textColor ?? Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: fontSize ?? 16.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Inline text button 
class StyledTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final double? fontSize;
  final TextDecoration? decoration;

  const StyledTextButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.fontSize,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? AppColors.primary,
          fontSize: fontSize ?? 14.sp,
          fontWeight: FontWeight.w600,
          decoration: decoration,
        ),
      ),
    );
  }
}
