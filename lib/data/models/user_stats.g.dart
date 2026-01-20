// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      quotesReadToday: (json['quotesReadToday'] as num?)?.toInt() ?? 0,
      dailyGoal: (json['dailyGoal'] as num?)?.toInt() ?? 10,
      lastActiveDate: json['lastActiveDate'] == null
          ? null
          : DateTime.parse(json['lastActiveDate'] as String),
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'streak': instance.streak,
      'quotesReadToday': instance.quotesReadToday,
      'dailyGoal': instance.dailyGoal,
      'lastActiveDate': instance.lastActiveDate?.toIso8601String(),
    };
