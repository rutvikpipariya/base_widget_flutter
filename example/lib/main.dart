import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  // Configure the fonts once; every BaseTextStyles.instance getter uses them.
  BaseTextStyles.instance = BaseTextStyles(
    fontSize: 14,
    color: '151D31'.toColor(),
  );
  runApp(const ExampleApp());
}

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weights', style: BaseTextStyles.instance.bold),
            Text('Light', style: BaseTextStyles.instance.light),
            Text('Regular', style: BaseTextStyles.instance.regular),
            Text('Semi bold', style: BaseTextStyles.instance.semiBold),
            // Any style is a plain TextStyle, so copyWith varies just one.
            Text(
              'Bold, 24px',
              style: BaseTextStyles.instance.bold.copyWith(fontSize: 24),
            ),
            Text(
              'Hex colours',
              style: BaseTextStyles.instance.bold.copyWith(
                color: '#1364FF'.toColor(),
              ),
            ),
            // Uncomment once you have an SVG in the example's assets:
            // const SvgImageWidget(
            //   asset: 'assets/icons/search.svg',
            //   height: 24,
            //   color: Colors.indigo,
            //   semanticsLabel: 'Search',
            // ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Tap outside to dismiss the keyboard',
                border: OutlineInputBorder(),
              ),
            ),
            const Text('Tap save to see the loading overlay.'),
          ],
        ),
      ),
    );
  }
}
