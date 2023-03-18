import 'package:get/get.dart';
import 'package:location/location.dart';

class MyStateController extends GetxController{

  var isenableLocation = false.obs;
  var locationData = LocationData.fromMap(<String,dynamic>{}).obs;

  var isLoading = false.obs;
}