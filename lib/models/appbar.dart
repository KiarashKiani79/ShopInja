import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/my_colors.dart';

class AppBarContainer extends StatelessWidget {
  const AppBarContainer({
    super.key,
  });

  static const SystemUiOverlayStyle customStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(200),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.deepSkyBlue,
            AppColors.turquoise,
            Colors.white,
          ],
        ),
      ),
    );
  }
}
