import 'package:business_os/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isManualLogin = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _isManualLogin = true;

    context.read<AuthCubit>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.failure) {
                _isManualLogin = false;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message ?? 'Something went wrong'),
                  ),
                );
              }

              if (state.status == AuthStatus.authenticated) {
                if (_isManualLogin) {
                  _isManualLogin = false;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Welcome Back! ${state.user?.displayName ?? ""}",
                      ),
                    ),
                  );
                }
                context.go('/resumes');
              }
            },
            builder: (context, state) {
              final isLoadingAuth = state.status == AuthStatus.authLoading;
              final isLoadingGoogle = state.status == AuthStatus.googleLoading;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.description_outlined, size: 64),

                          const SizedBox(height: 24),

                          Text(
                            'Welcome back',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Sign in to continue building your resume.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),

                          const SizedBox(height: 32),

                          /// Email
                          CustomTextField(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email_outlined),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final email = value?.trim() ?? '';

                              if (email.isEmpty) {
                                return 'Enter your email';
                              }

                              if (!email.contains('@')) {
                                return 'Enter a valid email';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          /// Password
                          CustomTextField(
                            labelText: "Password",
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your password';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          FilledButton(
                            onPressed: isLoadingAuth ? null : _submit,
                            child: isLoadingAuth
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),

                          const SizedBox(height: 16),

                          OutlinedButton.icon(
                            onPressed: isLoadingGoogle
                                ? null
                                : () {
                                    _isManualLogin = true;

                                    context
                                        .read<AuthCubit>()
                                        .signInWithGoogle();
                                  },
                            icon: const Icon(
                              Icons.g_mobiledata_rounded,
                              size: 22,
                            ),
                            label: const Text('Continue with Google'),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              TextButton(
                                onPressed: () => context.go('/auth/register'),
                                child: const Text('Create account'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
