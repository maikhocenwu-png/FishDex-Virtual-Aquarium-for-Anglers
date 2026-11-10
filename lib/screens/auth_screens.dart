import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'home_screen.dart';

void _enterApp(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (route) => false,
  );
}

Widget _errorText(String? message) {
  if (message == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(message,
        style: const TextStyle(fontSize: 13, color: Color(0xFFB00020))),
  );
}

/// A.1 Sign in
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      final name = res.user?.userMetadata?['display_name'] as String?;
      store.userName = (name != null && name.isNotEmpty)
          ? name
          : email.split('@').first;
      store.userEmail = email;
      if (!mounted) return;
      _enterApp(context);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not connect. Check your internet.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
                    child: Text('FishDex',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: kInk)),
                  ),
                  const Center(
                    child: Text('Every catch becomes a fish in your aquarium',
                        style: TextStyle(fontSize: 13, color: kMuted)),
                  ),
                  const SizedBox(height: 24),
                  const FieldLabel('Email'),
                  AppField(
                    controller: _email,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const FieldLabel('Password'),
                  AppField(
                      controller: _password, hint: 'Password', obscure: true),
                  _errorText(_error),
                  const SizedBox(height: 24),
                  DarkButton(_busy ? 'Signing in...' : 'Sign in',
                      onTap: _busy ? null : _signIn),
                  const SizedBox(height: 12),
                  OutlinePill(
                    'Create account',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CreateAccountScreen()),
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
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }
    if (password != _confirm.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );
      if (res.session == null) {
        // Email confirmation is still turned on in Supabase.
        setState(() => _error = 'Check your email to confirm, then sign in.');
        return;
      }
      store.userName = name.isNotEmpty ? name : email.split('@').first;
      store.userEmail = email;
      if (!mounted) return;
      _enterApp(context);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not connect. Check your internet.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
                  AppField(controller: _name, hint: 'Name shown to friends'),
                  const FieldLabel('Email'),
                  AppField(
                    controller: _email,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const FieldLabel('Password'),
                  AppField(
                      controller: _password,
                      hint: 'At least 8 characters',
                      obscure: true),
                  const FieldLabel('Confirm password'),
                  AppField(
                      controller: _confirm,
                      hint: 'Type it again',
                      obscure: true),
                  const SizedBox(height: 12),
                  const Text(
                    'New accounts share nothing by default. '
                    'You choose what to share later in Profile and privacy.',
                    style: TextStyle(fontSize: 12, color: kMuted),
                  ),
                  _errorText(_error),
                  const SizedBox(height: 24),
                  DarkButton(_busy ? 'Creating...' : 'Create account',
                      onTap: _busy ? null : _create),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}