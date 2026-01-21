import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/auth_provider.dart';
import '../../../../data/models/quote_model.dart';
import '../../../../core/services/firestore_service.dart';

part 'library_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class LibraryViewModel extends _$LibraryViewModel {
  final _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;

  StreamSubscription<List<Quote>>? _subscription;

  @override
  List<Quote> build() {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    _subscription?.cancel();
    if (user != null) {
      _subscription = _firestoreService.getFavorites(user.uid).listen((
        favorites,
      ) {
        state = favorites;
      });
    } else {
      state = [];
    }

    ref.onDispose(() => _subscription?.cancel());
    return [];
  }

  Future<void> toggleFavorite(Quote quote) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Authenticated: Sync with Firestore
      if (isFavorite(quote)) {
        // Optimistic update handled by stream? No, stream is async.
        // Let's rely on the stream to update the state to keep single source of truth,
        // OR update local state optimistically.
        // For responsive UI, optimistic is better, but simple stream is safer.
        // Let's just fire and forget the service call, the stream will update the UI.
        await _firestoreService.removeFavorite(user.uid, quote);
      } else {
        await _firestoreService.addFavorite(user.uid, quote);
      }
    } else {
      // Guest: Keep local state only
      if (state.contains(quote)) {
        state = state.where((q) => q != quote).toList();
      } else {
        state = [...state, quote];
      }
    }
  }

  bool isFavorite(Quote quote) {
    // Need custom equality check? Quote is freezed, so == works if fields match.
    // However, if Firestore adds fields (like savedAt), equality might break if not handled?
    // FirestoreService returns Quote objects via fromJson.
    // If the input 'quote' is from API, it doesn't have 'savedAt'.
    // If 'state' quotes have 'savedAt' (dropped by fromJson? No, fromJson ignores extra fields usually).
    // Let's assume standard freezed equality works.
    return state.any((q) => q.text == quote.text && q.author == quote.author);
  }
}
