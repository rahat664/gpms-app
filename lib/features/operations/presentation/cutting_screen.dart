import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/form/form_validators.dart';
import '../../../core/json/json_utils.dart';
import '../../../core/network/error_message.dart';
import '../../../ui/widgets/app_scaffold.dart';
import '../../../ui/widgets/app_snackbar.dart';
import '../../../ui/widgets/state_placeholders.dart';
import '../data/operations_repository.dart';

class CuttingScreen extends ConsumerStatefulWidget {
  const CuttingScreen({super.key});

  @override
  ConsumerState<CuttingScreen> createState() => _CuttingScreenState();
}

class _CuttingScreenState extends ConsumerState<CuttingScreen> {
  bool _loading = true;
  String? _error;
  String? _selectedPoId;
  String? _selectedPoItemId;
  final _batchNoController = TextEditingController();
  final _batchIdController = TextEditingController();
  final _bundleSizeController = TextEditingController();
  final _bundleQtyController = TextEditingController();

  List<Map<String, dynamic>> _pos = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _poItems = const <Map<String, dynamic>>[];
  Map<String, dynamic>? _batch;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _batchNoController.dispose();
    _batchIdController.dispose();
    _bundleSizeController.dispose();
    _bundleQtyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await ref.read(operationsRepositoryProvider).fetchPos();
      if (!mounted) return;
      setState(() {
        _pos = pos;
        _loading = false;
      });
      await _loadBatch();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = readableErrorMessage(
          error,
          fallback: 'Failed to load cutting data',
        );
        _loading = false;
      });
    }
  }

  Future<void> _loadPoItems() async {
    final poId = _selectedPoId;
    if (poId == null || poId.isEmpty) {
      setState(() => _poItems = const <Map<String, dynamic>>[]);
      return;
    }
    try {
      final detail = await ref
          .read(operationsRepositoryProvider)
          .fetchPoDetail(poId);
      if (!mounted) return;
      setState(() {
        _poItems = jsonList(
          detail['items'],
        ).map(jsonMap).toList(growable: false);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _poItems = const <Map<String, dynamic>>[]);
    }
  }

  Future<void> _loadBatch() async {
    final batchId = _batchIdController.text.trim();
    if (batchId.isEmpty) {
      setState(() => _batch = null);
      return;
    }
    try {
      final batch = await ref
          .read(operationsRepositoryProvider)
          .fetchCuttingBatch(batchId);
      if (!mounted) return;
      setState(() => _batch = batch);
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(error, fallback: 'Failed to load batch'),
        isError: true,
      );
    }
  }

  Future<void> _createBatch() async {
    try {
      final response = await ref
          .read(operationsRepositoryProvider)
          .createCuttingBatch(
            poItemId: requireText(_selectedPoItemId ?? '', 'PO Item'),
            batchNo: requireText(_batchNoController.text, 'Batch No'),
          );
      final id = firstString(response, const <String>['id']) ?? '';
      if (id.isNotEmpty) {
        _batchIdController.text = id;
      }
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Cutting batch created');
      _loadBatch();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(
          error,
          fallback: 'Failed to create batch',
        ),
        isError: true,
      );
    }
  }

  Future<void> _generateBundle() async {
    try {
      await ref
          .read(operationsRepositoryProvider)
          .createBundles(
            batchId: requireText(_batchIdController.text, 'Batch ID'),
            size: requireText(_bundleSizeController.text, 'Size'),
            qty: requirePositiveInt(_bundleQtyController.text, 'Qty'),
          );
      _bundleSizeController.clear();
      _bundleQtyController.clear();
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Bundle generated');
      _loadBatch();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(
          error,
          fallback: 'Failed to generate bundle',
        ),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bundles = jsonList(
      _batch?['bundles'],
    ).map(jsonMap).toList(growable: false);

    return AppScaffold(
      title: 'Cutting',
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
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPoId,
                      decoration: const InputDecoration(labelText: 'PO'),
                      items: _pos
                          .map(
                            (po) => DropdownMenuItem<String>(
                              value: firstString(po, const <String>['id']),
                              child: Text(
                                '${firstString(po, const <String>['poNo']) ?? '-'} · ${firstString(jsonMap(po['buyer']), const <String>['name']) ?? 'No buyer'}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        setState(() {
                          _selectedPoId = value;
                          _selectedPoItemId = null;
                        });
                        _loadPoItems();
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPoItemId,
                      decoration: const InputDecoration(labelText: 'PO Item'),
                      items: _poItems
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: firstString(item, const <String>['id']),
                              child: Text(
                                '${firstString(jsonMap(item['style']), const <String>['styleNo']) ?? 'Style'} · ${firstString(item, const <String>['color']) ?? '-'} · ${firstString(item, const <String>['quantity']) ?? '-'}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) =>
                          setState(() => _selectedPoItemId = value),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _batchNoController,
                      decoration: const InputDecoration(labelText: 'Batch No'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _createBatch,
                        child: const Text('Create Batch'),
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
                    TextField(
                      controller: _batchIdController,
                      decoration: const InputDecoration(labelText: 'Batch ID'),
                      onSubmitted: (_) => _loadBatch(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _bundleSizeController,
                            decoration: const InputDecoration(
                              labelText: 'Size',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _bundleQtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Qty'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _generateBundle,
                        child: const Text('Generate Bundle'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (bundles.isEmpty)
              const EmptyStateCard(
                title: 'No bundles',
                message: 'Create a batch and generate bundles to view details.',
                icon: Icons.content_cut_outlined,
              )
            else
              ...bundles.map(
                (bundle) => Card(
                  child: ListTile(
                    title: Text(
                      firstString(bundle, const <String>['bundleCode']) ?? '-',
                    ),
                    subtitle: Text(
                      'Size ${firstString(bundle, const <String>['size']) ?? '-'} · Qty ${firstString(bundle, const <String>['qty']) ?? '-'} · ${firstString(bundle, const <String>['status']) ?? '-'}',
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
