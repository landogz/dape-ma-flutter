import '../../../core/models/post_comment.dart';

List<PostComment> addCommentToTree(
  List<PostComment> comments,
  PostComment comment,
) {
  if (comment.parentId == null || comment.parentId == 0) {
    return [comment, ...comments];
  }

  return comments
      .map((item) => _insertReply(item, comment))
      .toList();
}

PostComment _insertReply(PostComment node, PostComment reply) {
  if (node.id == reply.parentId) {
    return node.copyWith(replies: [...node.replies, reply]);
  }

  if (node.replies.isEmpty) {
    return node;
  }

  return node.copyWith(
    replies: node.replies.map((child) => _insertReply(child, reply)).toList(),
  );
}

List<PostComment> updateCommentInTree(
  List<PostComment> comments,
  PostComment updated,
) {
  return comments.map((item) => _updateNode(item, updated)).toList();
}

PostComment _updateNode(PostComment node, PostComment updated) {
  if (node.id == updated.id) {
    return updated.copyWith(replies: node.replies);
  }

  if (node.replies.isEmpty) {
    return node;
  }

  return node.copyWith(
    replies: node.replies.map((child) => _updateNode(child, updated)).toList(),
  );
}

List<PostComment> removeCommentFromTree(
  List<PostComment> comments,
  int commentId,
) {
  final filtered = <PostComment>[];

  for (final item in comments) {
    if (item.id == commentId) {
      continue;
    }

    filtered.add(
      item.copyWith(
        replies: removeCommentFromTree(item.replies, commentId),
      ),
    );
  }

  return filtered;
}

int countCommentsInTree(List<PostComment> comments) {
  var total = 0;
  for (final comment in comments) {
    total += 1 + countCommentsInTree(comment.replies);
  }
  return total;
}
