import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dashboard_stats_provider.g.dart';

/// Stats data for the dashboard overview
class DashboardStats {
  final int totalTemplates;
  final int activeTemplates;
  final int premiumTemplates;
  final int categoriesCount;
  final List<Map<String, dynamic>> recentTemplates;

  const DashboardStats({
    required this.totalTemplates,
    required this.activeTemplates,
    required this.premiumTemplates,
    required this.categoriesCount,
    required this.recentTemplates,
  });
}

@riverpod
Future<DashboardStats> dashboardStats(Ref ref) async {
  final supabase = Supabase.instance.client;

  // Fetch all templates (admin has full access)
  final allTemplates = await supabase
      .from('templates')
      .select('id, name, category, is_active, is_premium, updated_at, thumbnail_url')
      .order('updated_at', ascending: false);

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
