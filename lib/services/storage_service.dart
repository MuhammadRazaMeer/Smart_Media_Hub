import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadFile(Uint8List bytes, String fileName, String folder) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final ref = _storage.ref().child('users/${user.uid}/$folder/$fileName');
      final uploadTask = await ref.putData(bytes);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> saveToHistory({
    required String fileName,
    required String fileType,
    required String operation,
    required int fileSize,
    required String downloadUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('history').add({
      'fileName': fileName,
      'fileType': fileType,
      'operation': operation,
      'fileSize': fileSize,
      'downloadUrl': downloadUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> historyStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteHistoryItem(String docId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .doc(docId)
        .delete();
  }
}
