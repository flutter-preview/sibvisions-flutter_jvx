import 'package:flutter/material.dart';

import '../../../../../flutter_jvx.dart';
import '../../../../../mixin/services.dart';

class AppNameEditor extends StatelessWidget with ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// TextController for the editing field
  final TextEditingController controller;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppNameEditor({required this.controller, Key? key}) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: FlutterJVx.translate('App Name'),
        hintText: FlutterJVx.translate('Enter new App Name'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
