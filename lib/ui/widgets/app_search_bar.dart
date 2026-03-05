import 'dart:async';

import 'package:flutter/material.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.onChangedDebounced,
    this.hintText = 'Search',
    this.initialValue = '',
    this.debounce = const Duration(milliseconds: 320),
  });

  final ValueChanged<String> onChangedDebounced;
  final String hintText;
  final String initialValue;
  final Duration debounce;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      widget.onChangedDebounced(value.trim());
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: _controller,
      hintText: widget.hintText,
      leading: const Icon(Icons.search_rounded),
      trailing: <Widget>[
        if (_controller.text.isNotEmpty)
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              _controller.clear();
              _onChanged('');
            },
          ),
      ],
      onChanged: _onChanged,
    );
  }
}
