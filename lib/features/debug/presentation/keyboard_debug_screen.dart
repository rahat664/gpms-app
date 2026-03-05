import 'package:flutter/material.dart';

class KeyboardDebugScreen extends StatefulWidget {
  const KeyboardDebugScreen({super.key});

  @override
  State<KeyboardDebugScreen> createState() => _KeyboardDebugScreenState();
}

class _KeyboardDebugScreenState extends State<KeyboardDebugScreen> {
  late final TextEditingController _fieldAController;
  late final TextEditingController _fieldBController;

  @override
  void initState() {
    super.initState();
    _fieldAController = TextEditingController();
    _fieldBController = TextEditingController();
  }

  @override
  void dispose() {
    _fieldAController.dispose();
    _fieldBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Keyboard Debug')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Tap fields, switch focus, then tap outside to dismiss.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fieldAController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Field A'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fieldBController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Field B'),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Keyboard should remain stable while typing.',
                    ),
                  ),
                );
              },
              child: const Text('Run Quick Check'),
            ),
          ],
        ),
      ),
    );
  }
}
