/// A single revenue transaction (subscription or purchase).
class RevenueTransaction {
  const RevenueTransaction({
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.userEmail,
    this.referenceId,
  });

  final String userId;
  final String? userEmail; // null if profile deleted
  final int amount;
  final String type; // 'subscription' | 'purchase'
  final String? referenceId;
  final DateTime createdAt;
}

/// Daily transaction aggregation.
class DailyRevenue {
  const DailyRevenue({
    required this.date,
    required this.transactionCount,
    required this.creditAmount,
  });

  final DateTime date; // UTC
  final int transactionCount;
  final int creditAmount; // total credits granted
}

/// Tier breakdown from profiles table.
class TierBreakdown {
  const TierBreakdown({
    required this.tier,
    required this.count,
    required this.totalUsers,
  });

  final String tier; // null subscription_tier → 'free'
  final int count;
  final int totalUsers;

  /// Guard divide-by-zero when totalUsers = 0.
  double get percentage => totalUsers == 0 ? 0.0 : count / totalUsers;
}

/// Aggregated revenue data for the Revenue page.
class RevenueStats {
  const RevenueStats({
    required this.recentTransactions,
    required this.dailyRevenue,
    required this.tierBreakdown,
  });

  /// Last 50 subscription/purchase transactions, newest first.
  final List<RevenueTransaction> recentTransactions;

  /// 7-day daily breakdown, oldest first, zero-filled.
  final List<DailyRevenue> dailyRevenue;

  /// Tier distribution from profiles.
  final List<TierBreakdown> tierBreakdown;

  int get subscriptionsToday {
    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);
    return recentTransactions
        .where((t) => !t.createdAt.isBefore(todayStart))
        .length;
  }

  int get subscriptionsThisWeek {
    final sevenDaysAgo =
        DateTime.now().toUtc().subtract(const Duration(days: 7));
    return recentTransactions
        .where((t) => t.createdAt.isAfter(sevenDaysAgo))
        .length;
  }

  int get totalPremiumUsers {
    final premiumTier = tierBreakdown
        .where((t) => t.tier != 'free')
        .fold<int>(0, (sum, t) => sum + t.count);
    return premiumTier;
  }
}
