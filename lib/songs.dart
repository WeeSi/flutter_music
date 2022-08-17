import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_app/albums.dart';
import 'package:music_app/search.dart';
import 'package:music_app/settings.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class Songs extends StatefulWidget {
  const Songs({Key? key}) : super(key: key);

  @override
  State<Songs> createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  final OnAudioQuery _audioQuery = OnAudioQuery();
  int _selectedIndex = 0;
  final player = AudioPlayer();
  bool isPlaying = false;

  void requestStoragePermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }

      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    player.dispose();

    super.dispose();
  }

  playAudio(item) async {
    await player.setFilePath(item.data);
    await player.play();
  }

  void _navigateToSearchScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SearchScreen()));
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Settings()));
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                  onPressed: (() => {_navigateToSearchScreen(context)}),
                  icon: const Icon(Icons.search)),
              PopupMenuButton(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  color: darkDynamic?.secondary ?? lightDynamic?.secondary,
                  enabled: true,
                  onSelected: (value) {
                    if (value == 2) {
                      _navigateToSettings(context);
                    }
                  },
                  itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 1,
                          child: Text("First"),
                        ),
                        const PopupMenuItem(
                          value: 2,
                          child: Text("Settings"),
                        ),
                      ])
            ],
            title: const Text('Musiques'),
          ),
          body: FutureBuilder<List<SongModel>>(
            future: _audioQuery.querySongs(
                sortType: null,
                orderType: OrderType.DESC_OR_GREATER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true),
            builder: (context, item) {
              if (item.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (item.data!.isEmpty) {
                return const Center(
                  child: Text("No songs found"),
                );
              }

              return ListView.builder(
                  itemCount: item.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        item.data![index].title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      subtitle: Text(item.data![index].artist.toString()),
                      trailing: const Icon(Icons.more_vert),
                      leading: QueryArtworkWidget(
                          id: item.data![index].id, type: ArtworkType.AUDIO),
                      onTap: () {
                        playAudio(item.data![index]);
                      },
                    );
                  });
            },
          ));
    });
  }
}
