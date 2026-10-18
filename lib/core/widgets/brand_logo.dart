import 'package:flutter/material.dart';
import 'package:jaycom_contacts/core/constants/app_constants.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 64, this.borderRadius = 18});

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        AppConstants.logoAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'شعار جايكم',
      ),
    );
  }
}
