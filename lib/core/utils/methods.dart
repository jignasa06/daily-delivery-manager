import 'package:intl/intl.dart';

class UtilsMethods{

  static String localToDMMMYYYY(DateTime time){

    return DateFormat('d MMM yyyy').format(time);
  }
}