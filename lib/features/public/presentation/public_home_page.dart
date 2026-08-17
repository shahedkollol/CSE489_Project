import 'package:flutter/material.dart';

/// Public tab site: no sign-in required. Stub for now; the next build
/// pass adds the Draws / Standings / Break tab bar from the wireframes.
class PublicHomePage extends StatelessWidget {
  const PublicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draws & results')),
      body: const Center(child: Text('Public tab site \u2014 coming next')),
    );
  }
}
