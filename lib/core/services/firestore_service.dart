import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/quote_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // USER DATA
  // ---------------------------------------------------------------------------

  Future<void> saveUser(User user) async {
    try {
      final docRef = _db.collection('users').doc(user.uid);

      // Use set with merge: true to avoid overwriting existing fields if we add more later
      // and only update what's necessary or new.
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      print('Error saving user to Firestore: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // FAVORITES
  // ---------------------------------------------------------------------------

  /// Stream of user's favorite quotes
  Stream<List<Quote>> getFavorites(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // We stored the quote data in the document, map it back to Quote model.
            // We added 'savedAt' for sorting, but Quote model might not have it.
            // Quote.fromJson matches the standard fields.
            return Quote.fromJson(doc.data());
          }).toList();
        });
  }

  /// Add a quote to favorites
  Future<void> addFavorite(String uid, Quote quote) async {
    try {
      // Use a consistent ID generation strategy to avoid duplicates.
      // A simple way is to hash the content or just rely on text+author as uniqueness.
      // Firestore document IDs can be strings. Let's create a composite ID.
      // Replacing special chars to ensure valid doc ID.
      final docId = '${quote.author}_${quote.text}'.replaceAll(
        RegExp(r'[/\\]'),
        '',
      );

      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(docId);

      final data = quote.toJson();
      data['savedAt'] =
          FieldValue.serverTimestamp(); // Add timestamp for sorting

      await docRef.set(data);
    } catch (e) {
      // ignore: avoid_print
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  /// Remove a quote from favorites
  Future<void> removeFavorite(String uid, Quote quote) async {
    try {
      final docId = '${quote.author}_${quote.text}'.replaceAll(
        RegExp(r'[/\\]'),
        '',
      );

      await _db
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(docId)
          .delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error removing favorite: $e');
      rethrow;
    }
  }
}
