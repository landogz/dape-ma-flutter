import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/rehab_center.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../hope/hope_colors.dart';
import 'widgets/rehab_center_card.dart';
import '../../core/theme/app_theme_colors.dart';

class RehabCentersScreen extends StatefulWidget {
  const RehabCentersScreen({super.key});

  @override
  State<RehabCentersScreen> createState() => _RehabCentersScreenState();
}

class _RehabCentersScreenState extends State<RehabCentersScreen> {
  List<RehabCenter> _centers = [];
  bool _loading = false;
  String _region = '';
  String _search = '';
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
          if (_search.trim().isNotEmpty) 'search': _search.trim(),
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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.pageBackground,
        foregroundColor: HopeColors.headingOf(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.rehabCentersTitle,
          style: TextStyle(
            color: HopeColors.headingOf(context),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: _regions.map((r) {
                final value = r['value']!;
                final label = value.isEmpty ? l10n.allRegions : r['label']!;
                final selected = _region == value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _region = value);
                      _loadCenters();
                    },
                    selectedColor: HopeColors.purple,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : HopeColors.mutedOf(context),
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: context.pageBackground,
                    side: BorderSide(
                      color:
                          selected ? HopeColors.purple : HopeColors.cardBorderOf(context),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: (v) {
                setState(() => _search = v);
                _loadCenters();
              },
              onChanged: (v) {
                if (v.isEmpty && _search.isNotEmpty) {
                  setState(() => _search = '');
                  _loadCenters();
                }
              },
              decoration: InputDecoration(
                hintText: l10n.searchRehabByHint,
                hintStyle: TextStyle(color: HopeColors.mutedOf(context)),
                prefixIcon:
                    Icon(Icons.search, color: HopeColors.headingOf(context)),
                filled: true,
                fillColor: context.inputFill,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: HopeColors.cardBorderOf(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: HopeColors.cardBorderOf(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: HopeColors.purple, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: HopeColors.purple),
                  )
                : _centers.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_hospital_outlined,
                                size: 56,
                                color: HopeColors.mutedOf(context),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.noRehabFound,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: HopeColors.headingOf(context),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _region.isNotEmpty || _search.isNotEmpty
                                    ? l10n.tryDifferentSearch
                                    : l10n.checkBackLater,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: HopeColors.mutedOf(context),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: HopeColors.headingOf(context),
                        onRefresh: _loadCenters,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _centers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return RehabCenterCard(center: _centers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
