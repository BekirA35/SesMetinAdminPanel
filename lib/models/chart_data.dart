class ChartDataPoint {
  final String date;
  final int count;

  ChartDataPoint({
    required this.date,
    required this.count,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  DateTime get dateTime => DateTime.parse(date);
}

class ChartDataResponse {
  final bool success;
  final String message;
  final List<ChartDataPoint> userRegistrations;
  final List<ChartDataPoint> recordCreations;

  ChartDataResponse({
    required this.success,
    required this.message,
    required this.userRegistrations,
    required this.recordCreations,
  });

  factory ChartDataResponse.fromJson(Map<String, dynamic> json) {
    return ChartDataResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userRegistrations: (json['userRegistrations'] as List<dynamic>?)
              ?.map((d) => ChartDataPoint.fromJson(d))
              .toList() ??
          [],
      recordCreations: (json['recordCreations'] as List<dynamic>?)
              ?.map((d) => ChartDataPoint.fromJson(d))
              .toList() ??
          [],
    );
  }
}

