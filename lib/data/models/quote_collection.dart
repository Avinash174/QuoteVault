import 'package:freezed_annotation/freezed_annotation.dart';
import 'quote_model.dart';

part 'quote_collection.g.dart';
part 'quote_collection.freezed.dart';

@freezed
class QuoteCollection with _$QuoteCollection {
  const factory QuoteCollection({
    required String id,
    required String name,
    @Default([]) List<Quote> quotes,
    DateTime? createdAt,
  }) = _QuoteCollection;

  factory QuoteCollection.fromJson(Map<String, dynamic> json) =>
      _$QuoteCollectionFromJson(json);
}
