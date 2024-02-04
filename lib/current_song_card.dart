import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:skot/audio_player_controller.dart';

class CurrentSongCard extends StatelessWidget {
  final AudioPlayerController audioPlayerController;
  final Function changeCurrentIndex;
  final double position;

  const CurrentSongCard({
    super.key,
    required this.audioPlayerController,
    required this.changeCurrentIndex,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: () => changeCurrentIndex(3),
        child: Card(
          color: (audioPlayerController.dominantColor ?? Colors.green)
              .withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image(
                          image: audioPlayerController.currentCover,
                          width: 72,
                          height: 72,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audioPlayerController.currentSong,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: audioPlayerController.textColor,
                            ),
                          ),
                          Text(
                            audioPlayerController.currentArtist,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: audioPlayerController.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(audioPlayerController.player.playing
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: audioPlayerController.player.playing
                        ? () => audioPlayerController.pause()
                        : () => audioPlayerController.play(),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ProgressBar(
                    progress: Duration(
                        milliseconds:
                            audioPlayerController.currentPosition.toInt()),
                    total: Duration(
                        milliseconds:
                            audioPlayerController.maxDuration.toInt()),
                    thumbRadius: 0,
                    thumbGlowRadius: 0,
                    barHeight: 2,
                    timeLabelLocation: TimeLabelLocation.none,
                    baseBarColor: Colors.white54,
                    progressBarColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
