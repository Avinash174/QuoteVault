// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuoteImpl _$$QuoteImplFromJson(Map<String, dynamic> json) => _$QuoteImpl(
  text: json['quote'] as String,
  author: json['author'] as String,
  work: json['work'] as String? ?? '',
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  id: json['id'] as String?,
  userId: json['userId'] as String?,
);

Map<String, dynamic> _$$QuoteImplToJson(_$QuoteImpl instance) =>
    <String, dynamic>{
      'quote': instance.text,
      'author': instance.author,
      'work': instance.work,
      'categories': instance.categories,
      'id': instance.id,
      'userId': instance.userId,
    };
