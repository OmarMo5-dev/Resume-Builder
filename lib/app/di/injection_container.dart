import 'package:business_os/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/send_email_verification.dart';
import '../../features/auth/domain/usecases/send_password_reset_email.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/resume/data/datasources/resume_remote_data_source.dart';
import '../../features/resume/data/repositories/firestore_resume_repository.dart';
import '../../features/resume/domain/repositories/resume_repository.dart';
import '../../features/resume/domain/usecases/create_resume.dart';
import '../../features/resume/domain/usecases/delete_resume.dart';
import '../../features/resume/domain/usecases/duplicate_resume.dart';
import '../../features/resume/domain/usecases/get_resumes.dart';
import '../../features/resume/domain/usecases/get_resume.dart';
import '../../features/resume/domain/usecases/get_public_resume.dart';
import '../../features/resume/domain/usecases/update_resume.dart';
import '../../features/resume/presentation/cubit/resumes_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/firestore_profile_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';


final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final firebaseAuth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn.instance;

  await googleSignIn.initialize(
    serverClientId:
    '223428772506-vit1kdpngcsh68g2t1jpn0jqq1j5ti0f.apps.googleusercontent.com',
  );

  getIt.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
  );

  /// Auth

  getIt.registerLazySingleton<FirebaseAuth>(() => firebaseAuth);

  getIt.registerLazySingleton<GoogleSignIn>(() => googleSignIn);

  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  getIt.registerFactory<AuthCubit>(
        () => AuthCubit(
      signIn: getIt<SignIn>(),
      register: getIt<Register>(),
      signInWithGoogle: getIt<SignInWithGoogle>(),
      sendPasswordResetEmail: getIt<SendPasswordResetEmail>(),
      sendEmailVerification: getIt<SendEmailVerification>(),
      signOut: getIt<SignOut>(),
      authStateChanges: getIt<AuthRepository>().authStateChanges,
    ),
  );

  getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));

  getIt.registerLazySingleton(() => Register(getIt<AuthRepository>()));

  getIt.registerLazySingleton(() => SignInWithGoogle(getIt<AuthRepository>()));

  getIt.registerLazySingleton(
        () => SendPasswordResetEmail(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(
        () => SendEmailVerification(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));

  /// Profile

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSource(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<ProfileRepository>(
        () => FirestoreProfileRepository(getIt<ProfileRemoteDataSource>()),
  );

  getIt.registerLazySingleton(() => GetProfile(getIt<ProfileRepository>()));
  getIt.registerLazySingleton(() => UpdateProfile(getIt<ProfileRepository>()));

  getIt.registerFactory<ProfileCubit>(
        () => ProfileCubit(
      getProfile: getIt<GetProfile>(),
      updateProfile: getIt<UpdateProfile>(),
    ),
  );

  /// Resumes

  getIt.registerLazySingleton<ResumeRemoteDataSource>(
        () => ResumeRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<ResumeRepository>(
        () => FirestoreResumeRepository(
      remoteDataSource: getIt<ResumeRemoteDataSource>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton(() => GetResumes(getIt<ResumeRepository>()));

  getIt.registerLazySingleton(() => GetResume(getIt<ResumeRepository>()));

  getIt.registerLazySingleton(() => GetPublicResume(getIt<ResumeRepository>()));

  getIt.registerLazySingleton(() => CreateResume(getIt<ResumeRepository>()));

  getIt.registerLazySingleton(() => UpdateResume(getIt<ResumeRepository>()));

  getIt.registerLazySingleton(() => DeleteResume(getIt<ResumeRepository>()));

  getIt.registerLazySingleton(
        () => DuplicateResume(
      getIt<ResumeRepository>(),
    ),
  );

  getIt.registerFactory<ResumesCubit>(
        () => ResumesCubit(
      getResumes: getIt<GetResumes>(),
      createResume: getIt<CreateResume>(),
      updateResume: getIt<UpdateResume>(),
      deleteResume: getIt<DeleteResume>(),
      duplicateResume: getIt<DuplicateResume>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // ResumeEditorCubit is created by the editor page because it needs the selected resume.

}
