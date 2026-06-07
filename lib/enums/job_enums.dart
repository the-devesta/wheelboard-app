/// Enum for Job Role
enum JobRole {
  driver('Driver'),
  technician('Technician'),
  helper('Helper');

  final String value;
  const JobRole(this.value);

  static JobRole fromString(String? value) {
    if (value == null || value.isEmpty) return JobRole.driver;
    switch (value.toLowerCase().trim()) {
      case 'driver':
        return JobRole.driver;
      case 'technician':
        return JobRole.technician;
      case 'helper':
        return JobRole.helper;
      default:
        return JobRole.driver;
    }
  }
}

/// Enum for Job Duration — mirrors FE `CreateJobData.duration` and the backend
/// `CreateJobDto.duration` accepted values.
enum JobDuration {
  permanent('Permanent'),
  taskBased('Task-based'),
  temporary('Temporary');

  final String value;
  const JobDuration(this.value);

  static JobDuration? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    final lowerValue = value.toLowerCase().trim();

    // Try exact match first
    for (var duration in JobDuration.values) {
      if (duration.value.toLowerCase() == lowerValue) {
        return duration;
      }
    }

    // Try partial match
    if (lowerValue.contains('permanent')) {
      return JobDuration.permanent;
    } else if (lowerValue.contains('task')) {
      return JobDuration.taskBased;
    } else if (lowerValue.contains('temp')) {
      return JobDuration.temporary;
    }

    return null;
  }

  static List<String> get allValues =>
      JobDuration.values.map((e) => e.value).toList();
}

/// Enum for Job Type
enum JobType {
  driver('Driver'),
  technician('Technician'),
  helper('Helper');

  final String value;
  const JobType(this.value);

  static JobType? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    final lowerValue = value.toLowerCase().trim();

    // Try exact match first
    for (var type in JobType.values) {
      if (type.value.toLowerCase() == lowerValue) {
        return type;
      }
    }

    // Try partial match
    if (lowerValue.contains('driver')) {
      return JobType.driver;
    } else if (lowerValue.contains('technician')) {
      return JobType.technician;
    } else if (lowerValue.contains('helper')) {
      return JobType.helper;
    }

    return null;
  }

  static List<String> get allValues =>
      JobType.values.map((e) => e.value).toList();
}
