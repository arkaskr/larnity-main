import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:larnity/src/core/theme/app_colors.dart';

class AppToast {
  static void show(String msg, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.red : AppColors.primaryOrange,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
