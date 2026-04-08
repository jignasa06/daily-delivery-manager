import 'package:flutter/material.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';

class HeadlineBodyOneBaseWidget extends StatelessWidget {
  const HeadlineBodyOneBaseWidget(
    this.title, {
    super.key,
    this.titleColor,
    this.titleTextAlign = TextAlign.left,
    this.maxLine,
    this.fontWeight,
    this.textOverflow,
    this.fontSize,
    this.height,
    this.foreground,
    this.fontFamily,
    this.underline = false,
    this.letterSpacing = 1,
    this.wordSpacing,
    this.isLineThrough = false,
    this.latterSpacing,
  });

  final String? title;
  final Color? titleColor;
  final TextAlign? titleTextAlign;
  final int? maxLine;
  final FontWeight? fontWeight;
  final TextOverflow? textOverflow;
  final double? fontSize;
  final double? height;
  final double? latterSpacing;
  final Paint? foreground;
  final String? fontFamily;
  final bool underline;
  final double? letterSpacing;
  final double? wordSpacing;
  final bool? isLineThrough;

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? '',
      style: AppStyles.baseHeadline.copyWith(
          letterSpacing: latterSpacing,
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.w500,
          color: titleColor ?? AppColors.textMain),
      textAlign: titleTextAlign,
      maxLines: maxLine,
      overflow: textOverflow,
      softWrap: true,
    );
  }
}
