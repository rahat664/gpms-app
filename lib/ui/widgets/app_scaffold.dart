import 'dart:ui';

import 'package:flutter/material.dart';

import 'status_chip.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.bottomNavigationBar,
    this.onRefresh,
    this.onFactorySwitch,
    this.statusLabel,
    this.isOnline = true,
    this.actions = const <Widget>[],
  });

  final Widget body;
  final String title;
  final Widget? bottomNavigationBar;
  final VoidCallback? onRefresh;
  final VoidCallback? onFactorySwitch;
  final String? statusLabel;
  final bool isOnline;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: title,
        onRefresh: onRefresh,
        onFactorySwitch: onFactorySwitch,
        statusLabel: statusLabel,
        isOnline: isOnline,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.onRefresh,
    this.onFactorySwitch,
    this.statusLabel,
    this.isOnline = true,
    this.actions = const <Widget>[],
  });

  final String title;
  final VoidCallback? onRefresh;
  final VoidCallback? onFactorySwitch;
  final String? statusLabel;
  final bool isOnline;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final label = statusLabel ?? (isOnline ? 'Online' : 'Offline');

    return AppBar(
      title: Text(title),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withValues(alpha: 0.1)),
        ),
      ),
      actions: <Widget>[
        StatusChip(
          label: label,
          tone: isOnline ? StatusTone.positive : StatusTone.critical,
          compact: true,
          icon: isOnline ? Icons.wifi : Icons.wifi_off,
          maxWidth: 140,
        ),
        const SizedBox(width: 8),
        if (onRefresh != null)
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        if (onFactorySwitch != null)
          IconButton(
            tooltip: 'Switch factory',
            onPressed: onFactorySwitch,
            icon: const Icon(Icons.factory_outlined),
          ),
        ...actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
