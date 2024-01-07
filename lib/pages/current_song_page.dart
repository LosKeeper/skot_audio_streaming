import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:spartacus_project/audio_player_controller.dart';

class CurrentSongPage extends StatefulWidget {
  final AudioPlayerController audioPlayerController;
  final double position;

  const CurrentSongPage({
    super.key,
    required this.audioPlayerController,
    required this.position,
  });

  @override
  _CurrentSongPageState createState() => _CurrentSongPageState();
}

class _CurrentSongPageState extends State<CurrentSongPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.audioPlayerController.currentSong,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                widget.audioPlayerController.currentArtist,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Image(
                    image: widget.audioPlayerController.currentCover,
                  ),
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
                            milliseconds: widget
                                .audioPlayerController.currentPosition
                                .toInt()),
                        buffered: Duration(
                            milliseconds: widget
                                .audioPlayerController.bufferedPosition
                                .toInt()),
                        total: Duration(
                            milliseconds: widget
                                .audioPlayerController.maxDuration
                                .toInt()),
                        onSeek: (duration) {
                          widget.audioPlayerController.player.seek(duration);
                          setState(() {
                            widget.audioPlayerController.changeCurrentPosition(
                                duration.inMilliseconds.toDouble());
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(widget.audioPlayerController.player.playing
                    ? Icons.pause
                    : Icons.play_arrow),
                onPressed: widget.audioPlayerController.player.playing
                    ? () => widget.audioPlayerController.pause()
                    : () => widget.audioPlayerController.play(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
