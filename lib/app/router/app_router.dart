import 'package:business_os/app/di/injection_container.dart';
import 'package:business_os/app/router/app_page_transition.dart';
import 'package:business_os/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:business_os/features/resume/presentation/cubit/resumes_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/resume/domain/entities/resume.dart';
import '../../features/resume/presentation/pages/public_resume_page.dart';
import '../../features/resume/presentation/pages/resume_editor_page.dart';
import '../../features/resume/presentation/pages/resume_preview_page.dart';
import '../../features/resume/presentation/pages/resumes_page.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/auth/login',
    routes: [
      GoRoute(path: '/auth/login', pageBuilder: (context, state) => AppPageTransition.slide(child: BlocProvider(create: (_) => getIt<AuthCubit>(), child: const LoginPage()))),
      GoRoute(path: '/auth/register', pageBuilder: (context, state) => AppPageTransition.slide(child: BlocProvider(create: (_) => getIt<AuthCubit>(), child: const RegisterPage()))),
      GoRoute(path: '/auth/forgot-password', pageBuilder: (context, state) => AppPageTransition.slide(child: BlocProvider(create: (_) => getIt<AuthCubit>(), child: const ForgotPasswordPage()))),
      GoRoute(path: '/profile', pageBuilder: (context, state) => AppPageTransition.slide(child: const ProfilePage())),
      GoRoute(
        path: '/resumes',
        pageBuilder: (context, state) => AppPageTransition.slide(
          child: BlocProvider(create: (_) => getIt<ResumesCubit>()..loadResumes(), child: const ResumesPage()),
        ),
      ),
      GoRoute(
        path: '/resumes/editor',
        // Route arguments are required; deep-linking without them falls back
        // to the list instead of crashing on a bad cast.
        redirect: (context, state) => state.extra is Resume ? null : '/resumes',
        pageBuilder: (context, state) {
          final resume = state.extra! as Resume;
          return AppPageTransition.slide(child: ResumeEditorPage(resume: resume));
        },
      ),
      GoRoute(
        path: '/resumes/preview',
        redirect: (context, state) => state.extra is Resume ? null : '/resumes',
        pageBuilder: (context, state) {
          final resume = state.extra! as Resume;
          return AppPageTransition.slide(child: ResumePreviewPage(resume: resume));
        },
      ),
      GoRoute(
        path: '/public/resumes/:uid/:resumeId',
        pageBuilder: (context, state) => AppPageTransition.slide(
          child: PublicResumePage(uid: state.pathParameters['uid']!, resumeId: state.pathParameters['resumeId']!),
        ),
      ),
    ],
  );
}
