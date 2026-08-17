/// The set of roles a signed-in user can have. Role is assigned by whoever
/// creates the account (the tab director) and is stored in Firestore, never
/// chosen by the user at sign-in time.
enum UserRole { admin, adjudicator, team, public }

extension UserRoleX on UserRole {
  static UserRole fromName(String? name) {
    return UserRole.values.firstWhere(
      (r) => r.name == name,
      orElse: () => UserRole.public,
    );
  }
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.tournamentId,
    this.adjudicatorId,
    this.teamId,
  });

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;

  /// Which tournament this account is scoped to. Null for super-admins
  /// who manage multiple tournaments.
  final String? tournamentId;

  /// Links this account to its Adjudicator document, when role == adjudicator.
  final String? adjudicatorId;

  /// Links this account to its Team document, when role == team.
  final String? teamId;

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: UserRoleX.fromName(data['role'] as String?),
      tournamentId: data['tournamentId'] as String?,
      adjudicatorId: data['adjudicatorId'] as String?,
      teamId: data['teamId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'tournamentId': tournamentId,
        'adjudicatorId': adjudicatorId,
        'teamId': teamId,
      };
}
