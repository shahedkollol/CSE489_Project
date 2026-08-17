import 'package:flutter/material.dart';

/// Shown only for the instant it takes Firebase to report whether a user
/// is already signed in. app_router.dart's redirect logic moves past this
/// as soon as authStateChangesProvider resolves.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
