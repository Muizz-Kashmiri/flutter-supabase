import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_learn/constants.dart';
import 'package:supabase_learn/database.dart';
import 'package:supabase_learn/homepage.dart';
import 'package:supabase_learn/realtime.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.anonKey,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _pageList = {
    'HomePage': const MyHomePage(),
    'Database': const DatabasePage(),
    'Realtime': const RealtimePage(),
  };
  var _currentIndex = 0;
  final supabase = Supabase.instance.client;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 37, 35, 40)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Supabase Flutter Demo'),
        ),
        body: _pageList.values.elementAt(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HomePage',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Database',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Realtime',
            ),
          ],
        ),
      ),
    );
  }
}
