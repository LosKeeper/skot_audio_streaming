import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

String url = 'http://192.168.1.42';

class SongCard extends StatelessWidget {
  final String currentSong;
  final bool isPlaying;
  final Function pauseAudio;
  final Function playAudio;
  final double currentPosition;
  final double maxDuration;
  final Color? dominantColor;

  SongCard({
    required this.currentSong,
    required this.isPlaying,
    required this.pauseAudio,
    required this.playAudio,
    required this.currentPosition,
    required this.maxDuration,
    this.dominantColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
      ),
      height: 80,
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
                        image: NetworkImage(
                          url + '/audio/lkp/erratic/cover.png',
                        ),
                        width: 72,
                        height: 72,
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'LKP',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: isPlaying ? () => pauseAudio() : () => playAudio(),
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
    );
  }
}
