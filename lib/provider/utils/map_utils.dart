import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(
    double latitude,
    double longitude,
  ) async {
    String queryUrl = 'https://maps.google.com/?q=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(queryUrl))) {
      await launchUrl(Uri.parse(queryUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }
}
