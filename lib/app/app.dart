import 'package:flutter/material.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
//
// import '../core/localization/app_localizations.dart';
import '../core/theme/app_dark_theme.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class ResumeBuilderApp extends StatelessWidget {
  const ResumeBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'Resume AI',

      // locale: const Locale('ar'),
      theme: AppTheme.light,
      darkTheme: AppDarkTheme.dark,
      themeMode: ThemeMode.system,

      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      //
      // supportedLocales: const [
      //   Locale('ar'),
      //   Locale('en'),
      // ],
      routerConfig: createAppRouter(),
    );
  }
}
