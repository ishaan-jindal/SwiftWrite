import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writer/data/services/auth_service.dart';
import 'package:writer/data/services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AuthService? _authService;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<AuthService>()) {
      _authService = Get.find<AuthService>();
    }
  }

  Future<void> _openAuthScreen() async {
    if (!Get.isRegistered<AuthService>()) {
      final initialized = await FirebaseService.initializeFromEnv();
      if (!initialized && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not initialize Firebase. Check your .env Firebase values first.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      _authService = Get.put(AuthService(), permanent: true);
    }

    if (mounted) {
      await Get.toNamed('/auth');
      setState(() {
        if (Get.isRegistered<AuthService>()) {
          _authService = Get.find<AuthService>();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Features',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _authService?.isSignedIn == true
                          ? 'Enabled automatically because you are signed in.'
                          : 'Disabled because no account is signed in.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Account',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _authService?.isSignedIn == true
                          ? 'Signed in as ${_authService?.email ?? 'a Firebase user'}.'
                          : 'Sign in to enable cloud sync and internet features.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: _openAuthScreen,
                          child: Text(
                            _authService?.isSignedIn == true
                                ? 'Manage Account'
                                : 'Sign In / Create Account',
                          ),
                        ),
                        if (_authService?.isSignedIn == true)
                          OutlinedButton(
                            onPressed: () async {
                              await _authService?.signOut();
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
