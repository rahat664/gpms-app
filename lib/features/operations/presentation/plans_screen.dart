import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/form/form_validators.dart';
import '../../../core/json/json_utils.dart';
import '../../../core/network/error_message.dart';
import '../../../ui/widgets/app_scaffold.dart';
import '../../../ui/widgets/app_snackbar.dart';
import '../../../ui/widgets/state_placeholders.dart';
import '../data/operations_repository.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  bool _loading = true;
  String? _error;

  final _planNameController = TextEditingController();
  final _planStartController = TextEditingController();
  final _planEndController = TextEditingController();
  final _planIdController = TextEditingController();

  String? _selectedPoId;
  String? _selectedPoItemId;
  String? _selectedLineId;
  final _assignStartController = TextEditingController();
  final _assignEndController = TextEditingController();
  final _assignDateController = TextEditingController();
  final _assignTargetController = TextEditingController();

  List<Map<String, dynamic>> _pos = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _poItems = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _lineStatus = const <Map<String, dynamic>>[];
  Map<String, dynamic>? _planDetail;
  final List<String> _knownPlanIds = <String>[];

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _planStartController.text = _today;
    _planEndController.text = _today;
    _assignStartController.text = _today;
    _assignEndController.text = _today;
    _assignDateController.text = _today;
    _loadInitial();
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _planStartController.dispose();
    _planEndController.dispose();
    _planIdController.dispose();
    _assignStartController.dispose();
    _assignEndController.dispose();
    _assignDateController.dispose();
    _assignTargetController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(operationsRepositoryProvider);
      final results = await Future.wait<List<Map<String, dynamic>>>(
        <Future<List<Map<String, dynamic>>>>[
          repository.fetchPos(),
          repository.fetchLineStatus(date: _assignDateController.text),
        ],
      );
      if (!mounted) return;
      setState(() {
        _pos = results[0];
        _lineStatus = results[1];
        _loading = false;
      });
      await _loadPlanDetail();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = readableErrorMessage(error, fallback: 'Failed to load plans');
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
      final items = jsonList(
        detail['items'],
      ).map(jsonMap).toList(growable: false);
      setState(() => _poItems = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _poItems = const <Map<String, dynamic>>[]);
    }
  }

  Future<void> _loadPlanDetail() async {
    final planId = _planIdController.text.trim();
    if (planId.isEmpty) {
      setState(() => _planDetail = null);
      return;
    }

    try {
      final detail = await ref
          .read(operationsRepositoryProvider)
          .fetchPlanDetail(planId);
      if (!mounted) return;
      setState(() => _planDetail = detail);
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(error, fallback: 'Failed to load plan'),
        isError: true,
      );
    }
  }

  Future<void> _createPlan() async {
    try {
      ensureDateOrder(_planStartController.text, _planEndController.text);
      final response = await ref
          .read(operationsRepositoryProvider)
          .createPlan(
            name: requireText(_planNameController.text, 'Name'),
            startDate: requireDate(_planStartController.text, 'Start Date'),
            endDate: requireDate(_planEndController.text, 'End Date'),
          );
      final newId = firstString(response, const <String>['id', 'planId']) ?? '';
      if (newId.isNotEmpty) {
        _planIdController.text = newId;
        if (!_knownPlanIds.contains(newId)) {
          _knownPlanIds.insert(0, newId);
        }
      }
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Plan created');
      _loadPlanDetail();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(error, fallback: 'Failed to create plan'),
        isError: true,
      );
    }
  }

  Future<void> _assignPlan() async {
    try {
      final planId = requireText(_planIdController.text, 'Plan ID');
      ensureDateOrder(_assignStartController.text, _assignEndController.text);
      await ref
          .read(operationsRepositoryProvider)
          .assignPlan(
            planId: planId,
            poId: requireText(_selectedPoId ?? '', 'PO'),
            poItemId: requireText(_selectedPoItemId ?? '', 'PO Item'),
            lineId: requireText(_selectedLineId ?? '', 'Line'),
            startDate: requireDate(_assignStartController.text, 'Start Date'),
            endDate: requireDate(_assignEndController.text, 'End Date'),
            targetDate: requireDate(_assignDateController.text, 'Target Date'),
            targetQty: requirePositiveInt(
              _assignTargetController.text,
              'Target Qty',
            ),
          );
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Plan assigned');
      _loadPlanDetail();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(error, fallback: 'Failed to assign plan'),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = jsonList(
      _planDetail?['lines'],
    ).map(jsonMap).toList(growable: false);

    return AppScaffold(
      title: 'Plans',
      onRefresh: _loadInitial,
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
            ErrorStateCard(message: _error!, onRetry: _loadInitial)
          else ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create Plan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _planNameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _planStartController,
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _planEndController,
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _createPlan,
                        child: const Text('Create Plan'),
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
                        'Assign Line',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _planIdController,
                      decoration: const InputDecoration(labelText: 'Plan ID'),
                      onSubmitted: (_) => _loadPlanDetail(),
                    ),
                    if (_knownPlanIds.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _knownPlanIds
                            .map(
                              (id) => ActionChip(
                                label: Text(
                                  id.substring(0, id.length.clamp(0, 8)),
                                ),
                                onPressed: () {
                                  setState(() => _planIdController.text = id);
                                  _loadPlanDetail();
                                },
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                    const SizedBox(height: 8),
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
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLineId,
                      decoration: const InputDecoration(labelText: 'Line'),
                      items: _lineStatus
                          .map(
                            (line) => DropdownMenuItem<String>(
                              value: firstString(line, const <String>[
                                'lineId',
                              ]),
                              child: Text(
                                firstString(line, const <String>['lineName']) ??
                                    '-',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) =>
                          setState(() => _selectedLineId = value),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _assignStartController,
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _assignEndController,
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _assignDateController,
                            decoration: const InputDecoration(
                              labelText: 'Target Date',
                            ),
                            onSubmitted: (_) async {
                              try {
                                final date = requireDate(
                                  _assignDateController.text,
                                  'Target Date',
                                );
                                final lines = await ref
                                    .read(operationsRepositoryProvider)
                                    .fetchLineStatus(date: date);
                                if (!mounted) return;
                                setState(() => _lineStatus = lines);
                              } catch (_) {}
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _assignTargetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Target Qty',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _assignPlan,
                        child: const Text('Assign Line'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Plan Detail',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      firstString(
                            _planDetail ?? const <String, dynamic>{},
                            const <String>['name'],
                          ) ??
                          'No plan loaded',
                    ),
                    const SizedBox(height: 10),
                    if (lines.isEmpty)
                      const Text('No assigned lines')
                    else
                      ...lines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              title: Text(
                                firstString(
                                      jsonMap(line['line']),
                                      const <String>['name'],
                                    ) ??
                                    firstString(line, const <String>[
                                      'lineId',
                                    ]) ??
                                    '-',
                              ),
                              subtitle: Text(
                                'PO ${firstString(jsonMap(line['po']), const <String>['poNo']) ?? '-'} · Style ${firstString(jsonMap(jsonMap(line['poItem'])['style']), const <String>['styleNo']) ?? '-'}',
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
