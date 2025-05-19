
// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../object/objCuaca.dart';

class Connect {
  var apiUrl = 'https://api.tomorrow.io/v4/weather/';
  var key = 'TURSXOHsvqKxFEbuZvQI3AgQEFU59J8W';

  dataUrl(String url) async {
    var fullUrl = '$apiUrl/realtime?location=$url&apikey=$key';

    var response = await http.get(Uri.parse(fullUrl), headers: {'Content-type': 'application/json', 'Accept': 'application/json'});

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }

  Future<List<DataCuaca>>cuacaPerhari(String latlng) async {
    var fullUrl = '$apiUrl/forecast?location=$latlng&apikey=$key';

    final response = await http.get(Uri.parse(fullUrl), headers: {'Content-type': 'application/json', 'Accept': 'application/json'});

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final listDaily = data['timelines']['daily'] as List;

      return listDaily.map((e) => DataCuaca.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }

  Future<List<DataCuacaPerJam>>cuacaPerjam(String latlng) async {
    DateTime now = DateTime.now().toLocal();
    var fullUrl = '$apiUrl/forecast?location=$latlng&timesteps=1h&startTime=now-2h&endTime=now+2h&apikey=$key';

    final response = await http.get(Uri.parse(fullUrl), headers: {'Content-type': 'application/json', 'Accept': 'application/json'});

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final listDaily = data['timelines']['hourly'] as List;

      List<DataCuacaPerJam> filter = listDaily.map((e) => DataCuacaPerJam.fromJson(e)).toList();

      print('Response : $filter');

      return filter.where((e) => e.time.isAfter(now.subtract(Duration(hours: 2))) && e.time.isBefore(now.add(Duration(hours: 2)))).toList();
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }
}