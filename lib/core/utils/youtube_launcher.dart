import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubeLauncher {
  /// Launches YouTube search for form tutorial of a specific exercise.
  static Future<void> launchExerciseTutorial(String exerciseTitle) async {
    final cleanTitle = exerciseTitle.trim();
    final query = cleanTitle.isNotEmpty
        ? '$cleanTitle exercise form tutorial'
        : 'workout exercise form tutorial';
    final url = Uri.parse(
      'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('[YouTubeLauncher] Failed external launch: $e, trying platform default');
      try {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (err) {
        debugPrint('[YouTubeLauncher] Could not launch URL: $err');
      }
    }
  }
}
