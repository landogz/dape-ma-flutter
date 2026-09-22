import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/locale_scope.dart';
import '../hope_colors.dart';
import 'hope_directory_org.dart';
import 'hope_directory_service.dart';

class HopeDirectoryScreen extends StatefulWidget {
  const HopeDirectoryScreen({super.key});

  @override
  State<HopeDirectoryScreen> createState() => _HopeDirectoryScreenState();
}

class _HopeDirectoryScreenState extends State<HopeDirectoryScreen> {
  final _searchController = TextEditingController();
  String _category = '';
  String _search = '';
  bool _loading = true;
  String? _error;
  List<HopeDirectoryOrg> _items = const [];

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await HopeDirectoryService.fetch(
        category: _category.isEmpty ? null : _category,
        search: _search,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.l10n.hopeDirectoryEmpty;
      });
    }
  }

  Future<void> _call(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = <(String, String)>[
      ('', l10n.hopeDirectoryAll),
      ('government', l10n.hopeDirectoryGov),
      ('ngo', l10n.hopeDirectoryNgo),
      ('school', l10n.hopeDirectorySchools),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: HopeColors.purple,
        elevation: 0,
        title: Text(
          l10n.hopeDirectoryTitle,
          style: const TextStyle(
            color: HopeColors.purple,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: chips.map((chip) {
                final selected = _category == chip.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(chip.$2),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _category = chip.$1);
                      _load();
                    },
                    selectedColor: HopeColors.purple,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : HopeColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected ? HopeColors.purple : HopeColors.cardBorder,
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                hintText: l10n.hopeDirectorySearchHint,
                prefixIcon: const Icon(Icons.search, color: HopeColors.purple),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: HopeColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: HopeColors.cardBorder),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: HopeColors.purple))
                : _items.isEmpty
                    ? Center(child: Text(_error ?? l10n.hopeDirectoryEmpty))
                    : RefreshIndicator(
                        color: HopeColors.purple,
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final org = _items[index];
                            return _DirectoryCard(
                              org: org,
                              onCall: () => _call(org.phone),
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

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({required this.org, required this.onCall});

  final HopeDirectoryOrg org;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final initial = org.name.isNotEmpty ? org.name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HopeColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: HopeColors.purple.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: HopeColors.purpleSoft,
            backgroundImage:
                org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
            child: org.logoUrl == null
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: HopeColors.purple,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  org.name,
                  style: const TextStyle(
                    color: HopeColors.purple,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                if (org.description != null && org.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    org.description!,
                    style: const TextStyle(color: HopeColors.muted, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 8),
                if (org.address != null && org.address!.isNotEmpty)
                  _InfoRow(Icons.place_outlined, org.address!),
                if (org.phone != null && org.phone!.isNotEmpty)
                  _InfoRow(Icons.phone_outlined, org.phone!),
                if (org.email != null && org.email!.isNotEmpty)
                  _InfoRow(Icons.email_outlined, org.email!),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: HopeColors.chipInactive,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onCall,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.phone, color: HopeColors.purple, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: HopeColors.purple),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: HopeColors.purple),
            ),
          ),
        ],
      ),
    );
  }
}
