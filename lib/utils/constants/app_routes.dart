import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:writer/controllers/note_controller.dart';
import 'package:writer/controllers/writer_controller.dart';
import 'package:writer/views/auth_screen.dart';
import 'package:writer/views/code_output_view.dart';
import 'package:writer/views/home_screen.dart';
import 'package:writer/views/settings_screen.dart';
import 'package:writer/views/writer_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static final routes = [
    GetPage(
      name: '/',
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NoteController>()) {
          Get.put(NoteController());
        }
      }),
      transition: Transition.leftToRight,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: '/auth',
      page: () => const AuthScreen(),
      transition: Transition.fadeIn,
      curve: Curves.easeIn,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: '/writer',
      page: () => const WriterScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NoteController>()) {
          Get.put(NoteController());
        }
        if (!Get.isRegistered<WriterController>()) {
          Get.put(WriterController());
        }
      }),
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
