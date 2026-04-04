import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:writer/data/models/note.dart';

class CloudNoteRecord {
  final String cloudId;
  final Note note;

  CloudNoteRecord({required this.cloudId, required this.note});
}

class CloudSyncService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _syncBox = Hive.box('note_sync');

  bool get isReady => _auth.currentUser != null;

  User? get currentUser => _auth.currentUser;

  Future<void> upsertNote({
    required dynamic localKey,
    required Note note,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final collection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes');

    final mappingKey = _mappingKey(user.uid, localKey);
    final existingCloudId = _syncBox.get(mappingKey) as String?;

    final payload = {
      'title': note.title,
      'content': note.content,
      'tags': note.tags,
      'order': note.order,
      'fileExtension': note.fileExtension,
      'createdAt': Timestamp.fromDate(note.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(note.updatedAt.toUtc()),
      'updatedBy': 'swiftwrite-client',
    };

    if (existingCloudId != null && existingCloudId.isNotEmpty) {
      await collection
          .doc(existingCloudId)
          .set(payload, SetOptions(merge: true));
      return;
    }

    final docRef = collection.doc();
    await docRef.set(payload);
    await _syncBox.put(mappingKey, docRef.id);
  }

  Future<List<CloudNoteRecord>> fetchCloudNotes() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const [];
    }

    final query = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .get();

    return query.docs.map((doc) {
      final data = doc.data();

      DateTime readDate(dynamic value, DateTime fallback) {
        if (value is Timestamp) {
          return value.toDate();
        }
        if (value is DateTime) {
          return value;
        }
        return fallback;
      }

      final createdAt = readDate(data['createdAt'], DateTime.now());
      final updatedAt = readDate(data['updatedAt'], createdAt);

      final cloudNote = Note(
        title: (data['title'] as String?) ?? 'Untitled',
        content: (data['content'] as String?) ?? '',
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: ((data['tags'] as List?) ?? const []).cast<String>(),
        order: data['order'] as int?,
        fileExtension: data['fileExtension'] as String?,
      );

      return CloudNoteRecord(cloudId: doc.id, note: cloudNote);
    }).toList(growable: false);
  }

  String? getCloudIdForLocalKey(dynamic localKey) {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return _syncBox.get(_mappingKey(user.uid, localKey)) as String?;
  }

  Future<void> setMapping({
    required dynamic localKey,
    required String cloudId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await _syncBox.put(_mappingKey(user.uid, localKey), cloudId);
  }

  Future<void> deleteNote({required dynamic localKey}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final mappingKey = _mappingKey(user.uid, localKey);
    final existingCloudId = _syncBox.get(mappingKey) as String?;
    if (existingCloudId == null || existingCloudId.isEmpty) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(existingCloudId)
        .delete();

    await _syncBox.delete(mappingKey);
  }

  String _mappingKey(String userId, dynamic localKey) {
    return '$userId::$localKey';
  }
}
