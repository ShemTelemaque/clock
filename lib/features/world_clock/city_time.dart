import 'package:timezone/timezone.dart' as tz;

class CityTime {
  final String cityName;
  final String timeZone;

  CityTime(this.cityName, this.timeZone);

  DateTime get currentTime {
    final location = tz.getLocation(timeZone);
    return tz.TZDateTime.now(location);
  }

  String get offset {
    final location = tz.getLocation(timeZone);
    final offsetHours = location.currentTimeZone.offset ~/ 3600;
    return 'UTC${offsetHours >= 0 ? "+" : ""}$offsetHours';
  }
}