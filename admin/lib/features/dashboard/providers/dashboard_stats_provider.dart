import 'package:artio_admin/core/utils/retry.dart';
import 'package:artio_admin/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dashboard_stats_provider.g.dart';

@riverpod
Future<DashboardStats> dashboardStats(Ref ref) async {
  final supabase = Supabase.instance.client;

  // Wrap with retry for network resilience
  final allTemplates = await retry(() => supabase
      .from('templates')
      .select('id, name, category, is_active, is_premium, updated_at, thumbnail_url')
      .order('updated_at', ascending: false));

  final list = allTemplates as List;
  final total = list.length;
  final active = list.where((t) => t['is_active'] == true).length;
  final premium = list.where((t) => t['is_premium'] == true).length;
  final categories = list.map((t) => t['category']).toSet().length;
  final recent = list.take(5).toList().cast<Map<String, dynamic>>();

  return DashboardStats(
    totalTemplates: total,
    activeTemplates: active,
    premiumTemplates: premium,
    categoriesCount: categories,
    recentTemplates: recent,
  );
}
