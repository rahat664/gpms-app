import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/form/form_validators.dart';
import '../../../core/json/json_utils.dart';
import '../../../core/network/error_message.dart';
import '../../../ui/widgets/app_scaffold.dart';
import '../../../ui/widgets/app_search_bar.dart';
import '../../../ui/widgets/app_snackbar.dart';
import '../../../ui/widgets/state_placeholders.dart';
import '../data/operations_repository.dart';

class PoWorkbenchScreen extends ConsumerStatefulWidget {
  const PoWorkbenchScreen({super.key});

  @override
  ConsumerState<PoWorkbenchScreen> createState() => _PoWorkbenchScreenState();
}

class _PoWorkbenchScreenState extends ConsumerState<PoWorkbenchScreen> {
  bool _loading = true;
  String? _error;
  String _query = '';

  String? _buyerId;
  final _poNoController = TextEditingController();
  String? _poIdForItem;
  String? _styleId;
  final _colorController = TextEditingController();
  final _qtyController = TextEditingController();

  List<Map<String, dynamic>> _buyers = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _styles = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _pos = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _stock = const <Map<String, dynamic>>[];

  String? _selectedPoId;
  Map<String, dynamic>? _selectedPo;
  Map<String, dynamic>? _selectedRequirement;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _poNoController.dispose();
    _colorController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(operationsRepositoryProvider);
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        repository.fetchBuyers(),
        repository.fetchStyles(),
        repository.fetchPos(),
        repository.fetchInventoryStock(),
      ]);
      if (!mounted) return;
      setState(() {
        _buyers = (results[0] as List<Map<String, dynamic>>);
        _styles = (results[1] as List<Map<String, dynamic>>);
        _pos = (results[2] as List<Map<String, dynamic>>);
        _stock = (results[3] as List<Map<String, dynamic>>);
        _loading = false;
      });
      await _loadSelectedPoDetail();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = readableErrorMessage(
          error,
          fallback: 'Failed to load PO workspace',
        );
        _loading = false;
      });
    }
  }

  Future<void> _loadSelectedPoDetail() async {
    final poId = _selectedPoId;
    if (poId == null || poId.isEmpty) {
      setState(() {
        _selectedPo = null;
        _selectedRequirement = null;
      });
      return;
    }
    try {
      final repository = ref.read(operationsRepositoryProvider);
      final details = await Future.wait<dynamic>(<Future<dynamic>>[
        repository.fetchPoDetail(poId),
        repository.fetchPoMaterialRequirement(poId),
      ]);
      if (!mounted) return;
      setState(() {
        _selectedPo = jsonMap(details[0]);
        _selectedRequirement = jsonMap(details[1]);
      });
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(
          error,
          fallback: 'Failed to load PO detail',
        ),
        isError: true,
      );
    }
  }

  Future<void> _createPo() async {
    try {
      await ref
          .read(operationsRepositoryProvider)
          .createPo(
            poNo: requireText(_poNoController.text, 'PO No'),
            buyerId: requireText(_buyerId ?? '', 'Buyer'),
          );
      _poNoController.clear();
      if (!mounted) return;
      AppSnackBar.show(context, message: 'PO created');
      _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(error, fallback: 'Failed to create PO'),
        isError: true,
      );
    }
  }

  Future<void> _addPoItem() async {
    try {
      await ref
          .read(operationsRepositoryProvider)
          .addPoItem(
            poId: requireText(_poIdForItem ?? '', 'PO'),
            styleId: requireText(_styleId ?? '', 'Style'),
            color: requireText(_colorController.text, 'Color'),
            quantity: requirePositiveInt(_qtyController.text, 'Quantity'),
          );
      _colorController.clear();
      _qtyController.clear();
      if (!mounted) return;
      AppSnackBar.show(context, message: 'PO item added');
      _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(error, fallback: 'Failed to add PO item'),
        isError: true,
      );
    }
  }

  Future<void> _updateStatus({
    required String poId,
    required String status,
  }) async {
    try {
      if (status == 'CONFIRMED') {
        await ref.read(operationsRepositoryProvider).confirmPo(poId);
      } else {
        await ref
            .read(operationsRepositoryProvider)
            .updatePoStatus(id: poId, status: status);
      }
      if (!mounted) return;
      AppSnackBar.show(context, message: 'PO updated to $status');
      _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(error, fallback: 'Failed to update PO'),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _pos
        .where((po) {
          final text =
              '${firstString(po, const <String>['poNo']) ?? ''} ${firstString(po, const <String>['status']) ?? ''} ${firstString(jsonMap(po['buyer']), const <String>['name']) ?? ''}'
                  .toLowerCase();
          return text.contains(_query.toLowerCase());
        })
        .toList(growable: false);

    final requirementMaterials = jsonList(
      _selectedRequirement?['materials'] ??
          _selectedRequirement?['items'] ??
          _selectedRequirement?['requirements'],
    ).map(jsonMap).toList(growable: false);
    final stockByMaterialId = <String, double>{};
    for (final row in _stock) {
      final materialId =
          firstString(row, const <String>['materialId', 'id']) ?? '';
      final qty =
          double.tryParse(
            (firstString(row, const <String>['availableQty']) ?? '0')
                .toString(),
          ) ??
          0;
      stockByMaterialId[materialId] = qty;
    }
    final poItems = jsonList(
      _selectedPo?['items'],
    ).map(jsonMap).toList(growable: false);

    return AppScaffold(
      title: 'PO Workbench',
      onRefresh: _load,
      onFactorySwitch: () => context.go('/factory-selector'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (_loading)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_error != null)
            ErrorStateCard(message: _error!, onRetry: _load)
          else ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create PO',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _poNoController,
                      decoration: const InputDecoration(labelText: 'PO No'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _buyerId,
                      decoration: const InputDecoration(labelText: 'Buyer'),
                      items: _buyers
                          .map(
                            (buyer) => DropdownMenuItem<String>(
                              value: firstString(buyer, const <String>['id']),
                              child: Text(
                                firstString(buyer, const <String>['name']) ??
                                    '-',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setState(() => _buyerId = value),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _createPo,
                        child: const Text('Create PO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Add PO Item',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _poIdForItem,
                      decoration: const InputDecoration(labelText: 'PO'),
                      items: _pos
                          .map(
                            (po) => DropdownMenuItem<String>(
                              value: firstString(po, const <String>['id']),
                              child: Text(
                                firstString(po, const <String>['poNo']) ?? '-',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) =>
                          setState(() => _poIdForItem = value),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _styleId,
                      decoration: const InputDecoration(labelText: 'Style'),
                      items: _styles
                          .map(
                            (style) => DropdownMenuItem<String>(
                              value: firstString(style, const <String>['id']),
                              child: Text(
                                '${firstString(style, const <String>['styleNo']) ?? '-'} · ${firstString(style, const <String>['name']) ?? '-'}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setState(() => _styleId = value),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _addPoItem,
                        child: const Text('Add Item'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            AppSearchBar(
              hintText: 'Search PO by number, buyer, or status',
              onChangedDebounced: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              const EmptyStateCard(
                title: 'No purchase orders',
                message: 'Create a PO to begin.',
                icon: Icons.shopping_bag_outlined,
              )
            else
              ...filtered.map((po) {
                final poId = firstString(po, const <String>['id']) ?? '';
                return Card(
                  child: ListTile(
                    title: Text(firstString(po, const <String>['poNo']) ?? '-'),
                    subtitle: Text(
                      '${firstString(jsonMap(po['buyer']), const <String>['name']) ?? '-'} · ${firstString(po, const <String>['status']) ?? '-'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (status) =>
                          _updateStatus(poId: poId, status: status),
                      itemBuilder: (_) => const <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: 'CONFIRMED',
                          child: Text('Confirm'),
                        ),
                        PopupMenuItem(
                          value: 'SHIPPED',
                          child: Text('Mark Shipped'),
                        ),
                        PopupMenuItem(value: 'CLOSED', child: Text('Close')),
                      ],
                    ),
                    onTap: () {
                      setState(() => _selectedPoId = poId);
                      _loadSelectedPoDetail();
                    },
                  ),
                );
              }),
            if (_selectedPoId != null) ...<Widget>[
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'PO Detail · ${firstString(_selectedPo ?? const <String, dynamic>{}, const <String>['poNo']) ?? _selectedPoId}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      if (poItems.isEmpty)
                        const Text('No line items')
                      else
                        ...poItems.map(
                          (item) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              firstString(
                                    jsonMap(item['style']),
                                    const <String>['styleNo'],
                                  ) ??
                                  firstString(item, const <String>[
                                    'styleNo',
                                  ]) ??
                                  'Style',
                            ),
                            subtitle: Text(
                              'Color ${firstString(item, const <String>['color']) ?? '-'} · Qty ${firstString(item, const <String>['quantity', 'qty']) ?? '-'}',
                            ),
                          ),
                        ),
                      const Divider(),
                      const Text(
                        'Material Requirement',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      if (requirementMaterials.isEmpty)
                        const Text('No requirement rows')
                      else
                        ...requirementMaterials.map((material) {
                          final materialId =
                              firstString(material, const <String>[
                                'materialId',
                              ]) ??
                              '';
                          final requiredQty =
                              double.tryParse(
                                (firstString(material, const <String>[
                                          'requiredQty',
                                        ]) ??
                                        '0')
                                    .toString(),
                              ) ??
                              0;
                          final stock = stockByMaterialId[materialId] ?? 0;
                          final shortage = requiredQty > stock;
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              firstString(material, const <String>[
                                    'materialName',
                                  ]) ??
                                  materialId,
                            ),
                            subtitle: Text(
                              'Required $requiredQty · Stock $stock · ${firstString(material, const <String>['uom']) ?? ''}',
                            ),
                            trailing: Text(
                              shortage ? 'SHORT' : 'OK',
                              style: TextStyle(
                                color: shortage
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
