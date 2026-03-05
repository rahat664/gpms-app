import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkspaceTab extends StatelessWidget {
  const WorkspaceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        _WorkspaceTile(
          title: 'PO Workbench',
          subtitle: 'Create PO, add items, confirm and close',
          icon: Icons.shopping_bag_outlined,
          route: '/workspace/po',
        ),
        _WorkspaceTile(
          title: 'Buyers',
          subtitle: 'Create, update and delete buyer records',
          icon: Icons.people_alt_outlined,
          route: '/workspace/buyers',
        ),
        _WorkspaceTile(
          title: 'Styles & BOM',
          subtitle: 'Manage styles and BOM consumption',
          icon: Icons.design_services_outlined,
          route: '/workspace/styles',
        ),
        _WorkspaceTile(
          title: 'Materials',
          subtitle: 'Create and browse material library',
          icon: Icons.inventory_2_outlined,
          route: '/workspace/materials',
        ),
        _WorkspaceTile(
          title: 'Inventory',
          subtitle: 'Receive and issue stock to cutting',
          icon: Icons.warehouse_outlined,
          route: '/workspace/inventory',
        ),
        _WorkspaceTile(
          title: 'Plans',
          subtitle: 'Create plans and assign line targets',
          icon: Icons.event_note_outlined,
          route: '/workspace/plans',
        ),
        _WorkspaceTile(
          title: 'Cutting',
          subtitle: 'Create cutting batches and bundles',
          icon: Icons.content_cut_outlined,
          route: '/workspace/cutting',
        ),
        _WorkspaceTile(
          title: 'Sewing',
          subtitle: 'Post hourly line output and monitor status',
          icon: Icons.precision_manufacturing_outlined,
          route: '/workspace/sewing',
        ),
        _WorkspaceTile(
          title: 'Quality Control',
          subtitle: 'Submit inspections and review summary',
          icon: Icons.fact_check_outlined,
          route: '/workspace/qc',
        ),
      ],
    );
  }
}

class _WorkspaceTile extends StatelessWidget {
  const _WorkspaceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(route),
        ),
      ),
    );
  }
}
