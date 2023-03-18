import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:weather/models/weather_result.dart';
import 'package:weather/state/state.dart';
import 'package:weather/utils/utils.dart';
import 'package:weather/widgets/fore_cast_tile_widget.dart';
import 'package:weather/widgets/info_widget.dart';
import 'package:weather/widgets/weather_tile_widget.dart';

import 'const/color.dart';
import 'models/forcast_result.dart';
import 'network/open_weather_client_map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //     SystemUiOverlayStyle(statusBarColor: Color(colorBg1)));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = Get.put(MyStateController());
  var location = Location();
  late StreamSubscription listener;
  late PermissionStatus permissionStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      await enableLocationListener();
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Obx(() => Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      tileMode: TileMode.clamp,
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                    Color(colorBg1),
                    Color(colorBg2),
                  ])),
              child: controller.locationData.value != null
                  ? FutureBuilder(
                      future: OpenWeatherMapClient()
                          .getWeather(controller.locationData.value),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              snapshot.error.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return Center(
                            child: Text(
                              "No Data",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          var data = snapshot.data as WeatherResult;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 20,
                              ),
                              WeatherTileWidget(
                                context: context,
                                title: (data.name != null &&
                                        data.name!.isNotEmpty)
                                    ? data.name
                                    : '${data.coord!.lat}/${data.coord!.lon}',
                                titleFontSize: 30.0,
                                subTitle: DateFormat('dd-MMM-yyyy').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (data.dt ?? 0) * 1000)),
                              ),
                              Center(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      BuildIcon(data.weather![0]!.icon ?? ''),
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.fill,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(),
                                  errorWidget: (context, url, err) => Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              WeatherTileWidget(
                                context: context,
                                title: '${data.main!.temp}°C',
                                titleFontSize: 60.0,
                                subTitle: '${data.weather![0]!.description}',
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                  ),
                                  InfoWidget(
                                      icon: FontAwesomeIcons.wind,
                                      text: '${data.wind!.speed}'),
                                  InfoWidget(
                                      icon: FontAwesomeIcons.cloud,
                                      text: '${data.clouds!.all}'),
                                  InfoWidget(
                                      icon: FontAwesomeIcons.snowflake,
                                      text: data.snow != null
                                          ? '${data.snow!.d1h}'
                                          : '0'),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Expanded(
                                  child: FutureBuilder(
                                      future: OpenWeatherMapClient()
                                          .getForecast(
                                              controller.locationData.value),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                              snapshot.error.toString(),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        } else if (!snapshot.hasData) {
                                          return Center(
                                            child: Text(
                                              "No Data",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        } else {
                                          var data =
                                              snapshot.data as ForecastResult;
                                          return ListView.builder(
                                            itemCount: data.list!.length ?? 0,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              var item = data.list![index];
                                              return ForeCastTileWidget(
                                                imageUrl: BuildIcon(item!.weather![0]!.icon ?? '',isBigSize: false),
                                                  temp: '${item.main!.temp}°C',
                                                  time: DateFormat('HH:mm')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              (item.dt ?? 0) *
                                                                  1000)));
                                            },
                                          );
                                        }
                                      }))
                            ],
                          );
                        }
                      })
                  : Center(
                      child: Text('Waiting...',
                          style: TextStyle(color: Colors.white)),
                    )))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          controller.locationData.value = await location.getLocation();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  Future<void> enableLocationListener() async {
    controller.isenableLocation.value = await location.serviceEnabled();
    if (!controller.isenableLocation.value) {
      controller.isenableLocation.value = await location.requestService();
      if (!controller.isenableLocation.value) {
        return;
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    controller.locationData.value = await location.getLocation();
    listener = location.onLocationChanged.listen((event) {
      /*
      Because we use location to request data, So we just need get last location
       */
    });
  }
}
