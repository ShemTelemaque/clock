import 'package:timezone/timezone.dart' as tz;

class CityData {
  final String name;
  final String timeZone;

  const CityData(this.name, this.timeZone);

  @override
  String toString() => name;
}

class CityDatabase {
  static final List<CityData> cities = [
    const CityData('New York', 'America/New_York'),
    const CityData('London', 'Europe/London'),
    const CityData('Paris', 'Europe/Paris'),
    const CityData('Tokyo', 'Asia/Tokyo'),
    const CityData('Sydney', 'Australia/Sydney'),
    const CityData('Dubai', 'Asia/Dubai'),
    const CityData('Los Angeles', 'America/Los_Angeles'),
    const CityData('Singapore', 'Asia/Singapore'),
    const CityData('Hong Kong', 'Asia/Hong_Kong'),
    const CityData('Moscow', 'Europe/Moscow'),
    const CityData('Berlin', 'Europe/Berlin'),
    const CityData('Mumbai', 'Asia/Kolkata'),
    const CityData('Rio de Janeiro', 'America/Sao_Paulo'),
    const CityData('Toronto', 'America/Toronto'),
    const CityData('Shanghai', 'Asia/Shanghai'),
  ];

  static List<CityData> search(String query) {
    if (query.isEmpty) return cities;
    final lowercaseQuery = query.toLowerCase();
    return cities.where((city) => 
      city.name.toLowerCase().contains(lowercaseQuery) ||
      city.timeZone.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  static List<String> getAllTimeZones() {
    return tz.timeZoneDatabase.locations.keys.toList()
      ..sort((a, b) => a.compareTo(b));
  }
}