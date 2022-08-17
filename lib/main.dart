// ignore_for_file: unnecessary_const

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:music_app/albums.dart';
import 'package:music_app/home.dart';
import 'package:music_app/songs.dart';
import 'package:flutter/services.dart';
import 'package:miniplayer/miniplayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
      ),
      home: const MyHomePage(
        title: 'Musiques',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  static const double _playerHeight = 70.0;
  int _selectedIndex = 0;
  int selectedSong = 1;
  final _pageList = [const Home(), const Songs(), const Albums()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      selectedSong = 1;
    });
  }

  final ValueNotifier<double> playerExpandProgress =
      ValueNotifier(_playerHeight);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: _pageList
              .asMap()
              .map((i, screen) => MapEntry(
                    i,
                    Offstage(
                      offstage: _selectedIndex != i,
                      child: screen,
                    ),
                  ))
              .values
              .toList()
            ..add(Offstage(
              offstage: selectedSong == 0,
              child: Miniplayer(
                  onDismiss: () => setState(() {
                        selectedSong = 0;
                      }),
                  valueNotifier: playerExpandProgress,
                  minHeight: _playerHeight,
                  maxHeight: MediaQuery.of(context).size.height,
                  builder: (height, percentage) {
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          color: darkDynamic?.secondary.withOpacity(0.4) ??
                              lightDynamic?.secondary.withOpacity(0.4)),
                      child: Center(child: Text('$height $percentage')),
                    );
                  }),
            )),
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
              backgroundColor: darkDynamic?.secondary.withOpacity(0.3) ??
                  lightDynamic?.secondary.withOpacity(0.3),
              labelTextStyle: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  );
                }
                return const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                );
              }),
              indicatorColor: darkDynamic?.primary.withOpacity(0.3) ??
                  lightDynamic?.primary.withOpacity(0.3)),
          child: NavigationBar(
            animationDuration: const Duration(seconds: 1),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home, color: Colors.black, size: 25),
                  label: "Home"),
              NavigationDestination(
                  icon: Icon(Icons.music_note, color: Colors.black, size: 25),
                  label: "Songs"),
              NavigationDestination(
                icon: Icon(Icons.disc_full, color: Colors.black, size: 25),
                label: "Albums",
              ),
              NavigationDestination(
                  icon: Icon(Icons.person, color: Colors.black, size: 25),
                  label: "Artists"),
              NavigationDestination(
                  icon: Icon(Icons.playlist_add, color: Colors.black, size: 25),
                  label: "Playlists"),
            ],
            onDestinationSelected: (index) => _onItemTapped(index),
            selectedIndex: _selectedIndex,
          ),
        ),
      );
    });
  }
}
