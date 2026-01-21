import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../data/models/quote_model.dart';
import '../../data/models/quote_collection.dart';
import '../../data/models/user_stats.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // USER DATA
  // ---------------------------------------------------------------------------

  Future<void> saveUser(User user) async {
    try {
      final docRef = _db.collection('users').doc(user.uid);

      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update streak and last active date
      await _updateStreak(user.uid);

      developer.log(
        'User saved and streak updated: ${user.uid}',
        name: 'ThoughtVault.Firestore',
      );
    } catch (e) {
      developer.log(
        'Error saving user to Firestore',
        name: 'ThoughtVault.Firestore',
        error: e,
      );
    }
  }

  Future<void> _updateStreak(String uid) async {
    final docRef = _db.collection('users').doc(uid);
    final snapshot = await docRef.get();
    final data = snapshot.data();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (data == null || !data.containsKey('lastActiveDate')) {
      // First time active
      await docRef.set({
        'streak': 1,
        'lastActiveDate': Timestamp.fromDate(today),
        'quotesReadToday': 0,
      }, SetOptions(merge: true));
      return;
    }

    final lastActiveTimestamp = data['lastActiveDate'] as Timestamp;
    final lastActiveDate = lastActiveTimestamp.toDate();
    final lastActive = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );

    int currentStreak = data['streak'] ?? 0;

    if (today.isAtSameMomentAs(lastActive)) {
      // Already active today, do nothing
      return;
    } else if (today.difference(lastActive).inDays == 1) {
      // Streak continues
      await docRef.update({
        'streak': currentStreak + 1,
        'lastActiveDate': Timestamp.fromDate(today),
        'quotesReadToday': 0, // Reset daily goal
      });
    } else {
      // Streak broken
      await docRef.update({
        'streak': 1,
        'lastActiveDate': Timestamp.fromDate(today),
        'quotesReadToday': 0,
      });
    }
  }

  Stream<UserStats> getUserStats(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return const UserStats();

      // Map Firestore timestamp to DateTime for the model
      final map = Map<String, dynamic>.from(data);
      if (map['lastActiveDate'] != null) {
        map['lastActiveDate'] = (map['lastActiveDate'] as Timestamp)
            .toDate()
            .toIso8601String();
      }

      return UserStats.fromJson(map);
    });
  }

  Future<void> incrementQuotesRead(String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'quotesReadToday': FieldValue.increment(1),
      });
    } catch (e) {
      developer.log(
        'Error incrementing quotes read',
        name: 'ThoughtVault.Firestore',
        error: e,
      );
    }
  }

  Future<void> updateDailyGoal(String uid, int newGoal) async {
    try {
      await _db.collection('users').doc(uid).update({'dailyGoal': newGoal});
    } catch (e) {
      developer.log(
        'Error updating daily goal',
        name: 'ThoughtVault.Firestore',
        error: e,
      );
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
      developer.log(
        'Quote added to favorites: $docId',
        name: 'ThoughtVault.Firestore',
      );
    } catch (e) {
      developer.log(
        'Error adding favorite',
        name: 'ThoughtVault.Firestore',
        error: e,
      );
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
      developer.log(
        'Quote removed from favorites: $docId',
        name: 'ThoughtVault.Firestore',
      );
    } catch (e) {
      developer.log(
        'Error removing favorite',
        name: 'ThoughtVault.Firestore',
        error: e,
      );
      rethrow;
    }
  }
  // ---------------------------------------------------------------------------
  // COLLECTIONS
  // ---------------------------------------------------------------------------

  /// Stream of user's quote collections
  Stream<List<QuoteCollection>> getCollections(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('collections')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            if (data['createdAt'] is Timestamp) {
              data['createdAt'] = (data['createdAt'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }
            return QuoteCollection.fromJson(data);
          }).toList();
        });
  }

  /// Create a new collection
  Future<void> createCollection(String uid, String name) async {
    try {
      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('collections')
          .doc();

      await docRef.set({
        'name': name,
        'quotes': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      developer.log(
        'Collection created: $name',
        name: 'ThoughtVault.Firestore',
      );
    } catch (e) {
      developer.log(
        'Error creating collection',
        name: 'ThoughtVault.Firestore',
        error: e,
      );
      rethrow;
    }
  }

  /// Delete a collection
  Future<void> deleteCollection(String uid, String collectionId) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('collections')
          .doc(collectionId)
          .delete();
      developer.log(
        'Collection deleted: $collectionId',
        name: 'ThoughtVault.Firestore',
      );
    } catch (e) {
      developer.log(
        'Error deleting collection',
        name: 'ThoughtVault.Firestore',
        error: e,
      );
      rethrow;
    }
  }

  /// Add a quote to a specific collection
  Future<void> addQuoteToCollection(
    String uid,
    String collectionId,
    Quote quote,
  ) async {
    try {
      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('collections')
          .doc(collectionId);

      await docRef.update({
        'quotes': FieldValue.arrayUnion([quote.toJson()]),
      });
      developer.log(
        'Quote added to collection: $collectionId',
        name: 'ThoughtVault.Firestore',
      );
    } catch (e) {
      developer.log(
        'Error adding quote to collection',
        name: 'ThoughtVault.Firestore',
        error: e,
      );
      rethrow;
    }
  }

  /// Remove a quote from a specific collection
  Future<void> removeQuoteFromCollection(
    String uid,
    String collectionId,
    Quote quote,
  ) async {
    try {
      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('collections')
          .doc(collectionId);

      // Note: arrayRemove requires the exact object to match.
      // Firestore stores the JSON representation.
      await docRef.update({
        'quotes': FieldValue.arrayRemove([quote.toJson()]),
      });
      developer.log(
        'Quote removed from collection: $collectionId',
        name: 'ThoughtVault.Firestore',
      );
    } catch (e) {
      developer.log(
        'Error removing quote from collection',
        name: 'ThoughtVault.Firestore',
        error: e,
      );
      rethrow;
    }
  }
}
