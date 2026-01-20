import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/auth_provider.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../data/models/quote_collection.dart';
import '../../../../data/models/quote_model.dart';

part 'collection_viewmodel.g.dart';

@riverpod
class CollectionViewModel extends _$CollectionViewModel {
  final _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;

  @override
  Stream<List<QuoteCollection>> build() {
    final user = ref.watch(authStateProvider.select((v) => v.valueOrNull));

    if (user != null) {
      return _firestoreService.getCollections(user.uid);
    }
    return Stream.value([]);
  }

  Future<void> createCollection(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestoreService.createCollection(user.uid, name);
    }
  }

  Future<void> deleteCollection(String collectionId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestoreService.deleteCollection(user.uid, collectionId);
    }
  }

  Future<void> addQuoteToCollection(String collectionId, Quote quote) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestoreService.addQuoteToCollection(
        user.uid,
        collectionId,
        quote,
      );
    }
  }

  Future<void> removeQuoteFromCollection(
    String collectionId,
    Quote quote,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestoreService.removeQuoteFromCollection(
        user.uid,
        collectionId,
        quote,
      );
    }
  }
}
