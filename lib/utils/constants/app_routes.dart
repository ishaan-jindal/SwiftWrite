import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:writer/views/code_output_view.dart';
import 'package:writer/views/home_screen.dart';
import 'package:writer/views/mode_selection_screen.dart';
import 'package:writer/views/settings_screen.dart';
import 'package:writer/views/writer_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static final routes = [
    GetPage(
      name: '/',
      page: () => const HomeScreen(),
      transition: Transition.leftToRight,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: '/mode-selection',
      page: () => const ModeSelectionScreen(),
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: '/writer',
      page: () => const WriterScreen(),
      transition: Transition.rightToLeft,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: '/code-output',
      page: () => const CodeOutputView(),
      transition: Transition.downToUp,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
  ];
}
