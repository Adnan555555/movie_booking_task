import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_booking_app/repository/movies_repository.dart';

import 'controller/movie_controller.dart';
import 'core/app_route.dart';
import 'core/app_theme.dart';

void main() {
  // Initialize GetX dependencies
  Get.put(MoviesRepository());
  Get.put(MoviesController(Get.find<MoviesRepository>()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tentwenty',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.home,
    );
  }
}