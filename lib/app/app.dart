import 'package:flutter/material.dart';

import '../core/theme/app_dark_theme.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/controllers/theme_controller.dart';
import 'router/app_router.dart';

class ResumeBuilderApp extends StatefulWidget {
  const ResumeBuilderApp({super.key});

  @override
  State<ResumeBuilderApp> createState() => _ResumeBuilderAppState();
}

class _ResumeBuilderAppState extends State<ResumeBuilderApp> {
  final ThemeController _themeController = ThemeController.instance;
  late final _router = createAppRouter();

  @override
  void initState() {
    super.initState();
    _themeController.addListener(_handleThemeChanged);
  }

  @override
  void dispose() {
    _themeController.removeListener(_handleThemeChanged);
    super.dispose();
  }

  void _handleThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Resume AI',
      theme: AppTheme.light,
      darkTheme: AppDarkTheme.dark,
      // Light is the product default; System is applied only when selected.
      themeMode: _themeController.themeMode,
      routerConfig: _router,
    );
  }
}
