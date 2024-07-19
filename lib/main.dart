import 'package:flutter/material.dart';
import 'package:google_next_imagen_demo/screens/copy_writing.dart';
import 'package:google_next_imagen_demo/screens/edit_image.dart';
import 'screens/generate_image.dart';

// 一瞬文字化けするのは日本語のせい
// https://gaprot.jp/2022/03/28/flutter_dev_bugfix_text/

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeStatefulWidget(),
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue)),
    );
  }
}

class HomeStatefulWidget extends StatefulWidget {
  const HomeStatefulWidget({super.key});

  @override
  State<HomeStatefulWidget> createState() => _HomeStatefulWidgetState();
}

class _HomeStatefulWidgetState extends State<HomeStatefulWidget> {
  static const List<Widget> _screens = [
    GenerateImage(),
    EditImage(),
    CopyWriting(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.image), label: 'Generate Image'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Image Edit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat), label: 'Copy Writing'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
