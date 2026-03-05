import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/json/json_utils.dart';
import '../../../ui/widgets/app_scaffold.dart';
import '../../../ui/widgets/state_placeholders.dart';
import '../../../ui/widgets/status_chip.dart';
import '../data/po_repository.dart';
import '../domain/po_models.dart';

class PoDetailsScreen extends ConsumerStatefulWidget {
  const PoDetailsScreen({super.key, required this.poId});

  final String poId;

  @override
  ConsumerState<PoDetailsScreen> createState() => _PoDetailsScreenState();
}

class _PoDetailsScreenState extends ConsumerState<PoDetailsScreen> {
  bool _loading = true;
  String? _error;
  PoDetail? _po;
  List<Map<String, dynamic>> _materials = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repository = ref.read(poRepositoryProvider);
      final po = await repository.fetchPo(widget.poId);
      final materials = await repository.fetchPoMaterialRequirement(widget.poId);

      if (!mounted) return;
      setState(() {
        _po = po;
        _materials = materials;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'PO Details',
      statusLabel: null,
      isOnline: _error == null,
      onRefresh: () {
        HapticFeedback.lightImpact();
        _load();
      },
      onFactorySwitch: () => context.go('/factory-selector'),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('PO: ${widget.poId}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text('Loading PO details...')),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('PO: ${widget.poId}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ErrorStateCard(
            message: 'Failed to load PO details. $_error',
            onRetry: _load,
          ),
        ],
      );
    }

    final po = _po;
    if (po == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ErrorStateCard(
            message: 'PO details response was empty.',
            onRetry: _load,
          ),
        ],
      );
    }

    return _DetailsContent(
      po: po,
      materialRequirements: _materials,
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.po,
    required this.materialRequirements,
  });

  final PoDetail po;
  final List<Map<String, dynamic>> materialRequirements;

  @override
  Widget build(BuildContext context) {
    final mergedMaterials = materialRequirements.isNotEmpty
        ? materialRequirements
        : po.materialRequirements;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        po.poNo,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    StatusChip(
                      label: _statusLabel(po.status),
                      tone: _statusTone(po.status),
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _MetaRow(label: 'Buyer', value: po.buyerName),
                _MetaRow(label: 'Created', value: _dateOrDash(po.createdAt)),
                _MetaRow(label: 'Due', value: _dateOrDash(po.dueDate)),
                _MetaRow(label: 'Delivery', value: _dateOrDash(po.deliveryDate)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _StatusTimelineCard(currentStep: _currentStep(po.status)),
        const SizedBox(height: 12),
        _SectionTitle(title: 'Material Requirements'),
        const SizedBox(height: 8),
        if (mergedMaterials.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Material requirement unavailable for this PO.'),
            ),
          )
        else
          Card(
            child: Column(
              children: <Widget>[
                for (var index = 0; index < mergedMaterials.length; index++) ...<Widget>[
                  Builder(
                    builder: (context) {
                      final material = mergedMaterials[index];
                      final name = (material['materialName'] ??
                              material['name'] ??
                              material['material'] ??
                              'Material')
                          .toString();
                      final qty =
                          (material['requiredQty'] ??
                                  material['qty'] ??
                                  material['quantity'] ??
                                  '-')
                              .toString();
                      final uom = (material['uom'] ?? material['unit'] ?? '').toString();

                      return ListTile(
                        title: Text(name),
                        subtitle: Text('Required qty: $qty $uom'),
                      );
                    },
                  ),
                  if (index != mergedMaterials.length - 1)
                    Divider(
                      color: Theme.of(context).dividerColor,
                      height: 1,
                    ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 12),
        _SectionTitle(title: 'Line Items'),
        const SizedBox(height: 8),
        if (po.items.isEmpty)
          const EmptyStateCard(
            title: 'No line items',
            message: 'The API response did not return item details for this PO.',
            icon: Icons.inventory_2_outlined,
          )
        else
          Card(
            child: Column(
              children: <Widget>[
                for (var index = 0; index < po.items.length; index++) ...<Widget>[
                  Builder(
                    builder: (context) {
                      final item = po.items[index];
                      final styleMap = jsonMap(item['style']);
                      final title = (item['styleNo'] ??
                              styleMap['styleNo'] ??
                              item['sku'] ??
                              item['item'] ??
                              'Item')
                          .toString();
                      final qty = (item['qty'] ?? item['quantity'] ?? '-').toString();
                      final uom = (item['uom'] ?? item['unit'] ?? '').toString();
                      final color = (item['color'] ?? '').toString();
                      final size = (item['size'] ?? '').toString();

                      return ListTile(
                        title: Text(title),
                        subtitle: Text(
                          'Qty: $qty $uom${color.isEmpty ? '' : '  •  Color: $color'}${size.isEmpty ? '' : '  •  Size: $size'}',
                        ),
                      );
                    },
                  ),
                  if (index != po.items.length - 1)
                    Divider(
                      color: Theme.of(context).dividerColor,
                      height: 1,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  int _currentStep(String status) {
    final value = status.toLowerCase();
    if (value.contains('ship')) return 3;
    if (value.contains('prod')) return 2;
    if (value.contains('confirm')) return 1;
    return 0;
  }

  String _statusLabel(String status) {
    final value = status.toLowerCase();
    if (value.contains('ship')) return 'Shipped';
    if (value.contains('prod')) return 'In Production';
    if (value.contains('confirm')) return 'Confirmed';
    if (value.contains('draft')) return 'Draft';
    return status;
  }

  StatusTone _statusTone(String status) {
    final value = status.toLowerCase();
    if (value.contains('ship')) return StatusTone.neutral;
    if (value.contains('prod')) return StatusTone.positive;
    if (value.contains('confirm')) return StatusTone.info;
    return StatusTone.warning;
  }

  String _dateOrDash(String? input) {
    if (input == null || input.trim().isEmpty) return '-';
    final parsed = DateTime.tryParse(input.trim());
    if (parsed == null) return input;
    return DateFormat('dd MMM yyyy').format(parsed);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _StatusTimelineCard extends StatelessWidget {
  const _StatusTimelineCard({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = <String>['Draft', 'Confirmed', 'Production', 'Shipped'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: List<Widget>.generate(labels.length, (index) {
            final reached = index <= currentStep;
            return Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: reached
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 70,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
