import 'package:flutter/material.dart';

import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'home_screen.dart';

void _enterApp(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (route) => false,
  );
}

/// A.1 Sign in
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopBar(title: 'Sign in'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Center(child: FishShape()),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'FishDex',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Every catch becomes a fish in your aquarium',
                      style: TextStyle(fontSize: 13, color: kMuted),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const FieldLabel('Email'),
                  const AppField(
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const FieldLabel('Password'),
                  const AppField(hint: 'Password', obscure: true),
                  const SizedBox(height: 24),
                  DarkButton('Sign in', onTap: () => _enterApp(context)),
                  const SizedBox(height: 12),
                  OutlinePill(
                    'Create account',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateAccountScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A.16 Create account
class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopBar(title: 'Create account', back: '<'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Display name'),
                  const AppField(hint: 'Name shown to friends'),
                  const FieldLabel('Email'),
                  const AppField(
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const FieldLabel('Password'),
                  const AppField(hint: 'At least 8 characters', obscure: true),
                  const FieldLabel('Confirm password'),
                  const AppField(hint: 'Type it again', obscure: true),
                  const SizedBox(height: 12),
                  const Text(
                    'New accounts share nothing by default. '
                    'You choose what to share later in Profile and privacy.',
                    style: TextStyle(fontSize: 12, color: kMuted),
                  ),
                  const SizedBox(height: 24),
                  DarkButton(
                    'Create account',
                    onTap: () => _enterApp(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
