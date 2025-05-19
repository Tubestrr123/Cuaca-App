// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusufmuadz_dri_weather/lainnya/variable_semua.dart';

import 'lainnya/warna.dart';
import 'layout/home_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yusuf Muadz - Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool isLoading = false;

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;
      SharedPreferences prefs = await SharedPreferences.getInstance();

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
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          prefs.setDouble('latitude', position.latitude);
          prefs.setDouble('longitude', position.longitude);
          prefs.setString('kota', placemarks[0].subAdministrativeArea!);
          prefs.setString('masuk', 'iya');

          isLoading = false;
        });
        
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeLayout()));
      }
    } catch (e) {
      print('Error: $e'); 
    }
    setState(() {
      isLoading = false;
    });
  }

  checkMasuk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? masuk = prefs.getString('masuk');
    if (masuk == 'iya') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeLayout()));
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
    ));
    checkMasuk();
  }

  @override
  void dispose() {
    super.dispose();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('$url_gambar_background/onboard.png', height: double.infinity, width: double.infinity, fit: BoxFit.cover),
          Positioned(
            left: 0,
            right: 0,
            bottom: 97,
            child: SizedBox(
              height: 300,
              width: 306,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Never get caught\nin the rain again',
                    style: TextStyle(fontFamily: 'Overpass', color: warnaText, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 9),
                  SizedBox(
                    width: 306,
                    child: Text(
                      'Stay ahead of the weather with our accurate forecasts',
                      style: TextStyle(fontFamily: 'Overpass', color: warnaText, fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(height: 28),
                  InkWell(
                    onTap: isLoading ? null : () {
                      setState(() {
                        isLoading = true;
                        getCurrentLocation();
                      });
                    },
                    child: Container(
                      height: 60,
                      width: 306,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isLoading ? warnaBadgeBorder : warnaPutih,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: Offset(0, 0),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(-4, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        isLoading ? 'Loading...' : 'Get Started',
                        style: TextStyle(fontFamily: 'Overpass', fontSize: 18, fontWeight: FontWeight.w400, color: isLoading ? warnaPutih : warnaText),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
}
