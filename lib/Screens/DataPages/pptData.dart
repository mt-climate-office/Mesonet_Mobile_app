// ignore_for_file: non_constant_identifier_names, camel_case_types

class pptData {
  String station;
  double? ninetyDayPPT;
  double? thirtyDayPPT;
  double YTDPPT;
  double fourteenDayPPT;
  double sevenDayPPT;
  double twentyFourHourPPT;
  double PPTsinceMidnight;

  pptData({
    required this.station,
    required this.ninetyDayPPT,
    required this.thirtyDayPPT,
    required this.YTDPPT,
    required this.fourteenDayPPT,
    required this.sevenDayPPT,
    required this.twentyFourHourPPT,
    required this.PPTsinceMidnight,
  });

  factory pptData.fromJson(Map<String,dynamic> json) {
    return pptData(
      station: json['station'],
      ninetyDayPPT: json['90-day Precipitation [in]'] ?? 0.0,
      thirtyDayPPT: json['30-day Precipitation [in]']  ?? 0.0,
      YTDPPT: json['Year to Date Precipitation [in]'] ?? 0.0,
      fourteenDayPPT: json['14-day Precipitation [in]'] ?? 0.0,
      sevenDayPPT: json['7-day Precipitation [in]'] ?? 0.0,
      twentyFourHourPPT: json['24-hour Precipitation [in]'] ?? 0.0,
      PPTsinceMidnight: json['Precipitation Since Midnight [in]'] ?? 0.0,
    );
  }
}