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

class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  bool _loading = true;
  String? _error;
  String _query = '';
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _uomController = TextEditingController();
  List<Map<String, dynamic>> _materials = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _uomController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final materials = await ref
          .read(operationsRepositoryProvider)
          .fetchMaterials();
      if (!mounted) return;
      setState(() {
        _materials = materials;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = readableErrorMessage(
          error,
          fallback: 'Failed to load materials',
        );
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    try {
      await ref
          .read(operationsRepositoryProvider)
          .createMaterial(
            name: requireText(_nameController.text, 'Name'),
            type: requireText(_typeController.text, 'Type'),
            uom: requireText(_uomController.text, 'UOM'),
          );
      _nameController.clear();
      _typeController.clear();
      _uomController.clear();
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Material created');
      _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(
          error,
          fallback: 'Failed to create material',
        ),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _materials
        .where((material) {
          final text =
              '${firstString(material, const <String>['name']) ?? ''} ${firstString(material, const <String>['type']) ?? ''} ${firstString(material, const <String>['uom']) ?? ''}'
                  .toLowerCase();
          return text.contains(_query.toLowerCase());
        })
        .toList(growable: false);

    return AppScaffold(
      title: 'Materials',
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
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _typeController,
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _uomController,
                    decoration: const InputDecoration(labelText: 'UOM'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _create,
                      child: const Text('Create Material'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppSearchBar(
            hintText: 'Search material by name, type, or UOM',
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
              title: 'No materials found',
              message: 'Create a material or clear the current search.',
              icon: Icons.inventory_2_outlined,
            )
          else
            ...filtered.map(
              (material) => Card(
                child: ListTile(
                  title: Text(
                    firstString(material, const <String>['name']) ?? '-',
                  ),
                  subtitle: Text(
                    '${firstString(material, const <String>['type']) ?? '-'} · ${firstString(material, const <String>['uom']) ?? '-'}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
