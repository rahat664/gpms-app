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

class SewingScreen extends ConsumerStatefulWidget {
  const SewingScreen({super.key});

  @override
  ConsumerState<SewingScreen> createState() => _SewingScreenState();
}

class _SewingScreenState extends ConsumerState<SewingScreen> {
  bool _loading = true;
  String? _error;
  String? _lineId;
  final _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _hourController = TextEditingController();
  final _qtyController = TextEditingController();
  final _bundleController = TextEditingController();

  List<Map<String, dynamic>> _lineStatus = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _bundleOptions = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hourController.dispose();
    _qtyController.dispose();
    _bundleController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final date = requireDate(_dateController.text, 'Date');
      final repository = ref.read(operationsRepositoryProvider);
      final results = await Future.wait<List<Map<String, dynamic>>>(
        <Future<List<Map<String, dynamic>>>>[
          repository.fetchLineStatus(date: date),
          repository.fetchBundles(),
        ],
      );
      if (!mounted) return;
      setState(() {
        _lineStatus = results[0];
        _bundleOptions = results[1];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = readableErrorMessage(
          error,
          fallback: 'Failed to load sewing data',
        );
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    try {
      await ref
          .read(operationsRepositoryProvider)
          .submitHourlyOutput(
            lineId: requireText(_lineId ?? '', 'Line'),
            date: requireDate(_dateController.text, 'Date'),
            hourSlot: requirePositiveInt(
              _hourController.text,
              'Hour Slot',
              min: 0,
            ),
            qty: requirePositiveInt(_qtyController.text, 'Qty'),
            bundleId: _bundleController.text.trim(),
          );
      _qtyController.clear();
      _bundleController.clear();
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Hourly output submitted');
      _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(
          error,
          fallback: 'Failed to submit hourly output',
        ),
        isError: true,
      );
    }
  }

  String _renderMap(dynamic source) {
    final map = jsonMap(source);
    if (map.isEmpty) return '-';
    return map.entries.map((entry) => '${entry.key}:${entry.value}').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Sewing',
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
                    initialValue: _lineId,
                    decoration: const InputDecoration(labelText: 'Line'),
                    items: _lineStatus
                        .map(
                          (line) => DropdownMenuItem<String>(
                            value: firstString(line, const <String>['lineId']),
                            child: Text(
                              firstString(line, const <String>['lineName']) ??
                                  '-',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) => setState(() => _lineId = value),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(labelText: 'Date'),
                          onSubmitted: (_) => _load(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _hourController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Hour Slot',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bundleController,
                    decoration: const InputDecoration(
                      labelText: 'Bundle ID (optional)',
                    ),
                  ),
                  if (_bundleOptions.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _bundleOptions
                            .take(5)
                            .map((bundle) {
                              final id =
                                  firstString(bundle, const <String>['id']) ??
                                  '';
                              return ActionChip(
                                label: Text(
                                  firstString(bundle, const <String>[
                                        'bundleCode',
                                      ]) ??
                                      id,
                                ),
                                onPressed: () => _bundleController.text = id,
                              );
                            })
                            .toList(growable: false),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Submit Output'),
                    ),
                  ),
                ],
              ),
            ),
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
          else if (_lineStatus.isEmpty)
            const EmptyStateCard(
              title: 'No line status',
              message: 'No sewing line data found for the selected date.',
              icon: Icons.precision_manufacturing_outlined,
            )
          else
            ..._lineStatus.map(
              (line) => Card(
                child: ListTile(
                  title: Text(
                    firstString(line, const <String>['lineName']) ?? '-',
                  ),
                  subtitle: Text(
                    'Output ${firstString(line, const <String>['totalOutputToday']) ?? '0'}\nHourly ${_renderMap(line['hourlyBreakdown'])}\nWIP ${_renderMap(line['wipCounts'])}',
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
