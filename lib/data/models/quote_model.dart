import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_model.freezed.dart';
part 'quote_model.g.dart';

@freezed
class Quote with _$Quote {
  const factory Quote({
    @JsonKey(name: 'quote') required String text,
    required String author,
    @Default('') String work,
    @Default([]) List<String> categories,
    String? id, // Firestore Document ID
    String? userId, // Creator's UID
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}
