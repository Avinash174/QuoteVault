// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuoteCollectionImpl _$$QuoteCollectionImplFromJson(
  Map<String, dynamic> json,
) => _$QuoteCollectionImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  quotes:
      (json['quotes'] as List<dynamic>?)
          ?.map((e) => Quote.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$QuoteCollectionImplToJson(
  _$QuoteCollectionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'quotes': instance.quotes,
  'createdAt': instance.createdAt?.toIso8601String(),
};
