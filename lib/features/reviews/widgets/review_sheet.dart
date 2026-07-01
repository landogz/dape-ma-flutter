import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../review_service.dart';

class ReviewSheet extends StatefulWidget {
  const ReviewSheet({
    super.key,
    required this.postId,
    this.initialRating = 5,
    this.initialComment,
  });

  final int postId;
  final int initialRating;
  final String? initialComment;

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  late int _rating;
  final _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    if (widget.initialComment != null) {
      _commentController.text = widget.initialComment!;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating <= 0) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await ReviewService.submitPostReview(
        widget.postId,
        _rating,
        _commentController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      setState(() {
        _error = ReviewService.friendlyError(e, 'submit your rating');
      });
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate this content',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                icon: Icon(
                  starIndex <= _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () => setState(() => _rating = starIndex),
              );
            }),
          ),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Comment (optional)',
              filled: true,
              fillColor: AppColors.lightBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: TextStyle(color: AppColors.accentRed),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit rating'),
            ),
          ),
        ],
      ),
    );
  }
}
