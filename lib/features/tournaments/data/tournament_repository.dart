import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tournament.dart';

class TournamentRepository {
  TournamentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('tournaments');

  Stream<List<Tournament>> watchAll() {
    return _collection.orderBy('name').snapshots().map(
          (snap) => snap.docs.map((d) => Tournament.fromFirestore(d.id, d.data())).toList(),
        );
  }

  Stream<Tournament?> watchById(String id) {
    return _collection.doc(id).snapshots().map(
          (doc) => doc.exists ? Tournament.fromFirestore(doc.id, doc.data()!) : null,
        );
  }

  Future<String> create({
    required String name,
    required String slug,
    required TournamentFormat format,
  }) async {
    final doc = await _collection.add({
      'name': name,
      'slug': slug,
      'format': format.short,
    });
    return doc.id;
  }

  Future<void> update(Tournament tournament) {
    return _collection.doc(tournament.id).set(tournament.toFirestore());
  }

  Future<void> delete(String id) {
    return _collection.doc(id).delete();
  }
}
