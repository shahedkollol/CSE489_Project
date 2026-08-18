import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/draw_round.dart';

class DrawRepository {
  DrawRepository(this._firestore, this._tournamentId);

  final FirebaseFirestore _firestore;
  final String _tournamentId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('tournaments').doc(_tournamentId).collection('draws');

  Stream<List<DrawRound>> watchAll() {
    return _collection.orderBy('roundNumber').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => DrawRound.fromFirestore(doc.id, doc.data())).toList(),
    );
  }

  Future<void> create(DrawRound drawRound) {
    return _collection.add(drawRound.toFirestore());
  }

  Future<void> delete(String id) {
    return _collection.doc(id).delete();
  }
}
