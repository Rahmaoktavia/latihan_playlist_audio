import 'package:flutter/material.dart';
import 'package:latihan_playlist_audio/model/model_audio.dart';
import 'package:latihan_playlist_audio/screen_page/audio_player_page.dart';
import 'package:latihan_playlist_audio/screen_page/favorite_audio.dart';

class PageBottomNavigationBar extends StatefulWidget {
  @override
  _PageBottomNavigationBarState createState() => _PageBottomNavigationBarState();
}

class _PageBottomNavigationBarState extends State<PageBottomNavigationBar> {
  int _currentIndex = 0;
  List<Datum> _favoriteAudioList = [];

  void _updateFavoriteList(List<Datum> newFavoriteList) {
    setState(() {
      _favoriteAudioList = newFavoriteList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          PageLatAudio(updateFavoriteList: _updateFavoriteList, favoriteAudioList: _favoriteAudioList),
          PageFavoriteAudio(favoriteAudioList: _favoriteAudioList, updateFavoriteList: _updateFavoriteList),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Music',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
      ),
    );
  }
}
