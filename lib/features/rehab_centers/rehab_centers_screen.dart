import 'package:flutter/material.dart';

import '../../core/models/rehab_center.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/rehab_center_card.dart';

class RehabCentersScreen extends StatefulWidget {
  const RehabCentersScreen({super.key});

  @override
  State<RehabCentersScreen> createState() => _RehabCentersScreenState();
}

class _RehabCentersScreenState extends State<RehabCentersScreen> {
  List<RehabCenter> _centers = [];
  bool _loading = false;
  String _region = '';
  final _searchController = TextEditingController();

  static const List<Map<String, String>> _regions = [
    {'value': '', 'label': 'All regions'},
    {'value': 'NCR', 'label': 'NCR'},
    {'value': 'Region III', 'label': 'Region III'},
    {'value': 'Region VII', 'label': 'Region VII'},
    {'value': 'Region XI', 'label': 'Region XI'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCenters() async {
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      final res = await api.get<Map<String, dynamic>>(
        Endpoints.rehabCenters,
        query: <String, dynamic>{
          if (_region.isNotEmpty) 'region': _region,
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
          _centers = list
              .map((e) => RehabCenter.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _centers = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rehab Centers'),
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
                      hintText: 'Search by name, address, or province',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _loadCenters(),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _regions.map((r) {
                        final value = r['value']!;
                        final label = r['label']!;
                        final isSelected = _region == value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _region = isSelected ? '' : value);
                              _loadCenters();
                            },
                            selectedColor: AppColors.primaryBlue.withOpacity(0.2),
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
                  : _centers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_hospital_outlined,
                                size: 64,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No rehab centers found',
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
                                        _searchController.text.isNotEmpty
                                    ? 'Try a different region or search'
                                    : 'Check back later for listings',
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
                          onRefresh: _loadCenters,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _centers.length,
                            itemBuilder: (context, index) {
                              return RehabCenterCard(center: _centers[index]);
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

