import 'package:flutter/material.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'auth_screens.dart';

/// A.10 Profile and privacy
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Scaffold(
          body: Column(
            children: [
              const TopBar(title: 'Profile and privacy', back: '<'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const InfoRow(
                      title: 'Jhon Doe',
                      subtitle: 'Angler since 2026',
                    ),
                    const SizedBox(height: 20),
                    const Text('SHARING (all off by default)',
                        style: TextStyle(fontSize: 12, color: kMuted)),
                    const SizedBox(height: 8),
                    InfoRow(
                      title: 'Share catch location',
                      subtitle: 'Friends can see where you fished',
                      trailing: WireSwitch(
                        on: store.shareLocation,
                        onChanged: store.setShareLocation,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      title: 'Share photos',
                      subtitle: 'Friends can see your catch photos',
                      trailing: WireSwitch(
                        on: store.sharePhotos,
                        onChanged: store.setSharePhotos,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      title: 'Allow compare',
                      subtitle: 'Friends can compare stats with you',
                      trailing: WireSwitch(
                        on: store.allowCompare,
                        onChanged: store.setAllowCompare,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinePill(
                      'Sign out',
                      onTap: () =>
                          Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const SignInScreen()),
                        (route) => false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
