import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_model.freezed.dart';
part 'quote_model.g.dart';

@freezed
class Quote with _$Quote {
  const factory Quote({
    @JsonKey(name: 'quote') required String text,
    required String author,
    @Default('')
    String work, // API Ninjas doesn't strictly have 'work' but we can keep it
    @Default('') String category, // Changed from List<String> categories
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}
