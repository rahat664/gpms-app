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

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  bool _loading = true;
  String? _error;
  String _query = '';
  String? _materialId;
  final _qtyController = TextEditingController();
  List<Map<String, dynamic>> _stock = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stock = await ref
          .read(operationsRepositoryProvider)
          .fetchInventoryStock();
      if (!mounted) return;
      setState(() {
        _stock = stock;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = readableErrorMessage(error, fallback: 'Failed to load stock');
        _loading = false;
      });
    }
  }

  Future<void> _apply({required bool receive}) async {
    try {
      final materialId = requireText(_materialId ?? '', 'Material');
      final qty = requirePositiveDouble(_qtyController.text, 'Qty');
      final repository = ref.read(operationsRepositoryProvider);
      if (receive) {
        await repository.receiveInventory(materialId: materialId, qty: qty);
      } else {
        await repository.issueInventoryToCutting(
          materialId: materialId,
          qty: qty,
        );
      }
      _qtyController.clear();
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: receive ? 'Inventory received' : 'Inventory issued',
      );
      _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(
          error,
          fallback: 'Inventory update failed',
        ),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = <String, Map<String, dynamic>>{};
    for (final row in _stock) {
      final id = firstString(row, const <String>['materialId', 'id']) ?? '';
      if (id.isEmpty) continue;
      options[id] = row;
    }

    final filtered = _stock
        .where((row) {
          final text =
              '${firstString(row, const <String>['materialName']) ?? ''} ${firstString(row, const <String>['materialType']) ?? ''} ${firstString(row, const <String>['uom']) ?? ''}'
                  .toLowerCase();
          return text.contains(_query.toLowerCase());
        })
        .toList(growable: false);

    return AppScaffold(
      title: 'Inventory',
      onRefresh: _load,
      onFactorySwitch: () => context.go('/factory-selector'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    initialValue: _materialId,
                    decoration: const InputDecoration(labelText: 'Material'),
                    items: options.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              '${firstString(entry.value, const <String>['materialName']) ?? '-'} · ${firstString(entry.value, const <String>['uom']) ?? '-'}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) => setState(() => _materialId = value),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _apply(receive: true),
                          child: const Text('Receive'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () => _apply(receive: false),
                          child: const Text('Issue to Cutting'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppSearchBar(
            hintText: 'Search stock rows',
            onChangedDebounced: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_error != null)
            ErrorStateCard(message: _error!, onRetry: _load)
          else if (filtered.isEmpty)
            const EmptyStateCard(
              title: 'No stock rows',
              message: 'Stock appears empty for this factory.',
              icon: Icons.warehouse_outlined,
            )
          else
            ...filtered.map(
              (row) => Card(
                child: ListTile(
                  title: Text(
                    firstString(row, const <String>['materialName']) ?? '-',
                  ),
                  subtitle: Text(
                    '${firstString(row, const <String>['materialType']) ?? '-'} · ${firstString(row, const <String>['availableQty']) ?? '0'} ${firstString(row, const <String>['uom']) ?? ''}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
