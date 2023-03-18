import 'dart:convert';

import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:weather/const/color.dart';
import '../models/forcast_result.dart';
import '../models/weather_result.dart';

class OpenWeatherMapClient{
  Future<WeatherResult> getWeather(LocationData locationData) async{
    if(locationData.latitude != null && locationData.longitude != null) {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/weather?lat=${locationData.latitude}&lon=${locationData
              .longitude}&units=metric&appId=$apiKey'));
      if (res.statusCode == 200) {
        return WeatherResult.fromJson(jsonDecode(res.body));
      }
      else {
        throw Exception('Bad Request');
      }
    }
        else{
          throw Exception('wrong location');
        }
      }


  Future<ForecastResult> getForecast(LocationData locationData) async{
    if(locationData.latitude != null && locationData.longitude != null) {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/forecast?lat=${locationData.latitude}&lon=${locationData
              .longitude}&units=metric&appId=$apiKey'));
      if (res.statusCode == 200) {
        return ForecastResult.fromJson(jsonDecode(res.body));
      }
      else {
        throw Exception('Bad Request');
      }
    }
    else{
      throw Exception('wrong location');
    }
  }
  }