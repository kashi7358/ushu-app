import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final TextStyle _baseTextStyle = GoogleFonts.poppins(
    color: AppColors.darkText,
  );

  static TextStyle extraBold = _baseTextStyle.copyWith(
    fontWeight: FontWeight.w800,
    fontSize: 28,
  );

  static TextStyle bold = _baseTextStyle.copyWith(
    fontWeight: FontWeight.w700,
    fontSize: 24,
  );

  static TextStyle semiBold = _baseTextStyle.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static TextStyle medium = _baseTextStyle.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static TextStyle regular = _baseTextStyle.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );
}
