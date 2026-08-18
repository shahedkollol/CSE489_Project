import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/team.dart';

class TeamRepository {
  TeamRepository(this._firestore, this._tournamentId);

  final FirebaseFirestore _firestore;
  final String _tournamentId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('tournaments').doc(_tournamentId).collection('teams');

  Stream<List<Team>> watchAll() {
    return _collection.orderBy('name').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Team.fromFirestore(doc.id, doc.data())).toList(),
    );
  }

  Future<String> create({
    required String name,
    required String shortName,
    required String institution,
  }) async {
    final doc = await _collection.add({
      'name': name,
      'shortName': shortName,
      'institution': institution,
    });
    return doc.id;
  }

  Future<void> update(Team team) {
    return _collection.doc(team.id).set(team.toFirestore());
  }

  Future<void> delete(String id) {
    return _collection.doc(id).delete();
  }
}
