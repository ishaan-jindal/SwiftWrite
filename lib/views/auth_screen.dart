import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writer/controllers/note_controller.dart';
import 'package:writer/data/services/auth_service.dart';
import 'package:writer/data/services/cloud_sync_service.dart';
import 'package:writer/data/services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthService? _authService;

  bool _isSignInMode = true;
  bool _isLoading = false;
  bool _isPreparingAuth = false;

  @override
  void initState() {
    super.initState();
    _prepareAuth();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prepareAuth() async {
    setState(() {
      _isPreparingAuth = true;
    });

    if (!Get.isRegistered<AuthService>()) {
      final initialized = await FirebaseService.initializeFromEnv();
      if (initialized) {
        _authService = Get.put(AuthService(), permanent: true);
        if (!Get.isRegistered<CloudSyncService>()) {
          Get.put(CloudSyncService(), permanent: true);
        }
      }
    } else {
      _authService = Get.find<AuthService>();
      if (!Get.isRegistered<CloudSyncService>()) {
        Get.put(CloudSyncService(), permanent: true);
      }
    }

    if (mounted) {
      _emailController.text = _authService?.email ?? '';
      setState(() {
        _isPreparingAuth = false;
      });
    }
  }

  Future<void> _submit() async {
    final AuthService? authService = _authService;
    if (authService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase auth is not available in the current setup.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignInMode) {
        await authService.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await authService.registerWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (mounted) {
        if (Get.isRegistered<NoteController>()) {
          await Get.find<NoteController>().syncWithCloudMergeLatestWins();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSignInMode ? 'Signed in successfully.' : 'Account created.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Get.back();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.explainAuthError(error)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final AuthService? authService = _authService;
    if (authService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase auth is not available in the current setup.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email address first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.explainAuthError(error)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = _authService;
    final isSignedIn = authService?.isSignedIn == true;

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: _isPreparingAuth
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cloud Features',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isSignedIn
                                ? 'Enabled automatically because your account is signed in.'
                                : 'Disabled until you sign in.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (isSignedIn) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Signed in as ${authService?.email ?? 'a Firebase user'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () async {
                                await authService?.signOut();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Signed out.'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  setState(() {});
                                }
                              },
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!isSignedIn) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isSignInMode ? 'Sign In' : 'Create Account',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your email address.';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Enter a valid email address.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your password.';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _submit,
                                  child: Text(
                                    _isLoading
                                        ? 'Working...'
                                        : (_isSignInMode
                                              ? 'Sign In'
                                              : 'Create Account'),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _isSignInMode = !_isSignInMode;
                                            });
                                          },
                                    child: Text(
                                      _isSignInMode
                                          ? 'Need an account?'
                                          : 'Already have an account?',
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _resetPassword,
                                    child: const Text('Reset password'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
