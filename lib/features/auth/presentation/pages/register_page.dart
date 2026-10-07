import 'package:business_os/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isManualLogin = false;


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _isManualLogin = true;

    context.read<AuthCubit>().register(
      email: _emailController.text,
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

              if (state.status == AuthStatus.authenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Welcome Back! ${state.user?.displayName ?? ""}",
                    ),
                  ),
                );
                context.go('/resumes');
              }
            },
            builder: (context, state) {
              final isLoading = state.status == AuthStatus.authLoading;

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
                            'Create your account',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Start building your professional resume.',
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          /// Name
                          CustomTextField(
                            labelText: "Full Name",
                            prefixIcon: Icon(Icons.person_outline),
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your name';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          /// Email
                          CustomTextField(
                            labelText: "Email",
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(Icons.email_outlined),
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
                            textInputAction: TextInputAction.next,
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
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          /// Confirm Password
                          CustomTextField(
                            labelText: "Confirm Password",
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          FilledButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Create account'),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account? '),
                              TextButton(
                                onPressed: () => context.go('/auth/login'),
                                child: const Text('Sign in'),
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
