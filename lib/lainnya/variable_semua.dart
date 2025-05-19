
// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';

import 'warna.dart';

// Url Gambar
String url_gambar = 'assets/images';
String url_gambar_background = 'assets/images/backgrounds';
String url_gambar_icon = 'assets/images/icons';

// MediaQuery

mediaQuery(BuildContext context) {
  return MediaQuery.of(context).size;
}

// Shadow Text

shadowText(double blurRadius, double offsetKananKiri, double offsetAtasBawah) {
  return [Shadow(
    offset: Offset(offsetKananKiri, offsetAtasBawah),
    blurRadius: 10.0,
    color: Colors.black.withOpacity(0.190),
  )];
}

// Loading

loadingLayout() {
  return Center(
    child: CircularProgressIndicator(
      color: warnaText,
    ),
  );
}

// Teks Cuaca

String keteranganCuaca(int code) {
  switch (code) {
    case 1000:
      return "Cerah";
    case 1100:
      return "Cerah Berawan";
    case 1101:
      return "Sebagian Berawan";
    case 1102:
      return "Berawan";
    case 1001:
      return "Mendung";
    case 2000:
      return "Berkabut";
    case 2100:
      return "Kabut Ringan";
    case 4000:
      return "Gerimis";
    case 4001:
      return "Hujan";
    case 4200:
      return "Hujan Ringan";
    case 4201:
      return "Hujan Lebat";
    case 5000:
      return "Salju";
    case 5100:
      return "Salju Ringan";
    case 5101:
      return "Salju Lebat";
    default:
      return "Tidak diketahui";
  }
}

// Gambar Cuaca

String gambarCuaca(int code) {
  switch (code) {
    case 1000:
      return "assets/images/sunny.png";
    case 1001:
      return "assets/images/cloudy.png";
    case 4001:
      return "assets/images/rain.png";
    case 4201:
      return "assets/images/petir.png";
    default:
      return "assets/images/awan_matahari.png";
  }
}
