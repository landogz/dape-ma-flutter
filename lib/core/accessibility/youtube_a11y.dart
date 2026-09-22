import 'package:youtube_player_flutter/youtube_player_flutter.dart';

YoutubePlayerFlags buildYoutubeFlags({
  required bool enableCaptions,
  bool autoPlay = false,
  bool mute = false,
}) {
  return YoutubePlayerFlags(
    autoPlay: autoPlay,
    mute: mute,
    enableCaption: enableCaptions,
    captionLanguage: 'en',
  );
}
