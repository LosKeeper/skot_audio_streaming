import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class CurrentSongPage extends StatefulWidget {
  final String currentSong;
  final double currentPosition;
  final double bufferedPosition;
  final double maxDuration;
  final Map<String, dynamic> jsonAvailableSongs;
  final Function playAudio;
  final Function pauseAudio;
  final Function initAudio;
  final dynamic player;
  final Function changeCurrentSong;
  final Function changeCurrentPosition;
  final bool isPlaying;
  final String urlCurrentCover;

  CurrentSongPage({
    Key? key,
    required this.currentSong,
    required this.jsonAvailableSongs,
    required this.playAudio,
    required this.pauseAudio,
    required this.initAudio,
    required this.player,
    required this.currentPosition,
    required this.bufferedPosition,
    required this.maxDuration,
    required this.changeCurrentSong,
    required this.changeCurrentPosition,
    required this.isPlaying,
    required this.urlCurrentCover,
  }) : super(key: key);

  @override
  _CurrentSongPageState createState() => _CurrentSongPageState();
}

class _CurrentSongPageState extends State<CurrentSongPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: widget.currentSong,
              onChanged: (String? newValue) {
                if (newValue != null && newValue != widget.currentSong) {
                  setState(() {
                    widget.changeCurrentSong(newValue);
                  });
                }
              },
              items: widget.jsonAvailableSongs != {}
                  ? widget.jsonAvailableSongs.keys
                      .toList()
                      .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                  : [],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Image(
                image: (widget.urlCurrentCover).isNotEmpty
                    ? Image.network(widget.urlCurrentCover).image
                    : const AssetImage('assets/images/default_cover.png'),
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: ProgressBar(
                      progress: Duration(
                          milliseconds: widget.currentPosition.toInt()),
                      buffered: Duration(
                          milliseconds: widget.bufferedPosition.toInt()),
                      total: Duration(milliseconds: widget.maxDuration.toInt()),
                      onSeek: (duration) {
                        widget.player.seek(duration);
                        setState(() {
                          widget.changeCurrentPosition(
                              duration.inMilliseconds.toDouble());
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: widget.isPlaying
                  ? () => widget.pauseAudio()
                  : () => widget.playAudio(),
            ),
          ],
        ),
      ),
    );
  }
}
