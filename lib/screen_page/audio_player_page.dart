import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:latihan_playlist_audio/model/model_audio.dart';

enum PlayerState { stopped, playing, paused }

class PageLatAudio extends StatefulWidget {
  final Function(List<Datum>) updateFavoriteList;
  final List<Datum> favoriteAudioList;

  const PageLatAudio({Key? key, required this.updateFavoriteList, required this.favoriteAudioList}) : super(key: key);

  @override
  State<PageLatAudio> createState() => _PageLatAudioState();
}

class _PageLatAudioState extends State<PageLatAudio> {
  List<Datum> _audioList = [];
  bool _isLoading = true;
  final List<AudioPlayer> _audioPlayers = [];
  final List<PlayerState> _playerStates = [];
  final Set<int> _favoriteIndexes = Set<int>();

  @override
  void initState() {
    super.initState();
    _fetchAudioData();
    _syncFavoriteIndexes();
  }

  @override
  void didUpdateWidget(PageLatAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFavoriteIndexes();
  }

  Future<void> _fetchAudioData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.156.142/playlist_audio/getAudio.php'));

      if (response.statusCode == 200) {
        final modelAudio = modelAudioFromJson(response.body);
        if (modelAudio.isSuccess && modelAudio.data.isNotEmpty) {
          setState(() {
            _audioList = modelAudio.data;
            for (int i = 0; i < _audioList.length; i++) {
              _audioPlayers.add(AudioPlayer());
              _playerStates.add(PlayerState.stopped);
            }
            _syncFavoriteIndexes();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load audio data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching audio data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _syncFavoriteIndexes() {
    _favoriteIndexes.clear();
    for (var audio in widget.favoriteAudioList) {
      int index = _audioList.indexWhere((element) => element.id == audio.id);
      if (index != -1) {
        _favoriteIndexes.add(index);
      }
    }
  }

  void _play(int index) async {
    final audioUrl = 'http://192.168.156.142/playlist_audio/audio_file/${_audioList[index].audioFile}';
    try {
      final result = await _audioPlayers[index].play(audioUrl);
      if (result == 1) {
        setState(() => _playerStates[index] = PlayerState.playing);
      } else {
        print('Error while playing audio: $result');
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _pause(int index) async {
    try {
      final result = await _audioPlayers[index].pause();
      if (result == 1) {
        setState(() => _playerStates[index] = PlayerState.paused);
      } else {
        print('Error while pausing audio: $result');
      }
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  void _stop(int index) async {
    try {
      final result = await _audioPlayers[index].stop();
      if (result == 1) {
        setState(() => _playerStates[index] = PlayerState.stopped);
      } else {
        print('Error while stopping audio: $result');
      }
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  void _toggleFavorite(int index) {
    setState(() {
      if (_favoriteIndexes.contains(index)) {
        _favoriteIndexes.remove(index);
        widget.favoriteAudioList.removeWhere((element) => element.id == _audioList[index].id);
      } else {
        _favoriteIndexes.add(index);
        widget.favoriteAudioList.add(_audioList[index]);
      }
      widget.updateFavoriteList(widget.favoriteAudioList);
    });
  }

  @override
  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Albums',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _audioList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle when album is tapped
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(
                                  'http://192.168.156.142/playlist_audio/gambar/${_audioList[index].gambar}',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _audioList[index].judulAudio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _audioList[index].penyanyi,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'For you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _audioList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(16.0),
                  elevation: 4,
                  child: ListTile(
                    leading: Image.network(
                      'http://192.168.156.142/playlist_audio/gambar/${_audioList[index].gambar}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      _audioList[index].judulAudio,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_audioList[index].penyanyi),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: _playerStates[index] == PlayerState.playing ? null : () => _play(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.pause),
                          onPressed: _playerStates[index] == PlayerState.playing ? () => _pause(index) : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: _playerStates[index] == PlayerState.playing || _playerStates[index] == PlayerState.paused ? () => _stop(index) : null,
                        ),
                        IconButton(
                          icon: _favoriteIndexes.contains(index) ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
                          onPressed: () => _toggleFavorite(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
