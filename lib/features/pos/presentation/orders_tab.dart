import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/widgets/app_search_bar.dart';
import '../../../ui/widgets/app_snackbar.dart';
import '../../../ui/widgets/skeleton_loaders.dart';
import '../../../ui/widgets/state_placeholders.dart';
import '../../../ui/widgets/status_chip.dart';
import '../data/po_repository.dart';
import '../domain/po_models.dart';

enum _OrderFilter { all, draft, confirmed, inProduction, shipped }

class OrdersTab extends ConsumerStatefulWidget {
  const OrdersTab({super.key});

  @override
  ConsumerState<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<OrdersTab> {
  _OrderFilter _selectedFilter = _OrderFilter.all;
  String _query = '';
  final Map<String, String> _statusOverrides = <String, String>{};

  Future<void> _refresh() async {
    ref.invalidate(poListProvider);
    await ref.read(poListProvider.future);
  }

  void _openDetails(BuildContext context, PoListItem po) {
    try {
      context.push('/po/${po.id}');
    } catch (error) {
      AppSnackBar.show(
        context,
        message: 'Navigation failed for PO ${po.poNo}: $error',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final poListAsync = ref.watch(poListProvider);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: poListAsync.when(
        data: (pos) => _buildData(context, pos),
        loading: () => const OrdersSkeleton(),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            _FilterHeader(
              selectedFilter: _selectedFilter,
              onFilterChanged: _onFilterChanged,
              onSearchChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            ErrorStateCard(
              message: 'Failed to load purchase orders. ${error.toString()}',
              onRetry: _refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildData(BuildContext context, List<PoListItem> pos) {
    final filtered = pos.where(_matchesSearchAndFilter).toList(growable: false);

    if (filtered.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          _FilterHeader(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
            onSearchChanged: _onSearchChanged,
          ),
          const SizedBox(height: 14),
          EmptyStateCard(
            title: 'No orders found',
            message: _query.isEmpty
                ? 'No orders match this filter right now.'
                : 'Try a different PO number or buyer keyword.',
            icon: Icons.inventory_2_outlined,
            actionLabel: 'Reset filters',
            onAction: () {
              setState(() {
                _selectedFilter = _OrderFilter.all;
                _query = '';
              });
              ref.invalidate(poListProvider);
            },
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FilterHeader(
              selectedFilter: _selectedFilter,
              onFilterChanged: _onFilterChanged,
              onSearchChanged: _onSearchChanged,
            ),
          );
        }

        final po = filtered[index - 1];
        final status = _effectiveStatus(po);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: ValueKey<String>(po.id),
            background: _SwipeActionBackground(
              alignment: Alignment.centerLeft,
              icon: Icons.check_circle_outline_rounded,
              label: 'Confirm PO',
              color: const Color(0xFF1F8A70),
            ),
            secondaryBackground: _SwipeActionBackground(
              alignment: Alignment.centerRight,
              icon: Icons.visibility_outlined,
              label: 'View details',
              color: const Color(0xFF1E5060),
            ),
            confirmDismiss: (direction) =>
                _onSwipeAction(context, po, status, direction),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openDetails(context, po),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              po.poNo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusChip(
                            label: _statusLabel(status),
                            tone: _statusTone(status),
                            compact: true,
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        po.buyerName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _progressFor(status, po.progress),
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _progressColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    if (!mounted) return;
    setState(() => _query = value);
  }

  void _onFilterChanged(_OrderFilter filter) {
    if (!mounted) return;
    setState(() => _selectedFilter = filter);
  }

  String _effectiveStatus(PoListItem po) => _statusOverrides[po.id] ?? po.status;

  bool _matchesSearchAndFilter(PoListItem po) {
    final status = _effectiveStatus(po);

    final query = _query.toLowerCase();
    final searchMatch = query.isEmpty ||
        po.poNo.toLowerCase().contains(query) ||
        po.buyerName.toLowerCase().contains(query);

    final normalized = _normalizeStatus(status);
    final filterMatch = switch (_selectedFilter) {
      _OrderFilter.all => true,
      _OrderFilter.draft => normalized == 'draft',
      _OrderFilter.confirmed => normalized == 'confirmed',
      _OrderFilter.inProduction => normalized == 'in_production',
      _OrderFilter.shipped => normalized == 'shipped',
    };

    return searchMatch && filterMatch;
  }

  Future<bool> _onSwipeAction(
    BuildContext context,
    PoListItem po,
    String status,
    DismissDirection direction,
  ) async {
    HapticFeedback.lightImpact();

    if (direction == DismissDirection.startToEnd) {
      final normalized = _normalizeStatus(status);
      if (normalized != 'draft') {
        AppSnackBar.show(
          context,
          message: 'Only draft POs can be confirmed from list.',
          isError: true,
        );
        return false;
      }

      setState(() => _statusOverrides[po.id] = 'confirmed');
      AppSnackBar.show(context, message: 'PO ${po.poNo} marked as confirmed.');
      return false;
    }

    _openDetails(context, po);
    return false;
  }

  String _normalizeStatus(String status) {
    final lower = status.toLowerCase().trim();
    if (lower.contains('prod')) return 'in_production';
    if (lower.contains('ship')) return 'shipped';
    if (lower.contains('confirm')) return 'confirmed';
    if (lower.contains('draft') || lower.contains('new')) return 'draft';
    return lower.replaceAll(' ', '_');
  }

  String _statusLabel(String status) {
    return switch (_normalizeStatus(status)) {
      'draft' => 'Draft',
      'confirmed' => 'Confirmed',
      'in_production' => 'In Production',
      'shipped' => 'Shipped',
      _ => status,
    };
  }

  StatusTone _statusTone(String status) {
    return switch (_normalizeStatus(status)) {
      'draft' => StatusTone.warning,
      'confirmed' => StatusTone.info,
      'in_production' => StatusTone.positive,
      'shipped' => StatusTone.neutral,
      _ => StatusTone.neutral,
    };
  }

  double _progressFor(String status, double? progressFromApi) {
    if (progressFromApi != null) {
      final normalized = progressFromApi > 1 ? progressFromApi / 100 : progressFromApi;
      return normalized.clamp(0.0, 1.0);
    }

    return switch (_normalizeStatus(status)) {
      'draft' => 0.12,
      'confirmed' => 0.35,
      'in_production' => 0.72,
      'shipped' => 1.0,
      _ => 0.2,
    };
  }

  Color _progressColor(String status) {
    return switch (_normalizeStatus(status)) {
      'draft' => const Color(0xFFF7B267),
      'confirmed' => const Color(0xFF73B3FF),
      'in_production' => const Color(0xFF4CE2C0),
      'shipped' => const Color(0xFF9AA0A5),
      _ => const Color(0xFF73B3FF),
    };
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  final _OrderFilter selectedFilter;
  final ValueChanged<_OrderFilter> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppSearchBar(
          hintText: 'Search by PO number or buyer',
          onChangedDebounced: onSearchChanged,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<_OrderFilter>(
            showSelectedIcon: false,
            selected: <_OrderFilter>{selectedFilter},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                onFilterChanged(selection.first);
              }
            },
            segments: const <ButtonSegment<_OrderFilter>>[
              ButtonSegment<_OrderFilter>(
                value: _OrderFilter.all,
                label: Text('All'),
              ),
              ButtonSegment<_OrderFilter>(
                value: _OrderFilter.draft,
                label: Text('Draft'),
              ),
              ButtonSegment<_OrderFilter>(
                value: _OrderFilter.confirmed,
                label: Text('Confirmed'),
              ),
              ButtonSegment<_OrderFilter>(
                value: _OrderFilter.inProduction,
                label: Text('In Production'),
              ),
              ButtonSegment<_OrderFilter>(
                value: _OrderFilter.shipped,
                label: Text('Shipped'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwipeActionBackground extends StatelessWidget {
  const _SwipeActionBackground({
    required this.alignment,
    required this.icon,
    required this.label,
    required this.color,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.35),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!isLeft) ...<Widget>[Text(label), const SizedBox(width: 6)],
          Icon(icon, size: 20),
          if (isLeft) ...<Widget>[const SizedBox(width: 6), Text(label)],
        ],
      ),
    );
  }
}
