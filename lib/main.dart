import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, scale) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48 * scale,
                height: 48 * scale,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                  boxShadow: scale > 1
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    e,
                    color: Colors.white,
                    size: 24 * scale,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item with its scale.
  final Widget Function(T, double scale) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// Index of the currently active drag.
  int? _activeDragIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isActive = _activeDragIndex == index;
          final scale = _activeDragIndex != null
              ? _getScaleForIndex(index)
              : 1.0; // Scale nearby items.

          return GestureDetector(
            key: ValueKey(item),
            onLongPressStart: (_) {
              setState(() => _activeDragIndex = index);
            },
            onLongPressMoveUpdate: (details) {
              _updatePosition(details.localPosition.dx, index);
            },
            onLongPressEnd: (_) {
              setState(() => _activeDragIndex = null);
            },
            child: widget.builder(item, scale),
          );
        }),
      ),
    );
  }

  /// Calculate scale based on distance from active item.
  double _getScaleForIndex(int index) {
    if (_activeDragIndex == null) return 1.0;

    final distance = (index - _activeDragIndex!).abs();
    if (distance == 0) return 1.5; // Active item.
    if (distance == 1) return 1.2; // Nearby item.
    return 1.0; // Other items.
  }

  /// Update the position of items based on drag.
  void _updatePosition(double dx, int currentIndex) {
    final newIndex = (dx / 56).clamp(0, _items.length - 1).toInt();
    if (newIndex != currentIndex) {
      setState(() {
        final item = _items.removeAt(currentIndex);
        _items.insert(newIndex, item);
        _activeDragIndex = newIndex;
      });
    }
  }
}
