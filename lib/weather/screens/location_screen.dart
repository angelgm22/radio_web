import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:radio_web/weather/services/weather.dart';
import 'package:flutter/material.dart';
import 'package:radio_web/weather/utilities/constants.dart';
// import 'package:flutter_weather_bg/bg/weather_bg.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'dart:ui' as ui;

class Forecast {
  String time;
  String temp;
  String tempMax;
  String tempMin;
  String description;
  String id;

  Forecast({
    required this.time,
    required this.temp,
    required this.tempMax,
    required this.tempMin,
    required this.description,
    required this.id,
  });
}

class LocationScreen extends StatefulWidget {
  //LocationScreen({this.locationWeather});
  // final locationWeather;
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weather = WeatherModel();
  List<Forecast> forecastList = [];
  int temperature = 0;
  String countryName = "";
  String condition = "";
  String Message = "";
  String descripcion = "";
  String tempMin = "";
  String tempMax = "";
  WeatherType weatherType = WeatherType.sunny;
  bool isLoading = true;
  bool ifexist = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateUI();
  }

  void updateUI() async {
    try {
      var weatherData = await WeatherModel().getLocationWeather();

      var weatherFData = await WeatherModel().getForecastWeather();

      if (weatherData == null) {
        temperature = 0;
        // WeatherIcon='ERROR';
        Message = 'Unable to get Weather data';
        countryName = '';
        return;
      }

      condition = weatherData['weather'][0]['id'].toString();

      double temp = weatherData['main']['temp'].toDouble();

      print(weatherFData.toString());

      for (int i = 0; i < weatherFData['list'].length; i++) {
        Forecast fore = new Forecast(
            time: _epochToTime(
                int.parse(weatherFData['list'][i]['dt'].toString()) * 1000),
            // time: weatherFData['list'][i]['dt'],
            temp: weatherFData['list'][i]['main']['temp'].toStringAsFixed(0),
            tempMax:
                weatherFData['list'][i]['main']['temp_max'].toStringAsFixed(0),
            tempMin:
                weatherFData['list'][i]['main']['temp_min'].toStringAsFixed(0),
            description:
                weatherFData['list'][i]['weather'][0]['description'].toString(),
            id: weatherFData['list'][i]['weather'][0]['id'].toString());
        setState(() {
          forecastList.add(fore);
        });
      }
      var epoch = DateTime.now().toUtc().millisecondsSinceEpoch / 1000;
      String tipo = 'noche';
      int sunset = int.parse(weatherData['sys']['sunset'].toString());
      int sunrise = int.parse(weatherData['sys']['sunrise'].toString());
      if (epoch >= sunrise && epoch <= sunset) {
        tipo = 'dia';
      }
      setState(() {
        temperature = temp.toInt();
        countryName = weatherData['name'];
        descripcion = weatherData['weather'][0]['description'];
        weatherType = weather.getWeatherType(int.parse(condition), tipo);
        isLoading = false;
        ifexist = true;
      });
    } catch (e) {
      ifexist = false;
    }
  }

  String _epochToTime(int Epoch) {
    String time = DateFormat('EEEE HH:00')
        .format(DateTime.fromMillisecondsSinceEpoch(Epoch))
        .toString();

    String time1;
    if (time.contains('Sunday')) {
      time1 = time.replaceAll('Sunday', 'Dom'); //ingo');
    } else if (time.contains('Monday')) {
      time1 = time.replaceAll('Monday', 'Lun'); //es');
    } else if (time.contains('Tuesday')) {
      time1 = time.replaceAll('Tuesday', 'Mar'); // tes');
    } else if (time.contains('Wednesday')) {
      time1 = time.replaceAll('Wednesday', 'Mié'); //rcoles');
    } else if (time.contains('Thursday')) {
      time1 = time.replaceAll('Thursday', 'Jue'); //ves');
    } else if (time.contains('Friday')) {
      time1 = time.replaceAll('Friday', 'Vie'); // rnes');
    } else {
      time1 = time.replaceAll('Saturday', 'Sáb'); //ado');
    }
    //   print('Tiempo $time1');
    return time1;
  }

  String _epochToTimeD(int Epoch) {
    String time = DateFormat('EEEE')
        .format(DateTime.fromMillisecondsSinceEpoch(Epoch))
        .toString();
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final forecast = SingleChildScrollView(
        child: Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
      decoration: new BoxDecoration(
        //  border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: const Color(0xff7c94b6).withOpacity(0.5),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: forecastList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                    forecastList[index].time,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: kMessageTextStyle1,
                  )),
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        Text(
                          weather.getWeatherAsset(
                            int.parse(forecastList[index].id),
                          ),
                          textAlign: TextAlign.center,
                          style: kMessageTextStyle,
                        ),
                        Text(
                          forecastList[index].description,
                          textAlign: TextAlign.center,
                          style: kMessageTextStyle1,
                        )
                      ])),
                  Expanded(
                      child: Text(
                    "${forecastList[index].tempMax}°C",
                    textAlign: TextAlign.center,
                    style: kMessageTextStyle,
                  )),

                  // );
                ],
              ),
              Divider(
                color: Colors.white,
              )
            ]);
          }),

      //)
    ));

    return /*Scaffold(
      appBar: AppBar(title: Text("Clima")),
      body: */
        Stack(alignment: Alignment.center, children: [
      WeatherBg(
        weatherType: weatherType,
        width: 100, //MediaQuery.of(context).size.width,
        height: 100, //MediaQuery.of(context).size.height,
      ),
      !isLoading
          ? ifexist
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ShadowText(
                      countryName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    ShadowText(
                      '$temperature°',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30, //customize size here
                        // AND others usual text style properties (fontFamily, fontWeight, ...)
                      ),
                    ),
                    ShadowText(
                      descripcion.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10, //customize size here
                        // AND others usual text style properties (fontFamily, fontWeight, ...)
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                )
              : Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sin Informacion Disponible"),
                        TextButton(
                          child: Text('Retry Now!'),
                          onPressed: () {
                            if (!ifexist) {
                              setState(() {});
                              updateUI();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
          : CircularProgressIndicator(),
    ] //),
            );
    //  ),

    // );
  }
}

class ShadowText extends StatelessWidget {
  ShadowText(this.data, {required this.style}) : assert(data != null);

  final String data;
  final TextStyle style;

  Widget build(BuildContext context) {
    return new ClipRect(
      child: new Stack(
        children: [
          new Positioned(
            top: 2.0,
            left: 2.0,
            child: new Text(
              data,
              style: style.copyWith(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          new BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: new Text(data, style: style),
          ),
        ],
      ),
    );
  }
}
