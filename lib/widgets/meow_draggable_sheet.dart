import 'package:flutter/material.dart';


/// Draggable Bottom Sheet seperti Meow Money Manager
/// Bisa di-slide unlimited ke atas, default 70% tinggi layar
class MeowDraggableSheet extends StatefulWidget {
  /// Content yang akan ditampilkan di dalam sheet
  final Widget child;

  /// Initial height ratio (default: 0.7 = 70%)
  final double initialChildSize;

  /// Minimum height ratio (default: 0.3 = 30%)
  final double minChildSize;

  /// Maximum height ratio (default: 1.0 = 100%)
  final double maxChildSize;

  /// Background color sheet
  final Color? backgroundColor;

  /// Border radius atas
  final double borderRadius;

  /// Header widget (tabs, dll) yang tetap di atas
  final Widget? header;
  const MeowDraggableSheet({
    Key? key,
    required this.child,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.25, // Allow more collapsing
    this.maxChildSize = 1.0,
    this.backgroundColor,
    this.borderRadius = 24.0,
    this.header,
  }) : super(key: key);

  @override
  State<MeowDraggableSheet> createState() => _MeowDraggableSheetState();
}

class _MeowDraggableSheetState extends State<MeowDraggableSheet> {
  DraggableScrollableController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    _controller ??= DraggableScrollableController();

    return DraggableScrollableSheet(
      controller: _controller!,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      expand: false,
      snap: true,
      snapSizes: [widget.minChildSize, widget.initialChildSize, widget.maxChildSize],
      builder: (context, scrollController) {
        
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(widget.borderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Draggable Handle Area - Enhanced for better touch response
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Safety checks
                  if (_controller == null || !_controller!.isAttached) return;

                  // Always allow resizing the sheet when dragging the handle
                  final currentSize = _controller!.size;
                  final sheetAtMax = currentSize >= widget.maxChildSize - 0.01;
                  final sheetAtMin = currentSize <= widget.minChildSize + 0.01;

                  if ((!sheetAtMax && details.delta.dy < 0) || // Dragging up when sheet not at max
                      (!sheetAtMin && details.delta.dy > 0)) {  // Dragging down when sheet not at min

                    // Resize the sheet
                    final screenHeight = MediaQuery.of(context).size.height;
                    final deltaRatio = -details.delta.dy / screenHeight;
                    final newSize = (currentSize + deltaRatio).clamp(widget.minChildSize, widget.maxChildSize);
                    if (_controller!.isAttached) {
                      _controller!.jumpTo(newSize);
                    }
                  }
                },
                onVerticalDragEnd: (details) {
                  // Safety checks
                  if (_controller == null || !_controller!.isAttached) return;

                  // Snap to nearest size when drag ends
                  final currentSize = _controller!.size;
                  final snapPoints = [widget.minChildSize, widget.initialChildSize, widget.maxChildSize];
                  final closest = snapPoints.reduce((a, b) =>
                      (currentSize - a).abs() < (currentSize - b).abs() ? a : b);
                  _controller!.animateTo(
                    closest,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 100, // Even larger touch area
                  padding: const EdgeInsets.only(top: 20, bottom: 12),
                  child: Column(
                    children: [
                      // Paw Icon
                      Icon(
                        Icons.pets,
                        size: 36, // Larger icon
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      // Drag Indicator Bar - More prominent
                      Container(
                        width: 80,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header (tabs, dll) - jika ada
              if (widget.header != null) widget.header!,

              // Content Area - Direct child without SingleChildScrollView wrapper
              // TabBarView and other content will handle their own scrolling
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Wrapper untuk menggunakan MeowDraggableSheet di page
/// Gunakan ini untuk wrap page content Anda
class MeowPageWithSheet extends StatelessWidget {
  /// Content di belakang sheet (akan tertutup)
  final Widget background;

  /// Header content (tabs, dll) yang tetap di atas sheet
  final Widget? sheetHeader;

  /// Content di dalam draggable sheet (scrollable)
  final Widget sheetContent;

  /// Sheet configuration
  final double initialSize;
  final double minSize;
  final Color? sheetColor;
  const MeowPageWithSheet({
    Key? key,
    required this.background,
    this.sheetHeader,
    required this.sheetContent,
    this.initialSize = 0.7,
    this.minSize = 0.25, // Allow more collapsing
    this.sheetColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background content (tertutup oleh sheet)
          background,

          // Draggable Sheet
          MeowDraggableSheet(
            initialChildSize: initialSize,
            minChildSize: minSize,
            backgroundColor: sheetColor,
            header: sheetHeader,
            child: sheetContent,
          ),
        ],
      ),
    );
  }
}

// ============================================
// CONTOH PENGGUNAAN
// ============================================

/// Example Page 1: Home dengan Tabs
class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MeowPageWithSheet(
      // Background yang akan tertutup
      background: Container(
        color: Colors.blue[100],
        child: const Center(
          child: Text('Background Content'),
        ),
      ),

      // Content dalam sheet
      sheetContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Home Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Tabs atau fitur Anda
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.black,
                  tabs: [
                    Tab(text: 'Expenses'),
                    Tab(text: 'Income'),
                    Tab(text: 'Budget'),
                  ],
                ),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      _buildExpensesList(),
                      _buildIncomeList(),
                      _buildBudgetList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.shopping_cart),
          title: Text('Expense ${index + 1}'),
          subtitle: const Text('Category'),
          trailing: const Text('-\$50'),
        );
      },
    );
  }

  Widget _buildIncomeList() {
    return const Center(child: Text('Income List'));
  }

  Widget _buildBudgetList() {
    return const Center(child: Text('Budget List'));
  }

}

/// Example Page 2: Statistics
class ExampleStatsPage extends StatelessWidget {
  const ExampleStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MeowPageWithSheet(
      background: Container(
        color: Colors.purple[100],
        child: const Center(child: Text('Stats Background')),
      ),
      sheetContent: Column(
        children: [
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Chart atau statistik Anda di sini
          Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: Text('Chart Placeholder')),
          ),
          const SizedBox(height: 20),
          // List data statistik
          ...List.generate(5, (index) {
            return Card(
              child: ListTile(
                title: Text('Category ${index + 1}'),
                trailing: Text('\$${(index + 1) * 100}'),
              ),
            );
          }),
        ],
      ),
      sheetColor: Colors.white,
      initialSize: 0.7,
    );
  }

}

// ============================================
// CARA PAKAI DI APP ANDA
// ============================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meow Draggable Sheet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
      // Atau gunakan dengan navigation
      // home: NavigationExample(),
    );
  }
}

/// Contoh dengan Bottom Navigation
class NavigationExample extends StatefulWidget {
  const NavigationExample({Key? key}) : super(key: key);

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ExampleHomePage(),
    const ExampleStatsPage(),
    // Tambahkan page lain di sini
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
