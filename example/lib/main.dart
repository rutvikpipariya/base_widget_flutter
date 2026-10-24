import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  // Configure the font once; every BaseTextStyles.instance getter uses it.
  BaseTextStyles.instance = const BaseTextStyles(fontSize: 15);
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'base_widget_flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: '#4F46E5'.toColor()),
      darkTheme: ThemeData(
        colorSchemeSeed: '#4F46E5'.toColor(),
        brightness: Brightness.dark,
      ),
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
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [OverlayDemo(), StatesDemo(), StylesDemo()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.hourglass_empty),
            label: 'Overlay',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_carousel_outlined),
            label: 'States',
          ),
          NavigationDestination(icon: Icon(Icons.text_fields), label: 'Styles'),
        ],
      ),
    );
  }
}

/// `isLoading` with a blurred overlay and a message, `canPop` and
/// `dismissKeyboardOnTap`.
class OverlayDemo extends StatefulWidget {
  const OverlayDemo({super.key});

  @override
  State<OverlayDemo> createState() => _OverlayDemoState();
}

class _OverlayDemoState extends State<OverlayDemo> {
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BaseWidget(
      bodyAppBar: AppBar(title: const Text('Edit profile')),
      isLoading: _isSaving,
      loadingMessage: 'Saving profile…',
      loadingBlur: 6,
      // Blocks the back gesture while a save is in flight.
      canPop: !_isSaving,
      dismissKeyboardOnTap: true,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                'RP',
                style: BaseTextStyles.instance.bold.copyWith(
                  fontSize: 28,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Full name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save'),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap Save for the blurred loading overlay. Tap outside a field '
            'to dismiss the keyboard.',
            style: BaseTextStyles.instance.regular.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// `BaseStateView` driven by a segmented button, with pull-to-refresh.
class StatesDemo extends StatefulWidget {
  const StatesDemo({super.key});

  @override
  State<StatesDemo> createState() => _StatesDemoState();
}

class _StatesDemoState extends State<StatesDemo> {
  BaseViewState _state = BaseViewState.content;

  Future<void> _refresh() async {
    setState(() => _state = BaseViewState.loading);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _state = BaseViewState.content);
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      bodyAppBar: AppBar(
        title: const Text('Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SegmentedButton<BaseViewState>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: BaseViewState.loading,
                  label: Text('Loading'),
                ),
                ButtonSegment(value: BaseViewState.empty, label: Text('Empty')),
                ButtonSegment(value: BaseViewState.error, label: Text('Error')),
                ButtonSegment(
                  value: BaseViewState.content,
                  label: Text('Content'),
                ),
              ],
              selected: {_state},
              onSelectionChanged: (value) =>
                  setState(() => _state = value.first),
            ),
          ),
        ),
      ),
      body: BaseStateView(
        state: _state,
        emptyTitle: 'No orders yet',
        emptyMessage: 'When you place an order, it will show up here.',
        errorMessage: 'Check your connection and try again.',
        onRetry: _refresh,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: _orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _OrderTile(order: _orders[index]),
          ),
        ),
      ),
    );
  }
}

typedef _Order = ({String title, String status, String price, String color});

const List<_Order> _orders = [
  (title: 'Running shoes', status: 'Delivered', price: r'$89', color: '22C55E'),
  (
    title: 'Wireless earbuds',
    status: 'Shipped',
    price: r'$129',
    color: '3B82F6',
  ),
  (title: 'Coffee beans', status: 'Processing', price: r'$18', color: 'F59E0B'),
  (title: 'Desk lamp', status: 'Delivered', price: r'$45', color: '22C55E'),
  (title: 'Backpack', status: 'Cancelled', price: r'$64', color: 'EF4444'),
  (title: 'Notebook set', status: 'Shipped', price: r'$12', color: '3B82F6'),
];

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final _Order order;

  @override
  Widget build(BuildContext context) {
    final color = order.color.toColor();
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.shopping_bag_outlined, color: color),
        ),
        title: Text(order.title, style: BaseTextStyles.instance.semiBold),
        subtitle: Text(
          order.status,
          style: BaseTextStyles.instance.medium.copyWith(color: color),
        ),
        trailing: Text(order.price, style: BaseTextStyles.instance.bold),
      ),
    );
  }
}

/// `BaseTextStyles` weights and `HexColor` parsing.
class StylesDemo extends StatelessWidget {
  const StylesDemo({super.key});

  static const _palette = [
    '#4F46E5',
    '#06B6D4',
    '#22C55E',
    '#F59E0B',
    '#EF4444',
    '#EC4899',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final styles = BaseTextStyles.instance;
    final weights = [
      ('thin', 'w100', styles.thin),
      ('light', 'w300', styles.light),
      ('regular', 'w400', styles.regular),
      ('medium', 'w500', styles.medium),
      ('semiBold', 'w600', styles.semiBold),
      ('bold', 'w700', styles.bold),
      ('black', 'w900', styles.black),
    ];

    return BaseWidget(
      bodyAppBar: AppBar(title: const Text('Styles')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('BaseTextStyles', style: styles.bold),
          const SizedBox(height: 12),
          for (final (name, weight, style) in weights)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'The quick brown fox',
                      style: style.copyWith(fontSize: 20),
                    ),
                  ),
                  Text(
                    '.$name · $weight',
                    style: styles.regular.copyWith(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 28),
          Text('Hex colours', style: styles.bold),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final hex in _palette)
                Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: hex.toColor(),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("'$hex'", style: styles.medium.copyWith(fontSize: 11)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
