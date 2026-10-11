import 'package:business_os/app/di/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import 'app/app.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemeController.instance.load();
  await setupDependencies();

  runApp(const ResumeBuilderApp());
}
