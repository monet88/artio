/// Aggregated analytics data built from profiles + generation_jobs.
class AnalyticsStats {
  const AnalyticsStats({
    required this.totalUsers,
    required this.totalJobs,
    required this.premiumUsers,
    required this.jobsToday,
    required this.dailyJobs,
    required this.topModels,
  });

  final int totalUsers;
  final int totalJobs;
  final int premiumUsers;
  final int jobsToday;

  /// Jobs per day for the last 7 days, oldest first.
  final List<DailyCount> dailyJobs;

  /// Top 5 models by job count in the last 7 days, sorted descending.
  final List<ModelCount> topModels;

  /// Derived: users without a premium subscription.
  int get freeUsers => totalUsers - premiumUsers;
}

/// One day's generation job count.
class DailyCount {
  const DailyCount({required this.date, required this.count});

  final DateTime date;
  final int count;
}

/// Usage count for a single AI model.
class ModelCount {
  const ModelCount({required this.model, required this.count});

  final String model;
  final int count;
}
