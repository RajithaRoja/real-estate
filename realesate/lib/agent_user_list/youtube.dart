import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realesate/constant/app.colors.dart';
import 'package:realesate/constant/app.strings.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoTourSection extends StatelessWidget {
  final String youtubeUrl;

  const VideoTourSection({super.key, required this.youtubeUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            bool isPortrait =
                MediaQuery.of(context).orientation == Orientation.portrait;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: SizedBox(
                width: isPortrait
                    ? MediaQuery.of(context).size.width *
                        0.9 // 90% width in portrait
                    : MediaQuery.of(context).size.width *
                        0.95, // 95% width in landscape
                height: isPortrait
                    ? MediaQuery.of(context).size.height *
                        0.7 // 70% height in portrait
                    : MediaQuery.of(context).size.height *
                        0.85, // 85% height in landscape
                child: VideoPopup(youtubeUrl: youtubeUrl),
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/images/youtube.svg",
            ),
            const SizedBox(width: 5),
            Text(
              AppStrings.videoAvailable,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey),
            ),
          ],
        ),
      ),
    );
  }
}

// Popup Video Player
class VideoPopup extends StatelessWidget {
  final String youtubeUrl;

  const VideoPopup({super.key, required this.youtubeUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Expanded(
          // 🔥 This makes the video take full height & width!
          child: AspectRatio(
            aspectRatio: 16 / 9, // Standard YouTube video ratio
            child: YouTubePlayerScreen(youtubeUrl: youtubeUrl),
          ),
        ),
      ],
    );
  }
}

class YouTubePlayerScreen extends StatefulWidget {
  final String youtubeUrl;

  const YouTubePlayerScreen({super.key, required this.youtubeUrl});

  @override
  _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? "";
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
