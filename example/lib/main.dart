import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'base_widget_flutter',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      bodyAppBar: AppBar(title: const Text('Home')),
      // Blocks the back gesture while a save is in flight.
      canPop: !_isSaving,
      isLoading: _isSaving,
      dismissKeyboardOnTap: true,
      safeArea: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            Text('Tap the save button to see the loading overlay.'),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tap outside to dismiss the keyboard',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
