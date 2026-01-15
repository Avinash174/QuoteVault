// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuoteImpl _$$QuoteImplFromJson(Map<String, dynamic> json) => _$QuoteImpl(
  text: json['quote'] as String,
  author: json['author'] as String,
  work: json['work'] as String? ?? '',
  category: json['category'] as String? ?? '',
);

Map<String, dynamic> _$$QuoteImplToJson(_$QuoteImpl instance) =>
    <String, dynamic>{
      'quote': instance.text,
      'author': instance.author,
      'work': instance.work,
      'category': instance.category,
    };
