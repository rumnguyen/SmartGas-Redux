import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class AppLogoHeading extends StatelessWidget {
  String welcome;
  bool shouldTextAllCaps;
  double logoHeight;
  double logoWidth;

  AppLogoHeading({
    Key? key,
    this.logoHeight = 75,
    this.logoWidth = 200,
    this.welcome = "",
    this.shouldTextAllCaps = true,
  }) : super(key: key);

  void _updateVariableByLocale() {
    String? locale = Intl.defaultLocale;
    if (locale == null || locale.isEmpty) {
      locale = Intl.systemLocale.split("_")[0];
    } else {
      locale = Intl.defaultLocale!.split("_")[0];
    }

    if (checkStringNullOrEmpty(welcome)) {
      if (locale.compareTo("en") == 0) {
        welcome = "Login";
      } else {
        welcome = "Đăng nhập";
      }
    }

    // initDefaultLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    _updateVariableByLocale();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ImageCacheManager.getImage(
            url: GlobalManager.images.logoHeading,
            height: logoHeight,
            width: logoWidth,
            filterQuality: FilterQuality.high
        ),
        const SizedBox(height: 24),
        // Text(
        //   shouldTextAllCaps ? welcome : welcome,
        //   textScaleFactor: 1.0,
        //   maxLines: 1,
        //   style: const TextStyle(
        //     color: Color(0xFF44494D),
        //     fontWeight: FontWeight.w600,
        //     fontSize: 28,
        //   ),
        // ),
      ],
    );
  }
}
