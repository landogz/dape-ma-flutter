import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class Endpoints {
  /// Set to `true` only when using local Laravel on port 8000 (simulator/emulator).
  static const bool useLocalApi = false;

  static const String _productionBaseUrl =
      'https://dapemade.ddb.gov.ph/api/v1';

  /// Your Mac LAN IP for a physical phone on the same Wi‑Fi.
  /// iOS Simulator / desktop can use 127.0.0.1; Android emulator uses 10.0.2.2.
  static const String _localLanHost = '192.168.100.84';
  static const int _localPort = 8000;

  static String get baseUrl {
    if (!useLocalApi) {
      return _productionBaseUrl;
    }

    return 'http://$_localHost:$_localPort/api/v1';
  }

  static String get _localHost {
    if (kIsWeb) {
      return '127.0.0.1';
    }

    if (Platform.isAndroid) {
      // Android emulator loopback to the host machine.
      return '10.0.2.2';
    }

    // iOS Simulator + macOS desktop.
    // For a real iPhone, change this to `_localLanHost`.
    return '127.0.0.1';
  }

  /// Useful when installing on a physical device instead of the simulator.
  static String get localLanBaseUrl =>
      'http://$_localLanHost:$_localPort/api/v1';

  static const posts = '/posts';
  static const rehabCenters = '/rehab-centers';
  static const trainings = '/trainings';
  static const contests = '/contests';
  /// Deprecated: use [contests]. Kept for unused legacy screens.
  static const songContest = '/song-contest';
  /// Deprecated: use [contests]. Kept for unused legacy screens.
  static const posterContest = '/poster-contest';
  /// Deprecated: use [contests]. Kept for unused legacy screens.
  static const videoContest = '/video-contest';
  static const iecMaterials = '/iec-materials';
  static const search = '/search';
  static const analyticsEvents = '/analytics/events';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const me = '/auth/me';
  static const meProfile = '/me/profile';
  static const profileUpdate = '/auth/profile';
  static const onboardingUpdate = '/auth/onboarding';
  static const changePassword = '/auth/password';
  static const forgotPassword = '/auth/forgot-password';
  static const bookmarks = '/bookmarks';
  static const reviews = '/reviews';
  static const notifications = '/notifications';
  static const notificationsSummary = '/notifications/summary';
  static const notificationsReadAll = '/notifications/read-all';
  static const fcmToken = '/device/fcm-token';
  static const dailyVerseToday = '/kid-listo/random';
  static const kidListoRandom = '/kid-listo/random';
  static const bibleBooks = '/bible/books';
  static const biblePassage = '/bible/passage';
  static const diaryEntries = '/diary-entries';
  static const diaryToday = '/diary-entries/today';
  static const hopeDirectory = '/hope-directory';
  static const hopeEvents = '/hope-events';
  static const moodCheckins = '/mood-checkins';
  static const moodCheckinsToday = '/mood-checkins/today';
  static const careToolkitQuestions = '/care-toolkit/questions';
  static const careSupportResources = '/care-support/resources';
  static const legalPages = '/legal-pages';

  static String notificationRead(int id) => '/notifications/$id/read';
  static String diaryEntry(int id) => '/diary-entries/$id';
  static String hopeEventDetail(int id) => '/hope-events/$id';
  static String legalPage(String slug) => '/legal-pages/$slug';

  static String postDetail(int postId) => '/posts/$postId';
  static String postLike(int postId) => '/posts/$postId/like';
  static String postReactions(int postId) => '/posts/$postId/reactions';
  static String postComments(int postId) => '/posts/$postId/comments';
  static String postComment(int postId, int commentId) =>
      '/posts/$postId/comments/$commentId';
  static String postReviews(int postId) => '/posts/$postId/reviews';
  static String trainingDetail(int id) => '/trainings/$id';
  static String contestDetail(int id) => '/contests/$id';
  static String contestSubmit(int id) => '/contests/$id/entries';
  static String contestMyEntry(int id) => '/contests/$id/my-entry';
  /// Deprecated: use [contestDetail].
  static String songContestDetail(int id) => '/song-contest/$id';
  /// Deprecated: use [contestSubmit].
  static String songContestSubmit(int id) => '/song-contest/$id/entries';
  /// Deprecated: use [contestMyEntry].
  static String songContestMyEntry(int id) => '/song-contest/$id/my-entry';
  /// Deprecated: use [contestDetail].
  static String posterContestDetail(int id) => '/poster-contest/$id';
  /// Deprecated: use [contestSubmit].
  static String posterContestSubmit(int id) => '/poster-contest/$id/entries';
  /// Deprecated: use [contestMyEntry].
  static String posterContestMyEntry(int id) => '/poster-contest/$id/my-entry';
  /// Deprecated: use [contestDetail].
  static String videoContestDetail(int id) => '/video-contest/$id';
  /// Deprecated: use [contestSubmit].
  static String videoContestSubmit(int id) => '/video-contest/$id/entries';
  /// Deprecated: use [contestMyEntry].
  static String videoContestMyEntry(int id) => '/video-contest/$id/my-entry';
  static String iecMaterialDetail(int id) => '/iec-materials/$id';

  static String postsByCategory(String slug) => '$posts?category=$slug';
  static String rehabByRegion(String region) => '$rehabCenters?region=$region';
  static String trainingsByRegion(String region) => '$trainings?region=$region';
  static String searchQuery(String q, {String? category}) {
    final encodedQuery = Uri.encodeQueryComponent(q);
    final encodedCategory =
        (category != null && category != 'all' && category.isNotEmpty)
            ? '&category=${Uri.encodeQueryComponent(category)}'
            : '';
    return '$search?q=$encodedQuery$encodedCategory';
  }
}
