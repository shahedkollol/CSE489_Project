import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/venue.dart';

class VenueRepository {
  VenueRepository(this._firestore, this._tournamentId);

  final FirebaseFirestore _firestore;
  final String _tournamentId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('tournaments').doc(_tournamentId).collection('venues');

  Stream<List<Venue>> watchAll() {
    return _collection.orderBy('name').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Venue.fromFirestore(doc.id, doc.data())).toList(),
    );
  }

  Future<String> create({
    required String name,
    required String building,
    required int capacity,
  }) async {
    final doc = await _collection.add({
      'name': name,
      'building': building,
      'capacity': capacity,
    });
    return doc.id;
  }

  Future<void> update(Venue venue) {
    return _collection.doc(venue.id).set(venue.toFirestore());
  }

  Future<void> delete(String id) {
    return _collection.doc(id).delete();
  }
}
