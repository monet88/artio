// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) int totalTemplates,
    @Default(0) int activeTemplates,
    @Default(0) int premiumTemplates,
    @Default(0) int categoriesCount,
    @Default([]) List<Map<String, dynamic>> recentTemplates,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}
