import 'package:flutter/material.dart';
import 'package:hlms_mobile/core/config/app_router.dart';
import 'package:hlms_mobile/core/config/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EduCoreApp());
}

class EduCoreApp extends StatelessWidget {
  const EduCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EduCore Hybrid LMS',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
