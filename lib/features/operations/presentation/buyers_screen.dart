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

class BuyersScreen extends ConsumerStatefulWidget {
  const BuyersScreen({super.key});

  @override
  ConsumerState<BuyersScreen> createState() => _BuyersScreenState();
}

class _BuyersScreenState extends ConsumerState<BuyersScreen> {
  bool _loading = true;
  String? _error;
  String _query = '';
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  List<Map<String, dynamic>> _buyers = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final buyers = await ref.read(operationsRepositoryProvider).fetchBuyers();
      if (!mounted) return;
      setState(() {
        _buyers = buyers;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = readableErrorMessage(error, fallback: 'Failed to load buyers');
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    try {
      final name = requireText(_nameController.text, 'Name');
      final country = _countryController.text.trim();
      await ref
          .read(operationsRepositoryProvider)
          .createBuyer(name: name, country: country.isEmpty ? null : country);
      _nameController.clear();
      _countryController.clear();
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Buyer created');
      _load();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: readableErrorMessage(
          error,
          fallback: 'Failed to create buyer',
        ),
        isError: true,
      );
    }
  }

  Future<void> _openEditDialog(Map<String, dynamic> buyer) async {
    final id = firstString(buyer, const <String>['id', 'buyerId']) ?? '';
    final nameController = TextEditingController(
      text: firstString(buyer, const <String>['name']) ?? '',
    );
    final countryController = TextEditingController(
      text: firstString(buyer, const <String>['country']) ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        final navigator = Navigator.of(context);
        return AlertDialog(
          title: const Text('Edit Buyer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (id.isEmpty) return;
                try {
                  await ref.read(operationsRepositoryProvider).deleteBuyer(id);
                  if (!mounted) return;
                  navigator.pop();
                  AppSnackBar.show(this.context, message: 'Buyer deleted');
                  _load();
                } catch (error) {
                  if (!mounted) return;
                  AppSnackBar.show(
                    this.context,
                    message: readableErrorMessage(
                      error,
                      fallback: 'Failed to delete buyer',
                    ),
                    isError: true,
                  );
                }
              },
              child: const Text('Delete'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (id.isEmpty) return;
                try {
                  await ref
                      .read(operationsRepositoryProvider)
                      .updateBuyer(
                        id: id,
                        name: requireText(nameController.text, 'Name'),
                        country: countryController.text.trim(),
                      );
                  if (!mounted) return;
                  navigator.pop();
                  AppSnackBar.show(this.context, message: 'Buyer updated');
                  _load();
                } catch (error) {
                  if (!mounted) return;
                  AppSnackBar.show(
                    this.context,
                    message: readableErrorMessage(
                      error,
                      fallback: 'Failed to update buyer',
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
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _buyers
        .where((buyer) {
          final text =
              '${firstString(buyer, const <String>['name']) ?? ''} ${firstString(buyer, const <String>['country']) ?? ''}'
                  .toLowerCase();
          return text.contains(_query.toLowerCase());
        })
        .toList(growable: false);

    return AppScaffold(
      title: 'Buyers',
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
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _create,
                      child: const Text('Create Buyer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppSearchBar(
            hintText: 'Search buyer by name or country',
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
              title: 'No buyers found',
              message: 'Create a buyer or clear the current search.',
              icon: Icons.people_outline_rounded,
            )
          else
            ...filtered.map(
              (buyer) => Card(
                child: ListTile(
                  title: Text(
                    firstString(buyer, const <String>['name']) ?? '-',
                  ),
                  subtitle: Text(
                    firstString(buyer, const <String>['country']) ?? '-',
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _openEditDialog(buyer),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
