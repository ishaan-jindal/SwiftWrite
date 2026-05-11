import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writer/features/auth/bloc/auth_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _openAuthScreen() async {
    final initialized = await context.read<AuthBloc>().ensureAuthInitialized();
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

    if (mounted) {
      await Navigator.of(context).pushNamed('/auth');
      setState(() {});
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
                    Builder(
                      builder: (ctx) {
                        final authState = ctx.watch<AuthBloc>().state;
                        return Text(
                          authState.isSignedIn
                              ? 'Enabled automatically because you are signed in.'
                              : 'Disabled because no account is signed in.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
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
                    Builder(
                      builder: (ctx) {
                        final authState = ctx.watch<AuthBloc>().state;
                        return Text(
                          authState.isSignedIn
                              ? 'Signed in as ${authState.email ?? 'a Firebase user'}.'
                              : 'Sign in to enable cloud sync and internet features.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: _openAuthScreen,
                          child: Builder(
                            builder: (ctx) {
                              final authState = ctx.watch<AuthBloc>().state;
                              return Text(
                                authState.isSignedIn
                                    ? 'Manage Account'
                                    : 'Sign In / Create Account',
                              );
                            },
                          ),
                        ),
                        Builder(
                          builder: (ctx) {
                            final authState = ctx.watch<AuthBloc>().state;
                            if (!authState.isSignedIn) {
                              return const SizedBox.shrink();
                            }

                            return OutlinedButton(
                              onPressed: () async {
                                await ctx.read<AuthBloc>().signOut();
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
                            );
                          },
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
