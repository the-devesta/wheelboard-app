/// Employer job statistics (`GET /jobs/my-jobs/stats`).
/// Mirrors `JobStatsDto` in `wheelboard-be/src/dto/job.dto.ts`.
class JobStats {
  final int totalJobs;
  final int activeJobs;
  final int pausedJobs;
  final int closedJobs;
  final int totalApplications;
  final int pendingApplications;
  final int hiredCount;

  const JobStats({
    this.totalJobs = 0,
    this.activeJobs = 0,
    this.pausedJobs = 0,
    this.closedJobs = 0,
    this.totalApplications = 0,
    this.pendingApplications = 0,
    this.hiredCount = 0,
  });

  factory JobStats.fromJson(Map<String, dynamic> json) {
    return JobStats(
      totalJobs: (json['totalJobs'] as num?)?.toInt() ?? 0,
      activeJobs: (json['activeJobs'] as num?)?.toInt() ?? 0,
      pausedJobs: (json['pausedJobs'] as num?)?.toInt() ?? 0,
      closedJobs: (json['closedJobs'] as num?)?.toInt() ?? 0,
      totalApplications: (json['totalApplications'] as num?)?.toInt() ?? 0,
      pendingApplications: (json['pendingApplications'] as num?)?.toInt() ?? 0,
      hiredCount: (json['hiredCount'] as num?)?.toInt() ?? 0,
    );
  }
}
