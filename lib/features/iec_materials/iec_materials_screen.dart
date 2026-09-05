import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/iec_material.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/iec_material_card.dart';

class IecMaterialsScreen extends StatefulWidget {
  const IecMaterialsScreen({super.key});

  @override
  State<IecMaterialsScreen> createState() => _IecMaterialsScreenState();
}

class _IecMaterialsScreenState extends State<IecMaterialsScreen> {
  List<IecMaterial> _items = [];
  bool _loading = false;
  String _topic = '';
  String _mediaType = '';
  final _searchController = TextEditingController();

  static const _topics = [
    '',
    'Prevention',
    'Awareness',
    'Youth',
    'Family',
    'Recovery',
  ];

  static const _mediaTypes = [
    {'value': '', 'labelKey': 'all'},
    {'value': 'gif', 'label': 'GIF'},
    {'value': 'youtube', 'label': 'YouTube'},
    {'value': 'image', 'label': 'Image'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient().get<Map<String, dynamic>>(
        Endpoints.iecMaterials,
        query: <String, dynamic>{
          'per_page': 48,
          if (_topic.isNotEmpty) 'topic': _topic,
          if (_mediaType.isNotEmpty) 'media_type': _mediaType,
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
          _items = list
              .map((e) => IecMaterial.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l10n.iecMaterialsTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.iecMaterialsSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchIecMaterialsHint,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _topics.map((topic) {
                        final selected = _topic == topic;
                        final label =
                            topic.isEmpty ? l10n.allTopics : topic;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) {
                              setState(
                                () => _topic = selected ? '' : topic,
                              );
                              _load();
                            },
                            selectedColor:
                                AppColors.primaryBlue.withValues(alpha: 0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _mediaTypes.map((type) {
                        final value = type['value']!;
                        final selected = _mediaType == value;
                        final label = value.isEmpty
                            ? l10n.allMediaTypes
                            : type['label']!;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) {
                              setState(
                                () => _mediaType = selected ? '' : value,
                              );
                              _load();
                            },
                            selectedColor: AppColors.secondaryBlue
                                .withValues(alpha: 0.18),
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
                  : _items.isEmpty
                      ? Center(child: Text(l10n.noIecMaterialsFound))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              return IecMaterialCard(
                                material: _items[index],
                                index: index,
                              );
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
