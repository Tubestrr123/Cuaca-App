
class DataCuaca {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DataCuaca({required this.date, required this.maxTemp, required this.minTemp, required this.weatherCode});

  factory DataCuaca.fromJson(Map<String, dynamic> json) {
    return DataCuaca(
      date: DateTime.parse(json['time']).toLocal(),
      maxTemp: json['values']['temperatureMax'].toDouble(),
      minTemp: json['values']['temperatureMin'].toDouble(),
      weatherCode: json['values']['weatherCodeMax'],
    );
  }
}

class DataCuacaPerJam {
  final DateTime time;
  final double temperature;
  final int weatherCode;

  DataCuacaPerJam({required this.time, required this.temperature, required this.weatherCode});

  factory DataCuacaPerJam.fromJson(Map<String, dynamic> json) {
    return DataCuacaPerJam(
      time: DateTime.parse(json['time']).toLocal(),
      temperature: json['values']['temperature'].toDouble(),
      weatherCode: json['values']['weatherCode'],
    );
  }
}