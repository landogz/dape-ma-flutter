import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/models/post.dart';
import '../../core/network/endpoints.dart';
import '../post_detail/post_detail_screen.dart';
import '../home/widgets/post_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Post> _bookmarks = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _loading = true);
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.bookmarks,
      );
      final root = res.data ?? <String, dynamic>{};
      final data = root['data'];
      final list = data is List<dynamic> ? data : <dynamic>[];
      setState(() {
        _bookmarks = list
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {
      if (mounted) setState(() => _bookmarks = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onBookmarkTap(Post post) async {
    try {
      await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.bookmarks,
        data: <String, dynamic>{'post_id': post.id},
      );
      await _loadBookmarks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from bookmarks'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove bookmark. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadBookmarks,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final post = _bookmarks[index];
                    return PostCard(
                      post: post,
                      isBookmarked: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(
                              post: post,
                              initialIsBookmarked: true,
                            ),
                          ),
                        ).then((_) => _loadBookmarks());
                      },
                      onBookmarkTap: () => _onBookmarkTap(post),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

