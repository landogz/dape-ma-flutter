import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/iec_material.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../hope/hope_colors.dart';
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
  String _search = '';
  final _searchController = TextEditingController();

  static const _topics = [
    '',
    'Prevention',
    'Awareness',
    'Youth',
    'Family',
    'Recovery',
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
    final topicChips = _topics
        .map((topic) => (topic, topic.isEmpty ? l10n.allTopics : topic))
        .toList();
    final mediaChips = <(String, String)>[
      ('', l10n.allMediaTypes),
      ('gif', 'GIF'),
      ('youtube', 'YouTube'),
      ('image', 'Image'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: HopeColors.purple,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.iecMaterialsTitle,
          style: const TextStyle(
            color: HopeColors.purple,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          if (l10n.iecMaterialsSubtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.iecMaterialsSubtitle,
                  style: const TextStyle(
                    color: HopeColors.muted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: topicChips.map((chip) {
                final selected = _topic == chip.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(chip.$2),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _topic = chip.$1);
                      _load();
                    },
                    selectedColor: HopeColors.purple,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : HopeColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color:
                          selected ? HopeColors.purple : HopeColors.cardBorder,
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: mediaChips.map((chip) {
                final selected = _mediaType == chip.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(chip.$2),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _mediaType = chip.$1);
                      _load();
                    },
                    selectedColor: HopeColors.purple,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : HopeColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color:
                          selected ? HopeColors.purple : HopeColors.cardBorder,
                    ),
                    showCheckmark: false,
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
                _load();
              },
              onChanged: (v) {
                if (v.isEmpty && _search.isNotEmpty) {
                  setState(() => _search = '');
                  _load();
                }
              },
              decoration: InputDecoration(
                hintText: l10n.searchIecMaterialsHint,
                hintStyle: const TextStyle(color: HopeColors.muted),
                prefixIcon:
                    const Icon(Icons.search, color: HopeColors.purple),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: HopeColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: HopeColors.cardBorder),
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
                : _items.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noIecMaterialsFound,
                          style: const TextStyle(
                            color: HopeColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: HopeColors.purple,
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
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
    );
  }
}
