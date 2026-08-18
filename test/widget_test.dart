// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:debate_tab_app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() {
  testWidgets('The app launches to the sign-in screen when no authenticated user exists', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DebateTabApp()));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}
