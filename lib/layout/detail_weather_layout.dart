


// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusufmuadz_dri_weather/lainnya/variable_semua.dart';
import 'package:yusufmuadz_dri_weather/lainnya/warna.dart';

import '../controller/koneksi.dart';
import '../object/objCuaca.dart';

class DetailWeatherLayout extends StatefulWidget {
  const DetailWeatherLayout({super.key});

  @override
  State<DetailWeatherLayout> createState() => _DetailWeatherLayoutState();
}

class _DetailWeatherLayoutState extends State<DetailWeatherLayout> {

  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  double _position = 0.0;

  List<DataCuaca> dataCuacaPerhari = [];
  List<DataCuacaPerJam> dataCuacaPerjam = [];

  @override
  initState() {
    super.initState();
    getDataCuaca();
    _scrollController.addListener(() {
      final scrollExtent = _scrollController.position.maxScrollExtent;
      final viewHeight = _scrollController.position.viewportDimension;

      setState(() {
        _position = (_scrollController.offset / scrollExtent) * (viewHeight - 130);
      });
    });
  }

  getDataCuaca() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    
    try {
      String latlng = '${sharedPreferences.getDouble('latitude')},${sharedPreferences.getDouble('longitude')}';
      var res_dataDaily = await Connect().cuacaPerhari(latlng);
      var res_dataHour = await Connect().cuacaPerjam(latlng);
      
      if (res_dataDaily.isNotEmpty || res_dataHour.isNotEmpty) {
        setState(() {
          dataCuacaPerhari = res_dataDaily;
          dataCuacaPerjam = res_dataHour;
          print('Data Cuaca Perjam: $dataCuacaPerjam');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koneksi Gagal')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? loadingLayout() :
      Stack(
        children: [
          Image.asset(
            '$url_gambar_background/Home.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 45,
            bottom: 20,
            right: 0,
            left: 0,
            child: SizedBox(
              height: mediaQuery(context).height,
              width: mediaQuery(context).width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Image.asset('$url_gambar_icon/panah_kanan_putih.png', height: 17, width: 17),
                          const SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              // fontFamily: 'Overpass',
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              shadows: shadowText(10, -2.3, 2.8)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 39),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today',
                          style: TextStyle(
                            fontFamily: 'Overpass',
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            shadows: shadowText(5, -2.3, 2.8)
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('MMM, dd').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            shadows: shadowText(5, -2.3, 2.8)
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    height: 150,
                  width: mediaQuery(context).width,
                    child: ListView.builder(
                      itemCount: dataCuacaPerjam.length < 5 ? dataCuacaPerjam.length : 5,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: mediaQuery(context).width / 5,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          decoration: index != 2 ? null : BoxDecoration(
                            border: Border.all(
                              color: warnaPutihSetengah,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: warnaPutihSeperempat,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${dataCuacaPerjam[index].temperature}°C',
                                style: TextStyle(
                                  fontFamily: 'Overpass',
                                  color: warnaPutih,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  shadows: shadowText(10, -3.0, 1.0)
                                ),
                              ),
                              const SizedBox(height: 23),
                              Image.asset(
                                gambarCuaca(dataCuacaPerjam[index].weatherCode),
                                height: 40,
                                width: 40,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                DateFormat('HH.00').format(dataCuacaPerjam[index].time),
                                style: TextStyle(
                                  fontFamily: 'Overpass',
                                  color: warnaPutih,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  shadows: shadowText(10, -3.0, 1.0)
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Next Forecast',
                      style: TextStyle(
                        fontFamily: 'Overpass',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900, // Black
                        shadows: shadowText(10, -2.3, 2.8)
                      ),
                    ),
                  ),
                  const SizedBox(height: 19),
                  Container(
                    height: 260,
                    width: mediaQuery(context).width,
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: Stack(
                      children: [
                        ListView.builder(
                          itemCount: dataCuacaPerhari.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(right: 40),
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              titleAlignment: ListTileTitleAlignment.center,
                              leading: Text(
                                DateFormat('MMM, dd').format(dataCuacaPerhari[index].date),
                                style: TextStyle(
                                  fontFamily: 'Overpass',
                                  color: warnaPutih,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: shadowText(10, -2.3, 2.8)
                                ),
                              ),
                              title: Image.asset(
                                gambarCuaca(dataCuacaPerhari[index].weatherCode),
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                              trailing: Text(
                                '${dataCuacaPerhari[index].maxTemp.toStringAsFixed(0)}°C',
                                style: TextStyle(
                                  fontFamily: 'Overpass',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900, // Black
                                  shadows: shadowText(10, -2.3, 2.8)
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 0,
                          right: 10,
                          bottom: 0,
                          child: Container(
                            width: 6,
                            alignment: Alignment.topCenter,
                            child: Visibility(
                              visible: dataCuacaPerhari.isNotEmpty,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 6,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: warnaPutihSetengah,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      )
                                    ),
                                  ),
                                  Positioned(
                                    top: _position.clamp(0, MediaQuery.of(context).size.height - 130),
                                    child: Container(
                                      width: 6,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                            )
                          )
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('$url_gambar_icon/matahari_putih.png', height: 22, width: 22),
                      const SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          'DRI Weather',
                          style: TextStyle(
                            fontFamily: 'Overpass',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            shadows: shadowText(10, -2.3, 2.8)
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}