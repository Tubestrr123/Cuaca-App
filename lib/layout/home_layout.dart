
// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yusufmuadz_dri_weather/lainnya/variable_semua.dart';

import '../controller/koneksi.dart';
import '../lainnya/warna.dart';
import 'detail_weather_layout.dart';
import 'maps_layout.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {

  bool isLoading = false;
  String nama_kota = 'Semarang';

  Map<String, dynamic> dataCuaca = {
    "data": {
      "values": {
        "temperature": 0,
        "windSpeed": 0,
        "humidity": 0,
      }
    }
  };

  List<dynamic> listNotifikasi = [
    {
      'status': 'new',
      'cuaca': [
        {
          'icon': 'matahari.png',
          'waktu': '00:10:00, 08-05-2025',
          'keterangan': 'A sunny day in your location, consider wearing your UV protection',
        },
      ]
    },
    {
      'status': 'earlier',
      'cuaca': [
        {
          'icon': 'angin_warna.png',
          'waktu': '00:10:00, 08-04-2025',
          'keterangan': "A cloudy day will occur all day long, don't worry about the heat of the sun",
        },
        {
          'icon': 'awan_hujan.png',
          'waktu': '00:10:00, 08-03-2025',
          'keterangan': "Potential for rain today is 84%, don't forget to bring your umbrella.",
        },
      ]
    },
  ];

  getNamaKota() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      nama_kota = prefs.getString('kota')!;
      getDataCuaca();
    });
  }

  @override
  void initState() {
    super.initState();
    getNamaKota();
  }

  getDataCuaca() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    
    try {
      var res = await Connect().dataUrl(sharedPreferences.getString('kota')!);
      var body = json.decode(res.body);
      
      if (body != null) {
        setState(() {
          dataCuaca = body;
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

  popUpNotifikasi() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.2), // semi transparent overlay
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.8,
              minChildSize: 0.2,
              builder: (context, scrollController) {
                return Container(
                  height: mediaQuery(context).height - 300,
                  width: mediaQuery(context).width,
                  padding: EdgeInsets.only(top: 20, bottom: 15),
                  decoration: BoxDecoration(
                    color: warnaPutih,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 2,
                          width: 36,
                          decoration: BoxDecoration(
                            color: warnaBlueGray,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 37, right: 20, left: 20),
                        child: Text('Your Notification', style: TextStyle(color: warnaText, fontSize: 24, fontWeight: FontWeight.w800, shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4.0,
                            color: Colors.black26, // Bayangan lembut
                          ),
                          ])
                        ),
                      ),
                      SizedBox(height: 9),
                      Expanded(
                        child: ListView.builder(
                          itemCount: listNotifikasi.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 9, bottom: 20),
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20, left: 20),
                                    child: Text(capitalText(listNotifikasi[index]['status']), style: TextStyle(color: index == 0 ? warnaText : warnaBlueGray, fontSize: 12, fontWeight: FontWeight.w400)),
                                  ),
                                  SizedBox(height: 8),
                                  ListView.builder(
                                    itemCount: listNotifikasi[index]['cuaca'].length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, indexCuaca) {
                                      return Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.fromLTRB(20, 18, 20, 18),
                                        color: index == 0 ? warnaBackgroundNotif : Colors.transparent,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              margin: EdgeInsets.only(right: 10),
                                              padding: EdgeInsets.only(right: 5),
                                              child: Center(child: Image.asset('$url_gambar_icon/${listNotifikasi[index]['cuaca'][indexCuaca]['icon']}', height: 20, width: 20, fit: BoxFit.cover))
                                            ),
                                            Expanded(
                                              child: RichText(
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
                                                text: TextSpan(
                                                  text: '10 minutes ago\n',
                                                  style: TextStyle(height: 3, color: index == 0 ? warnaText : warnaBlueGray, fontSize: 12, fontWeight: FontWeight.w300),
                                                  children: [
                                                    TextSpan(
                                                      text: listNotifikasi[index]['cuaca'][indexCuaca]['keterangan'],
                                                      style: TextStyle(height: 1.4, color: index == 0 ? warnaText : warnaBlueGray, fontSize: 14, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                              child: Center(child: Image.asset('$url_gambar_icon/${ index == 0 ? 'panah_bawah_warna.png' : 'panah_bawah_blue_gray.png'}', height: 13, width: 13))
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ],
        );
      },
    );
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
            top: 20,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MapsLayout()));
                        },
                        child: Container(
                          width: mediaQuery(context).width - 100,
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: '',
                              children: [
                                WidgetSpan(
                                  child: Icon(Icons.location_on_outlined, size: 24, color: Colors.white),
                                ),
                                TextSpan(
                                  text: '   ${nama_kota.replaceAll('Kabupaten', 'Kab.').replaceAll('kabupaten', 'Kab.').replaceAll('Kepulauan', 'Kep.').replaceAll('kepulauan', 'Kep.')}   ',
                                  style: TextStyle(fontFamily: 'Overpass', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(-2.3, 2.8),
                                        blurRadius: 10.0,
                                        color: Colors.black.withOpacity(0.190),
                                      ),
                                    ]
                                  ),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.top,
                                  child: Image.asset('$url_gambar_icon/panah_bawah_putih.png', height: 6, width: 9, fit: BoxFit.cover),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => popUpNotifikasi(),
                        child: Stack(
                          children: [
                            Image.asset('$url_gambar_icon/notifikasi.png', height: 22, width: 18, fit: BoxFit.cover),
                            Positioned(
                              top: 0,
                              right: -2,
                              child: Visibility(
                                visible: true,
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(width: 2, color: warnaBadgeBorder),
                                    color: Colors.red,
                                  ),
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Image.asset(gambarCuaca(dataCuaca["data"]["values"]["weatherCode"] ?? 0), height: 165, width: 165, fit: BoxFit.cover),
                  SizedBox(height: 20),
                  GradientBorderContainer(
                    borderGradient: LinearGradient(colors: [warnaPutih30, warnaPutih30]),
                    radius: 20.0,
                    borderWidth: 3.0,
                    contentPadding: EdgeInsets.all(20),
                    content: Column(
                      children: [
                        Text(
                          'Today, ${DateTime.now().day} ${DateFormat('MMMM').format(DateTime.now())}',
                          style: TextStyle(fontFamily: 'Overpass', color: warnaPutih, fontSize: 18, fontWeight: FontWeight.w400,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(-4.0, 2.0),
                                blurRadius: 5.0,
                                color: Colors.black.withOpacity(0.190),
                              ),
                            ]
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Visibility(
                            visible: dataCuaca.isNotEmpty,
                            child: Text(
                              '${dataCuaca["data"]["values"]["temperature"]}°',
                              style: TextStyle(color: warnaPutih, fontSize: 72, fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(
                                    blurRadius: 30,
                                    color: Colors.black.withOpacity(0.2),
                                    offset: Offset(0, 10),
                                  ),
                                ]
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          keteranganCuaca(dataCuaca["data"]["values"]["weatherCode"] ?? 0),
                          style: TextStyle(fontFamily: 'Overpass', color: warnaPutih, fontSize: 24, fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(-2.3, 2.8),
                                blurRadius: 6.0,
                                color: Colors.black.withOpacity(0.190),
                              ),
                            ]
                          ),
                        ),
                        SizedBox(height: 25),
                        Visibility(
                          visible: dataCuaca.isNotEmpty,
                          child: rowInfoCuaca('angin_putih.png', 'Wind', '${dataCuaca["data"]["values"]["windSpeed"]} km/h'),
                        ),
                        SizedBox(height: 10),
                        Visibility(
                          visible: dataCuaca.isNotEmpty,
                          child: rowInfoCuaca('air.png', 'Hum', '${dataCuaca["data"]["values"]["humidity"]}%'),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Material(
                    elevation: 5,
                    shadowColor: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailWeatherLayout()));
                      },
                      child: Container(
                        height: 60,
                        width: 220,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Weather Details   ',
                            style: TextStyle(fontFamily: 'Overpass', fontSize: 18, fontWeight: FontWeight.w400, color: warnaText),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Image.asset('$url_gambar_icon/panah_kanan.png', height: 12, width: 12),
                              ),
                            ],
                          ),
                        )
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

String capitalText(String text) {
  return text.split(' ').map((kata) {
    if (kata.isEmpty) return kata;
    return kata[0].toUpperCase() + kata.substring(1).toLowerCase();
  }).join(' ');
}


rowInfoCuaca(String icon, String text, String kecepatan) {
  return SizedBox(
    width: 200,
    child: Row(
      children: [
        Image.asset('$url_gambar_icon/$icon', height: 20, width: 20, fit: BoxFit.cover),
        SizedBox(width: 20),
        SizedBox(
          width: 40,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Overpass', color: warnaPutih, fontSize: 16, fontWeight: FontWeight.w400,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(-2.3, 2.8),
                  blurRadius: 6.0,
                  color: Colors.black.withOpacity(0.190),
                ),
              ]
            ),
          ),
        ),
        Container(
          height: 21,
          width: 1,
          margin: EdgeInsets.only(right: 22, left: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: Offset(-2.3, 2.8),
                blurRadius: 6.0,
                color: Colors.black.withOpacity(0.190),
              ),
            ],
            color: warnaPutih,
          )
        ),
        SizedBox(
          width: 70,
          child: Text(
            kecepatan,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Overpass', color: warnaPutih, fontSize: 16, fontWeight: FontWeight.w400,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(-2.3, 2.8),
                  blurRadius: 6.0,
                  color: Colors.black.withOpacity(0.190),
                ),
              ]
            ),
          ),
        ),
      ],
    ),
  );
}

class GradientBorderContainer extends StatelessWidget {
  final Widget content; // The widget inside the container
  final double radius; // Radius of the border's corners
  final double borderWidth; // Width of the border
  final Gradient borderGradient; // The gradient applied to the border
  final EdgeInsetsGeometry? margin; // Margin around the container
  final EdgeInsetsGeometry? contentPadding; // Padding inside the content
  const GradientBorderContainer({
    required this.content,
    required this.borderGradient,
    super.key,
    this.radius = 0.0,
    this.borderWidth = 1.0,
    this.margin,
    this.contentPadding,
  });
  @override
  Widget build(final BuildContext context) {
    return Container(
      width: mediaQuery(context).width,
      margin: margin, // Apply margin if provided
      padding: const EdgeInsets.all(2), // Add padding for the border to show
      decoration: BoxDecoration(
        gradient: borderGradient, // Apply gradient to the border
        borderRadius: _getBorderRadius(), // Round the corners based on radius
      ),
      child: Container(
        padding: contentPadding, // Padding for the content inside the container
        decoration: BoxDecoration(
          color: warnaPutih30, // Background color for the content area
          borderRadius: _getBorderRadius(), // Round corners for content as well
        ),
        child: content, // The content widget (could be anything)
      ),
    );
  }
  // Helper function to return border radius based on the 'radius' property
  BorderRadius _getBorderRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
    );
  }
}
