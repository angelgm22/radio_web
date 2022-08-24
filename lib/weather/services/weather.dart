import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';
import 'package:radio_web/weather/services/location.dart';
import 'package:radio_web/weather/services/networking.dart';

const apiKey = 'c24acd9d0450c49bf5bc4cf093ad00eb';
const openWeatherMapUrl = 'https://api.openweathermap.org/data/2.5/weather';
const openWeatherMapUrlF = 'https://api.openweathermap.org/data/2.5/forecast';

class WeatherModel {
  Future<dynamic> getCityWeather(String cityName) async {
    var url = '$openWeatherMapUrl?q=$cityName&appid=$apiKey&units=metric';
    NetworkHelper networkHelper = NetworkHelper(url);
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getLocationWeather() async {
        Location Loc = Location();
    await Loc.getCurrentLocation();


    String Lat = Loc.latitude.toString();
      // '26.3178195255735';
    String Lon = Loc.longitude.toString();
    // '-98.87180180290801';
    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapUrl?lat=$Lat&lon=$Lon&appid=$apiKey&units=metric&lang=es');
    var weatherData = await networkHelper.getData();

    return weatherData;
  }

  Future<dynamic> getForecastWeather() async {


    String Lat =  '26.3178195255735';
    String Lon =  '-98.87180180290801';

    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapUrlF?lat=$Lat&lon=$Lon&appid=$apiKey&units=metric&lang=es&cnt=8');
    var weatherData = await networkHelper.getData();

    return weatherData;
  }

  WeatherType getWeatherType(int condition, String tipo) {
    if (condition < 300) {
      return WeatherType.thunder;
      //  '🌩';
    } else if (condition < 400) {
      return WeatherType.heavyRainy;
      // '🌧';
    } else if (condition < 600) {
      return WeatherType.lightRainy;
      // '☔️';
    } else if (condition < 700) {
      return WeatherType.middleSnow;
      // '☃️';
    } else if (condition < 800) {
      return WeatherType.heavySnow;
      // '🌫';
    } else if (condition == 800) {
      if (tipo == "dia") {
        return WeatherType.sunny;
      } else {
        return WeatherType.sunnyNight;
      }
      // '☀️';
    } else if (condition <= 804) {
      if (tipo == "dia") {
        return WeatherType.cloudy;
      } else {
        return WeatherType.cloudyNight;
      }
      // '☁️';
    } else {
      return WeatherType.sunny;
      // return '🤷‍';
    }
  }

  String getWeatherAsset(int condition) {
    if (condition < 300) {
      return //'images/weatherIcons/15-s.png';
          '🌩';
    } else if (condition < 400) {
      return // 'images/weatherIcons/12-s.png';
          '🌧';
    } else if (condition < 600) {
      return // 'images/weatherIcons/14.png';
          '☔️';
    } else if (condition < 700) {
      return // 'images/weatherIcons/22-s.png';
          '☃️';
    } else if (condition < 800) {
      return // 'images/weatherIcons/08-.png';
          '🌫';
    } else if (condition == 800) {
      return // 'images/weatherIcons/01-s.png';
          '☀️';
    } else if (condition <= 804) {
      return // 'images/weatherIcons/07-s.png';
          '☁️';
    } else {
      return // 'images/weatherIcons/01-s.png';
          '🤷‍';
    }
  }
}
