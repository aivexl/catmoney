import 'package:flutter/material.dart';



/// Draggable Bottom Sheet seperti Meow Money Manager

/// Bisa di-slide unlimited ke atas, default 70% tinggi layar

class MeowDraggableSheet extends StatefulWidget {

  /// Content yang akan ditampilkan di dalam sheet

  final Widget child;



  /// Initial height ratio (default: 0.7 = 70%)

  final double initialChildSize;



  /// Minimum height ratio (default: 0.7 = 70%)

  final double minChildSize;



  /// Maximum height ratio (default: 1.0 = 100%)

  final double maxChildSize;



  /// Background color sheet

  final Color? backgroundColor;



  /// Border radius atas

  final double borderRadius;

  const MeowDraggableSheet({

    Key? key,

    required this.child,

    this.initialChildSize = 0.7,

    this.minChildSize = 0.7,

    this.maxChildSize = 1.0,

    this.backgroundColor,

    this.borderRadius = 24.0,

  }) : super(key: key);

  @override

  State<MeowDraggableSheet> createState() => _MeowDraggableSheetState();

}

class _MeowDraggableSheetState extends State<MeowDraggableSheet> {

  @override

  Widget build(BuildContext context) {

    return DraggableScrollableSheet(

      initialChildSize: widget.initialChildSize,

      minChildSize: widget.minChildSize,

      maxChildSize: widget.maxChildSize,

      builder: (context, scrollController) {

        return Container(

          decoration: BoxDecoration(

            color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,

            borderRadius: BorderRadius.vertical(

              top: Radius.circular(widget.borderRadius),

            ),

            boxShadow: [

              BoxShadow(

                color: Colors.black.withOpacity(0.1),

                blurRadius: 10,

                offset: const Offset(0, -5),

              ),

            ],

          ),

          child: Column(

            children: [

              // Handle dengan Paw Icon

              GestureDetector(

                onVerticalDragUpdate: (details) {

                  // Bisa tambahkan haptic feedback di sini

                },

                child: Container(

                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(vertical: 16),

                  child: Column(

                    children: [

                      // Paw Icon

                      Icon(

                        Icons.pets,

                        size: 28,

                        color: Colors.grey[400],

                      ),

                      const SizedBox(height: 8),

                      // Drag Indicator Bar

                      Container(

                        width: 40,

                        height: 4,

                        decoration: BoxDecoration(

                          color: Colors.grey[300],

                          borderRadius: BorderRadius.circular(2),

                        ),

                      ),

                    ],

                  ),

                ),

              ),



              // Content Area (Scrollable)

              Expanded(

                child: ListView(

                  controller: scrollController,

                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  children: [

                    widget.child,

                  ],

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



  /// Content di dalam draggable sheet

  final Widget sheetContent;



  /// Sheet configuration

  final double initialSize;

  final double minSize;

  final Color? sheetColor;

  const MeowPageWithSheet({

    Key? key,

    required this.background,

    required this.sheetContent,

    this.initialSize = 0.7,

    this.minSize = 0.7,

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