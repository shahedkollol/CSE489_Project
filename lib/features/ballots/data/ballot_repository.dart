import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/ballot_result.dart';

class BallotRepository {
  BallotRepository(this._firestore, this._tournamentId);

  final FirebaseFirestore _firestore;
  final String _tournamentId;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('tournaments').doc(_tournamentId).collection('ballots');

  String _docIdFor({required int roundNumber, required String govTeamId, required String oppTeamId}) {
    return '$roundNumber' '_' '$govTeamId' '_' '$oppTeamId';
  }

  Stream<List<BallotResult>> watchAll() {
    return _collection.orderBy('roundNumber').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => BallotResult.fromFirestore(doc.id, doc.data())).toList(),
    );
  }

  Stream<List<BallotResult>> watchPublished() {
    return _collection.where('isPublished', isEqualTo: true).orderBy('roundNumber').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => BallotResult.fromFirestore(doc.id, doc.data())).toList(),
    );
  }

  Future<void> upsert({
    required int roundNumber,
    required String govTeamId,
    required String oppTeamId,
    required int govScore,
    required int oppScore,
    String note = '',
  }) async {
    final docId = _docIdFor(roundNumber: roundNumber, govTeamId: govTeamId, oppTeamId: oppTeamId);
    final existing = await _collection.doc(docId).get();
    final wasPublished = existing.exists ? (existing.data()?['isPublished'] as bool? ?? false) : false;

    await _collection.doc(docId).set({
      'roundNumber': roundNumber,
      'govTeamId': govTeamId,
      'oppTeamId': oppTeamId,
      'govScore': govScore,
      'oppScore': oppScore,
      'note': note,
      'isPublished': wasPublished,
    });
  }

  Future<void> publishRound(int roundNumber, {required bool published}) async {
    final snapshot = await _collection.where('roundNumber', isEqualTo: roundNumber).get();
    for (final doc in snapshot.docs) {
      await _collection.doc(doc.id).update({'isPublished': published});
    }
  }

  Future<void> deleteForDebate({required int roundNumber, required String govTeamId, required String oppTeamId}) {
    final docId = _docIdFor(roundNumber: roundNumber, govTeamId: govTeamId, oppTeamId: oppTeamId);
    return _collection.doc(docId).delete();
  }
}
