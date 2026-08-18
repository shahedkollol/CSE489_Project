import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/adjudicator/presentation/adjudicator_home_page.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/ballots/presentation/ballot_page.dart';
import '../../features/draw/presentation/draw_page.dart';
import '../../features/motions/presentation/motion_page.dart';
import '../../features/participants/presentation/team_page.dart';
import '../../features/public/presentation/public_home_page.dart';
import '../../features/standings/presentation/standings_page.dart';
import '../../features/tournaments/presentation/tournament_dashboard_page.dart';
import '../../features/tournaments/presentation/tournament_form_page.dart';
import '../../features/tournaments/presentation/tournament_list_page.dart';
import '../../features/venues/presentation/venue_page.dart';

/// Centralizes all role-based routing. This is the piece that replaces the
/// wireframe's "tap a role button" screen: it decides where a signed-in
/// user lands based on the role stored in Firestore, not on user input.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Listenable that notifies go_router to re-evaluate `redirect` whenever
  // auth state or the user's profile changes.
  final refreshListenable = _GoRouterRefreshStream(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/admin', builder: (context, state) => const TournamentListPage()),
      // Literal path registered before the :id route below, so "new"
      // resolves here instead of being captured as a tournament id.
      GoRoute(
        path: '/admin/tournaments/new',
        builder: (context, state) => const TournamentFormPage(),
      ),
      GoRoute(
        path: '/admin/tournaments/:id',
        builder: (context, state) {
          return TournamentDashboardPage(tournamentId: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/admin/tournaments/:id/edit',
        builder: (context, state) {
          return TournamentFormPage(tournamentId: state.pathParameters['id']);
        },
      ),
      GoRoute(
        path: '/admin/tournaments/:id/participants',
        builder: (context, state) {
          return TeamPage(tournamentId: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/admin/tournaments/:id/venues',
        builder: (context, state) {
          return VenuePage(tournamentId: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/admin/tournaments/:id/motions',
        builder: (context, state) {
          return MotionPage(tournamentId: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/admin/tournaments/:id/draw',
        builder: (context, state) {
          return DrawPage(tournamentId: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/admin/tournaments/:id/ballots',
        builder: (context, state) {
          return BallotPage(tournamentId: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/admin/tournaments/:id/standings',
        builder: (context, state) {
          return StandingsPage(tournamentId: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/adjudicator',
        builder: (context, state) => const AdjudicatorHomePage(),
      ),
      GoRoute(path: '/public', builder: (context, state) => const PublicHomePage()),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final goingTo = state.matchedLocation;

      // Firebase hasn't reported initial auth state yet: stay on splash.
      if (authState.isLoading) return goingTo == '/' ? null : '/';

      final firebaseUser = authState.valueOrNull;

      // Signed out: only /login and /public are reachable.
      if (firebaseUser == null) {
        if (goingTo == '/login' || goingTo == '/public') return null;
        return '/login';
      }

      // Signed in but on splash or login: send to the right home once we
      // know the role. While the profile is still loading, park on splash.
      final profileState = ref.read(currentUserProfileProvider);
      if (profileState.isLoading) return goingTo == '/' ? null : '/';

      final profile = profileState.valueOrNull;
      final homeForRole = _homeRouteFor(profile?.role);

      if (goingTo == '/' || goingTo == '/login') return homeForRole;

      // Prevent an adjudicator from typing /admin/... into the address bar, etc.
      // startsWith, not ==, so nested routes like /admin/tournaments/new are
      // covered too.
      if (goingTo.startsWith('/admin') && profile?.role != UserRole.admin) return homeForRole;
      if (goingTo.startsWith('/adjudicator') &&
          !(profile?.role == UserRole.adjudicator || profile?.role == UserRole.team)) {
        return homeForRole;
      }

      return null;
    },
  );
});

String _homeRouteFor(UserRole? role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.adjudicator:
    case UserRole.team:
      return '/adjudicator';
    case UserRole.public:
    case null:
      return '/public';
  }
}

/// Bridges Riverpod's provider stream updates into something go_router's
/// `refreshListenable` (a plain ChangeNotifier) can listen to.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(this._ref) {
    _ref.listen(authStateChangesProvider, (_, __) => notifyListeners());
    _ref.listen(currentUserProfileProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
