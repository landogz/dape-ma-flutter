import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/training.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/training_card.dart';

class TrainingsScreen extends StatefulWidget {
  const TrainingsScreen({super.key});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {
  List<Training> _trainings = [];
  bool _loading = false;
  String _region = '';
  String _category = '';
  final _searchController = TextEditingController();

  static const List<Map<String, String>> _regions = [
    {'value': '', 'label': 'All regions'},
    {'value': 'NCR', 'label': 'NCR'},
    {'value': 'Region III', 'label': 'Region III'},
    {'value': 'Region VII', 'label': 'Region VII'},
    {'value': 'Region XI', 'label': 'Region XI'},
  ];

  static const List<Map<String, String>> _categories = [
    {'value': '', 'label': 'All categories'},
    {'value': 'Preventive Education', 'label': 'Preventive Education'},
    {'value': 'Capacity Building', 'label': 'Capacity Building'},
    {'value': 'Community-Based', 'label': 'Community-Based'},
    {'value': 'Anti-Drug Advocacy', 'label': 'Anti-Drug Advocacy'},
    {'value': 'Youth Development', 'label': 'Youth Development'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrainings() async {
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      final res = await api.get<Map<String, dynamic>>(
        Endpoints.trainings,
        query: <String, dynamic>{
          if (_region.isNotEmpty) 'region': _region,
          if (_category.isNotEmpty) 'category': _category,
          if (_searchController.text.trim().isNotEmpty)
            'search': _searchController.text.trim(),
        },
      );
      final root = res.data ?? <String, dynamic>{};
      List<dynamic> list = const [];
      final data = root['data'];
      if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
        list = data['data'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        list = data;
      }
      if (mounted) {
        setState(() {
          _trainings = list
              .map((e) => Training.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _trainings = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trainingsTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchTrainingsHint,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _loadTrainings(),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((c) {
                        final value = c['value']!;
                        final label =
                            value.isEmpty ? l10n.allCategories : c['label']!;
                        final isSelected = _category == value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(
                                () => _category = isSelected ? '' : value,
                              );
                              _loadTrainings();
                            },
                            selectedColor:
                                AppColors.primaryBlue.withOpacity(0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _regions.map((r) {
                        final value = r['value']!;
                        final label =
                            value.isEmpty ? l10n.allRegions : r['label']!;
                        final isSelected = _region == value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(
                                () => _region = isSelected ? '' : value,
                              );
                              _loadTrainings();
                            },
                            selectedColor:
                                AppColors.primaryBlue.withOpacity(0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _trainings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noTrainingsFound,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _region.isNotEmpty ||
                                        _category.isNotEmpty ||
                                        _searchController.text.isNotEmpty
                                    ? l10n.tryDifferentSearch
                                    : l10n.checkBackLater,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTrainings,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _trainings.length,
                            itemBuilder: (context, index) {
                              return TrainingCard(training: _trainings[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
