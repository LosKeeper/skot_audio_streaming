import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class CurrentSongCard extends StatelessWidget {
  final String currentSong;
  final String currentArtist;
  final bool isPlaying;
  final Function pauseAudio;
  final Function playAudio;
  final double currentPosition;
  final double maxDuration;
  final String urlCurrentSong;
  final String urlCurrentCover;
  final Color? dominantColor;
  final Function changeCurrentIndex;
  final Color? textColor;

  CurrentSongCard({
    required this.currentSong,
    required this.currentArtist,
    required this.isPlaying,
    required this.pauseAudio,
    required this.playAudio,
    required this.currentPosition,
    required this.maxDuration,
    required this.urlCurrentSong,
    required this.urlCurrentCover,
    required this.dominantColor,
    required this.changeCurrentIndex,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
      ),
      height: 80,
      child: InkWell(
        onTap: () => changeCurrentIndex(3),
        child: Card(
          color: (dominantColor ?? Colors.green).withOpacity(0.5),
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
                          image: (urlCurrentCover).isNotEmpty
                              ? Image.network(urlCurrentCover).image
                              : const AssetImage(
                                  'assets/images/default_cover.png'),
                          width: 72,
                          height: 72,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            currentArtist,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed:
                        isPlaying ? () => pauseAudio() : () => playAudio(),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ProgressBar(
                    progress: Duration(milliseconds: currentPosition.toInt()),
                    total: Duration(milliseconds: maxDuration.toInt()),
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
