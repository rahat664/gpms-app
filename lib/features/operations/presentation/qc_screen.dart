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

class QcScreen extends ConsumerStatefulWidget {
  const QcScreen({super.key});

  @override
  ConsumerState<QcScreen> createState() => _QcScreenState();
}

class _QcScreenState extends ConsumerState<QcScreen> {
  bool _loading = true;
  String? _error;
  String _inspectionType = 'INLINE';
  bool _pass = true;
  final _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _bundleController = TextEditingController();
  final _notesController = TextEditingController();
  final _defectTypeController = TextEditingController();
  final _defectCountController = TextEditingController();

  Map<String, dynamic> _summary = const <String, dynamic>{};
  List<Map<String, dynamic>> _bundleOptions = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _bundleController.dispose();
    _notesController.dispose();
    _defectTypeController.dispose();
    _defectCountController.dispose();
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
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        repository.fetchQcSummary(date: date),
        repository.fetchBundles(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = jsonMap(results[0]);
        _bundleOptions = (results[1] as List<Map<String, dynamic>>);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = readableErrorMessage(
          error,
          fallback: 'Failed to load QC data',
        );
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    try {
      final hasDefect = _defectTypeController.text.trim().isNotEmpty;
      await ref
          .read(operationsRepositoryProvider)
          .submitQcInspection(
            bundleId: requireText(_bundleController.text, 'Bundle ID'),
            type: _inspectionType,
            pass: _pass,
            notes: _notesController.text.trim(),
            defectType: hasDefect ? _defectTypeController.text.trim() : null,
            defectCount: hasDefect
                ? requirePositiveInt(
                    _defectCountController.text,
                    'Defect Count',
                  )
                : null,
          );
      _bundleController.clear();
      _notesController.clear();
      _defectTypeController.clear();
      _defectCountController.clear();
      setState(() {
        _inspectionType = 'INLINE';
        _pass = true;
      });
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Inspection submitted');
      _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(
          error,
          fallback: 'Failed to submit inspection',
        ),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topDefects = jsonList(
      _summary['topDefects'],
    ).map(jsonMap).toList(growable: false);

    return AppScaffold(
      title: 'Quality Control',
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
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date'),
                    onSubmitted: (_) => _load(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bundleController,
                    decoration: const InputDecoration(labelText: 'Bundle ID'),
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
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _inspectionType,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items: const <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: 'INLINE',
                              child: Text('INLINE'),
                            ),
                            DropdownMenuItem(
                              value: 'FINAL',
                              child: Text('FINAL'),
                            ),
                          ],
                          onChanged: (value) => setState(
                            () => _inspectionType = value ?? 'INLINE',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<bool>(
                          initialValue: _pass,
                          decoration: const InputDecoration(labelText: 'Pass'),
                          items: const <DropdownMenuItem<bool>>[
                            DropdownMenuItem(value: true, child: Text('true')),
                            DropdownMenuItem(
                              value: false,
                              child: Text('false'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _pass = value ?? true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _defectTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Defect Type',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _defectCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Defect Count',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Submit Inspection'),
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
          else ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _KpiCell(
                        label: 'Inspected',
                        value:
                            firstString(_summary, const <String>[
                              'totalInspected',
                            ]) ??
                            '0',
                      ),
                    ),
                    Expanded(
                      child: _KpiCell(
                        label: 'Pass Rate',
                        value:
                            '${firstString(_summary, const <String>['passRate']) ?? '0'}%',
                      ),
                    ),
                    Expanded(
                      child: _KpiCell(
                        label: 'DHU',
                        value:
                            '${firstString(_summary, const <String>['dhuEstimate']) ?? '0'}%',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (topDefects.isEmpty)
              const EmptyStateCard(
                title: 'No defects',
                message: 'No defect summary rows returned for this date.',
                icon: Icons.fact_check_outlined,
              )
            else
              ...topDefects.map(
                (defect) => Card(
                  child: ListTile(
                    title: Text(
                      firstString(defect, const <String>['defectType']) ?? '-',
                    ),
                    trailing: Text(
                      firstString(defect, const <String>['count']) ?? '0',
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

class _KpiCell extends StatelessWidget {
  const _KpiCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
