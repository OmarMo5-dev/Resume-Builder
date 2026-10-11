import 'dart:async';
import 'package:business_os/app/di/injection_container.dart';
import 'package:business_os/app/router/app_page_transition.dart';
import 'package:business_os/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/resume/domain/entities/resume.dart';
import '../../features/resume/presentation/pages/public_resume_page.dart';
import '../../features/resume/presentation/pages/resume_editor_page.dart';
import '../../features/resume/presentation/pages/resume_preview_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../root.dart';

GoRouter createAppRouter() {
  final authRefreshNotifier = AuthRefreshNotifier();

  return GoRouter(
    initialLocation: '/auth/login',
    refreshListenable: authRefreshNotifier,

    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;

      debugPrint('ROUTER REDIRECT: ${state.matchedLocation}');
      debugPrint('ROUTER FIREBASE USER: ${user?.uid}');

      final isAuthRoute =
      state.matchedLocation.startsWith('/auth/');

      if (user == null) {
        return isAuthRoute ? null : '/auth/login';
      }

      if (isAuthRoute) {
        return '/resumes';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/auth/login',
        pageBuilder: (context, state) =>
            AppPageTransition.slide(
              child: BlocProvider(
                create: (_) => getIt<AuthCubit>(),
                child: const LoginPage(),
              ),
            ),
      ),

      GoRoute(
        path: '/auth/register',
        pageBuilder: (context, state) =>
            AppPageTransition.slide(
              child: BlocProvider(
                create: (_) => getIt<AuthCubit>(),
                child: const RegisterPage(),
              ),
            ),
      ),

      GoRoute(
        path: '/auth/forgot-password',
        pageBuilder: (context, state) =>
            AppPageTransition.slide(
              child: BlocProvider(
                create: (_) => getIt<AuthCubit>(),
                child: const ForgotPasswordPage(),
              ),
            ),
      ),

      GoRoute(
        path: '/resumes',
        pageBuilder: (context, state) =>
            AppPageTransition.slide(
              child: const Root(initialIndex: 0),
            ),
      ),

      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            AppPageTransition.slide(
              child: const Root(initialIndex: 1),
            ),
      ),

      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => AppPageTransition.slide(
          child: const SettingsPage(),
        ),
      ),

      GoRoute(
        path: '/resumes/editor',
        redirect: (context, state) =>
        state.extra is Resume ? null : '/resumes',
        pageBuilder: (context, state) {
          final resume = state.extra! as Resume;

          return AppPageTransition.slide(
            child: ResumeEditorPage(resume: resume),
          );
        },
      ),

      GoRoute(
        path: '/resumes/preview',
        redirect: (context, state) =>
        state.extra is Resume ? null : '/resumes',
        pageBuilder: (context, state) {
          final resume = state.extra! as Resume;

          return AppPageTransition.slide(
            child: ResumePreviewPage(resume: resume),
          );
        },
      ),

      GoRoute(
        path: '/public/resumes/:uid/:resumeId',
        pageBuilder: (context, state) =>
            AppPageTransition.slide(
              child: PublicResumePage(
                uid: state.pathParameters['uid']!,
                resumeId: state.pathParameters['resumeId']!,
              ),
            ),
      ),
    ],
  );
}

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
