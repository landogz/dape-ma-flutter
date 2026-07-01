class Endpoints {
  // Point to your Laravel API (v1 prefix)
  static const baseUrl = 'https://dape-ma.alwaysdata.net/api/v1';

  static const posts = '/posts';
  static const rehabCenters = '/rehab-centers';
  static const search = '/search';
  static const analyticsEvents = '/analytics/events';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const me = '/auth/me';
  static const profileUpdate = '/auth/profile';
  static const changePassword = '/auth/password';
  static const forgotPassword = '/auth/forgot-password';
  static const bookmarks = '/bookmarks';
  static const reviews = '/reviews';

  static String postDetail(int postId) => '/posts/$postId';
  static String postLike(int postId) => '/posts/$postId/like';
  static String postComments(int postId) => '/posts/$postId/comments';
  static String postComment(int postId, int commentId) =>
      '/posts/$postId/comments/$commentId';
  static String postReviews(int postId) => '/posts/$postId/reviews';

  static String postsByCategory(String slug) => '$posts?category=$slug';
  static String rehabByRegion(String region) => '$rehabCenters?region=$region';
  static String searchQuery(String q, {String? category}) {
    final encodedQuery = Uri.encodeQueryComponent(q);
    final encodedCategory =
        (category != null && category != 'all' && category.isNotEmpty)
            ? '&category=${Uri.encodeQueryComponent(category)}'
            : '';
    return '$search?q=$encodedQuery$encodedCategory';
  }
}
