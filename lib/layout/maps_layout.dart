// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusufmuadz_dri_weather/lainnya/warna.dart';
import 'package:http/http.dart' as http;

import '../lainnya/variable_semua.dart';
import 'home_layout.dart';

class MapsLayout extends StatefulWidget {
  @override
  _MapsLayoutState createState() => _MapsLayoutState();
}

class _MapsLayoutState extends State<MapsLayout> {
  bool isLoading = false;
  LatLng? currentPosition;
  TextEditingController kotaController = TextEditingController();

  List<String> listKota = [];

  @override
  void initState() {
    super.initState();
    getLatLng();
  }

  getLatLng() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;

      currentPosition = LatLng(
        prefs.getDouble('latitude') ?? 0.0,
        prefs.getDouble('longitude') ?? 0.0,
      );
      listKota = prefs.getStringList('listKota') ?? [];
      isLoading = false;
    });
  }

  void searchKota(String city) async {
    setState(() {
      isLoading = true;
    });
    try {
      final location = await getLatLngFromCity(city);
      if (location != null) {
        setState(() {
          currentPosition = location;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lokasi tidak ditemukan')),
        );
      }
    } catch (e) {
      print('Error Maps: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> lokasiSaatIni() async {
    setState(() {
      isLoading = true;
    });
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak aktif');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permission lokasi ditolak');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permission lokasi ditolak permanen');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });
    }
  }

  Future<LatLng?> getLatLngFromCity(String cityName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$cityName&format=json&limit=1',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'com.example.yusufmuadz_dri_weather'
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);

        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

        setState(() {
          var check = listKota.where((element) => element == placemarks[0].subAdministrativeArea!).toList();
          
          if (listKota.length >= 3) {
            listKota.removeAt(0);
          }

          if (check.isEmpty) {
            listKota.add(placemarks[0].subAdministrativeArea!);
          }
          print('List Kota: $listKota');
          prefs.setDouble('latitude', lat);
          prefs.setDouble('longitude', lon);
          prefs.setString('kota', placemarks[0].subAdministrativeArea!);
          prefs.setStringList('listKota', listKota);
        });
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeLayout()));
        return false;
      },
      child: Scaffold(
        body: currentPosition == null || isLoading ? loadingLayout() :
          Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: currentPosition!,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: listKota.isNotEmpty ? 320 : 150,
                  padding: EdgeInsets.only(top: 40, bottom: 30, left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: warnaPutih,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: TextFormField(
                          controller: kotaController,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: warnaText
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search here',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: warnaBlueGray
                            ),
                            suffixIcon: InkWell(
                              onTap: () {
                                if (kotaController.text.isNotEmpty) {
                                  searchKota(kotaController.text);
                                }
                              },
                              child: Icon(Icons.search, color: warnaText),
                            ),
                            prefixIcon: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeLayout()));
                              },
                              child: Icon(Icons.arrow_back, color: warnaText),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: warnaBorder,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: listKota.isNotEmpty,
                        child: Container(
                          margin: EdgeInsets.only(top: 30, bottom: 5),
                          child: Text(
                            'Recent search',
                            style: TextStyle(
                              fontFamily: 'Overpass',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: warnaText
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: listKota.isNotEmpty,
                        child: Expanded(
                          child: ListView.builder(
                            itemCount: listKota.length > 3 ? 3 : listKota.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                leading: Image.asset('$url_gambar_icon/jam.png', height: 18, width: 18),
                                title: Text(listKota[index], style: TextStyle(fontFamily: 'Overpass', fontSize: 16, fontWeight: FontWeight.bold, color: warnaText)),
                                onTap: () {
                                  searchKota(listKota[index]);
                                },
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  )
                ),
              )
            ],
          ),
        floatingActionButton: currentPosition == null ? null :
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
            onTap: lokasiSaatIni,
            child: Icon(Icons.my_location),
          ),
        ),
      ),
    );
  }
}
