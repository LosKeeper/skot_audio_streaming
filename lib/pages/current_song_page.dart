import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:skot/audio_player_controller.dart';

class CurrentSongPage extends StatefulWidget {
  final AudioPlayerController audioPlayerController;
  final double position;
  final Function addToFavorites;
  final Function removeFromFavorites;
  final List<String> favorites;

  const CurrentSongPage({
    super.key,
    required this.audioPlayerController,
    required this.position,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.favorites,
  });

  @override
  // ignore: library_private_types_in_public_api
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 30,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      widget.audioPlayerController.skipToPrevious();
                    },
                  ),
                  const SizedBox(width: 50),
                  IconButton(
                    iconSize: 30,
                    icon: Icon(widget.audioPlayerController.player.playing
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: widget.audioPlayerController.player.playing
                        ? () => widget.audioPlayerController.pause()
                        : () => widget.audioPlayerController.play(),
                  ),
                  const SizedBox(width: 50),
                  IconButton(
                    iconSize: 30,
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      widget.audioPlayerController.skipToNext();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 30,
                    icon: widget.audioPlayerController.getRandom()
                        ? const Icon(Icons.shuffle_on_outlined)
                        : const Icon(Icons.shuffle_rounded),
                    onPressed: () {
                      widget.audioPlayerController.changeRandom();
                    },
                  ),
                  const SizedBox(width: 50),
                  IconButton(
                    iconSize: 30,
                    icon: widget.favorites
                            .contains(widget.audioPlayerController.currentSong)
                        ? const Icon(Icons.favorite)
                        : const Icon(Icons.favorite_border),
                    onPressed: () {
                      if (widget.favorites
                          .contains(widget.audioPlayerController.currentSong)) {
                        widget.removeFromFavorites(
                            widget.audioPlayerController.currentSong);
                      } else {
                        widget.addToFavorites(
                            widget.audioPlayerController.currentSong);
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
