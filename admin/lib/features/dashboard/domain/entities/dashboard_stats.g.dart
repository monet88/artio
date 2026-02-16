// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      totalTemplates: (json['totalTemplates'] as num?)?.toInt() ?? 0,
      activeTemplates: (json['activeTemplates'] as num?)?.toInt() ?? 0,
      premiumTemplates: (json['premiumTemplates'] as num?)?.toInt() ?? 0,
      categoriesCount: (json['categoriesCount'] as num?)?.toInt() ?? 0,
      recentTemplates:
          (json['recentTemplates'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
  _$DashboardStatsImpl instance,
) => <String, dynamic>{
  'totalTemplates': instance.totalTemplates,
  'activeTemplates': instance.activeTemplates,
  'premiumTemplates': instance.premiumTemplates,
  'categoriesCount': instance.categoriesCount,
  'recentTemplates': instance.recentTemplates,
};
