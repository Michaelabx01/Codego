
import 'package:code_projectv1/utils/custom_colors.dart';
import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurRadius;
  final double borderRadius;

  const CardContainer(
      {Key? key,
      required this.child,
      this.backgroundColor,
      this.shadowColor,
      this.width,
      this.height,
      this.padding,
      this.margin,
      this.blurRadius = 30,
      this.borderRadius = 20})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 30),
      width: width ?? double.infinity,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: _cardShapeDecoration(),
      child: child,
    );
  }

  BoxDecoration _cardShapeDecoration() => BoxDecoration(
      color: backgroundColor ?? CustomColors.kDarkThemeBlack,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: (blurRadius > 0)
          ? [
              BoxShadow(
                color: shadowColor ?? CustomColors.kDarkThemeBlack,
                blurRadius: blurRadius,
                offset: const Offset(0, 0),
              )
            ]
          : null);
}
