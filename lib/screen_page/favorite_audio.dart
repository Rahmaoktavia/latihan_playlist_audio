import 'package:flutter/material.dart';
import 'package:latihan_playlist_audio/model/model_audio.dart';

class PageFavoriteAudio extends StatefulWidget {
  final List<Datum> favoriteAudioList;
  final Function(List<Datum>) updateFavoriteList;

  const PageFavoriteAudio({Key? key, required this.favoriteAudioList, required this.updateFavoriteList}) : super(key: key);

  @override
  _PageFavoriteAudioState createState() => _PageFavoriteAudioState();
}

class _PageFavoriteAudioState extends State<PageFavoriteAudio> {
  void _removeFavorite(int index) {
    setState(() {
      widget.favoriteAudioList.removeAt(index);
      widget.updateFavoriteList(widget.favoriteAudioList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
      ),
      body: widget.favoriteAudioList.isEmpty
          ? const Center(
        child: Text('No favorite songs yet.'),
      )
          : ListView.builder(
        itemCount: widget.favoriteAudioList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(
              'http://192.168.156.142/playlist_audio/gambar/${widget.favoriteAudioList[index].gambar}',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(widget.favoriteAudioList[index].judulAudio),
            subtitle: Text(widget.favoriteAudioList[index].penyanyi),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeFavorite(index),
            ),
          );
        },
      ),
    );
  }
}
