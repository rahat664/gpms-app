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

class StylesScreen extends ConsumerStatefulWidget {
  const StylesScreen({super.key});

  @override
  ConsumerState<StylesScreen> createState() => _StylesScreenState();
}

class _StylesScreenState extends ConsumerState<StylesScreen> {
  bool _loading = true;
  String? _error;
  String _query = '';
  final _styleNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _seasonController = TextEditingController();
  List<Map<String, dynamic>> _styles = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _materials = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _styleNoController.dispose();
    _nameController.dispose();
    _seasonController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repository = ref.read(operationsRepositoryProvider);
      final results = await Future.wait<List<Map<String, dynamic>>>(
        <Future<List<Map<String, dynamic>>>>[
          repository.fetchStyles(),
          repository.fetchMaterials(),
        ],
      );
      if (!mounted) return;
      setState(() {
        _styles = results[0];
        _materials = results[1];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = readableErrorMessage(error, fallback: 'Failed to load styles');
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    try {
      await ref
          .read(operationsRepositoryProvider)
          .createStyle(
            styleNo: requireText(_styleNoController.text, 'Style No'),
            name: requireText(_nameController.text, 'Name'),
            season: _seasonController.text.trim(),
          );
      _styleNoController.clear();
      _nameController.clear();
      _seasonController.clear();
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Style created');
      _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(
          error,
          fallback: 'Failed to create style',
        ),
        isError: true,
      );
    }
  }

  Future<void> _openEditDialog(Map<String, dynamic> style) async {
    final id = firstString(style, const <String>['id']) ?? '';
    final styleNoController = TextEditingController(
      text: firstString(style, const <String>['styleNo']) ?? '',
    );
    final nameController = TextEditingController(
      text: firstString(style, const <String>['name']) ?? '',
    );
    final seasonController = TextEditingController(
      text: firstString(style, const <String>['season']) ?? '',
    );
    final consumptionController = TextEditingController();
    String? materialId;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            final navigator = Navigator.of(context);
            return AlertDialog(
              title: const Text('Style & BOM'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: styleNoController,
                        decoration: const InputDecoration(
                          labelText: 'Style No',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: seasonController,
                        decoration: const InputDecoration(labelText: 'Season'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: materialId,
                        decoration: const InputDecoration(
                          labelText: 'BOM Material',
                        ),
                        items: _materials
                            .map(
                              (material) => DropdownMenuItem<String>(
                                value: firstString(material, const <String>[
                                  'id',
                                ]),
                                child: Text(
                                  '${firstString(material, const <String>['name']) ?? '-'} · ${firstString(material, const <String>['uom']) ?? '-'}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) =>
                            setLocalState(() => materialId = value),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: consumptionController,
                        decoration: const InputDecoration(
                          labelText: 'Consumption',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    if (id.isEmpty) return;
                    try {
                      await ref
                          .read(operationsRepositoryProvider)
                          .deleteStyle(id);
                      if (!mounted) return;
                      navigator.pop();
                      AppSnackBar.show(this.context, message: 'Style deleted');
                      _load();
                    } catch (error) {
                      if (!mounted) return;
                      AppSnackBar.show(
                        this.context,
                        message: readableErrorMessage(
                          error,
                          fallback: 'Failed to delete style',
                        ),
                        isError: true,
                      );
                    }
                  },
                  child: const Text('Delete'),
                ),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (id.isEmpty) return;
                    try {
                      await ref
                          .read(operationsRepositoryProvider)
                          .updateStyle(
                            id: id,
                            styleNo: requireText(
                              styleNoController.text,
                              'Style No',
                            ),
                            name: requireText(nameController.text, 'Name'),
                            season: seasonController.text.trim(),
                          );
                      if (materialId != null &&
                          materialId!.trim().isNotEmpty &&
                          consumptionController.text.trim().isNotEmpty) {
                        await ref
                            .read(operationsRepositoryProvider)
                            .saveBom(
                              styleId: id,
                              materialId: materialId!,
                              consumption: requirePositiveDouble(
                                consumptionController.text,
                                'Consumption',
                              ),
                            );
                      }
                      if (!mounted) return;
                      navigator.pop();
                      AppSnackBar.show(this.context, message: 'Style updated');
                      _load();
                    } catch (error) {
                      if (!mounted) return;
                      AppSnackBar.show(
                        this.context,
                        message: readableErrorMessage(
                          error,
                          fallback: 'Failed to update style',
                        ),
                        isError: true,
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _bomCount(Map<String, dynamic> style) {
    final bomMap = jsonMap(style['bom']);
    final items = bomMap['items'] ?? style['bomItems'] ?? style['materials'];
    return jsonList(items).length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _styles
        .where((style) {
          final text =
              '${firstString(style, const <String>['styleNo']) ?? ''} ${firstString(style, const <String>['name']) ?? ''} ${firstString(style, const <String>['season']) ?? ''}'
                  .toLowerCase();
          return text.contains(_query.toLowerCase());
        })
        .toList(growable: false);

    return AppScaffold(
      title: 'Styles & BOM',
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
                    controller: _styleNoController,
                    decoration: const InputDecoration(labelText: 'Style No'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _seasonController,
                    decoration: const InputDecoration(labelText: 'Season'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _create,
                      child: const Text('Create Style'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppSearchBar(
            hintText: 'Search style no, name, or season',
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
              title: 'No styles found',
              message: 'Create a style or clear the current search.',
              icon: Icons.design_services_outlined,
            )
          else
            ...filtered.map(
              (style) => Card(
                child: ListTile(
                  title: Text(
                    firstString(style, const <String>['styleNo']) ?? '-',
                  ),
                  subtitle: Text(
                    '${firstString(style, const <String>['name']) ?? '-'} · BOM ${_bomCount(style)}',
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _openEditDialog(style),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
