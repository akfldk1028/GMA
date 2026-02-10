import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../mutations/login_mutation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final mutation = ref.read(loginMutationProvider.notifier);
    try {
      await mutation.call(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Login Failed'),
            description: Text('Please check your credentials.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginMutationProvider);
    final isLoading = loginState.isLoading;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ShadCard(
              title: const Text('Login'),
              description: const Text('Enter your credentials to continue.'),
              child: ShadForm(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      id: 'email',
                      label: const Text('Email'),
                      placeholder: const Text('your@email.com'),
                      controller: _emailController,
                      validator: (v) =>
                          v.isEmpty ? 'Email is required' : null,
                    ),
                    const SizedBox(height: 12),
                    ShadInputFormField(
                      id: 'password',
                      label: const Text('Password'),
                      placeholder: const Text('Password'),
                      obscureText: true,
                      controller: _passwordController,
                      validator: (v) =>
                          v.isEmpty ? 'Password is required' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ShadButton(
                        onPressed: isLoading ? null : _handleLogin,
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
