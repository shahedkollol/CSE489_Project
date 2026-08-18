import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/motion.dart';

class MotionRepository {
  MotionRepository(this._firestore, this._tournamentId);

  final FirebaseFirestore _firestore;
  final String _tournamentId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('tournaments').doc(_tournamentId).collection('motions');

  Stream<List<Motion>> watchAll() {
    return _collection.orderBy('round').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Motion.fromFirestore(doc.id, doc.data())).toList(),
    );
  }

  Future<String> create({
    required String text,
    required String info,
    required int round,
  }) async {
    final doc = await _collection.add({
      'text': text,
      'info': info,
      'round': round,
    });
    return doc.id;
  }

  Future<void> update(Motion motion) {
    return _collection.doc(motion.id).set(motion.toFirestore());
  }

  Future<void> delete(String id) {
    return _collection.doc(id).delete();
  }
}
