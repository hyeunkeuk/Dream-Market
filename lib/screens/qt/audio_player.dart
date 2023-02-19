import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QTAudio extends StatefulWidget {
  @override
  State<QTAudio> createState() => _QTAudioState();
}

class _QTAudioState extends State<QTAudio> {
  int maxduration = 100;

  int currentpos = 0;

  String currentpostlabel = "00:00";

  bool isplaying = false;

  bool audioplayed = false;

  bool isMute = true;

  Uint8List audiobytes;

  // final AudioCache qtAudio = AudioCache();
  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await player.setSource(AssetSource('audio/qt_audio.mp3'));
      player.onDurationChanged.listen((Duration d) {
        //get the duration of audio
        maxduration = d.inMilliseconds;
        setState(() {});
      });
      player.onPositionChanged.listen((Duration p) {
        currentpos =
            p.inMilliseconds; //get the current position of playing audio

        //generating the duration label
        int shours = Duration(milliseconds: currentpos).inHours;
        int sminutes = Duration(milliseconds: currentpos).inMinutes;
        int sseconds = Duration(milliseconds: currentpos).inSeconds;

        int rhours = shours;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        currentpostlabel = "$rminutes:$rseconds";

        setState(() {
          //refresh the UI
        });
      });
      isMute ? player.stop() : player.resume();
      // isMute ? player.setVolume(0.0) : player.setVolume(1.0);
    });
    super.initState();
  }

  @override
  void dispose() {
    // print('dispose called');
    player.stop();
    super.dispose();
  }

  void stopAudio() async {}

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        isMute = !isMute;
        isMute ? player.stop() : player.resume();

        // isMute ? player.setVolume(0.0) : player.setVolume(1.0);
      },
      icon: isMute ? Icon(Icons.volume_off) : Icon(Icons.volume_up),
    );
    // return Container(
    //   margin: EdgeInsets.only(top: 50),
    //   child: Column(
    //     children: [
    //       Container(
    //         child: Text(
    //           currentpostlabel,
    //           style: TextStyle(fontSize: 25),
    //         ),
    //       ),
    //       Slider(
    //         value: double.parse(currentpos.toString()),
    //         min: 0,
    //         max: double.parse(maxduration.toString()),
    //         divisions: maxduration,
    //         label: currentpostlabel,
    //         onChanged: (double value) async {
    //           int seekval = value.round();
    //           await player
    //               .seek(Duration(milliseconds: seekval))
    //               .then((value) => currentpos = seekval)
    //               .catchError(() {
    //             print("Seek unsuccessful.");
    //           });
    //         },
    //       ),
    //       Wrap(
    //         spacing: 10,
    //         children: [
    //           ElevatedButton.icon(
    //             onPressed: () async {
    //               if (!isplaying && !audioplayed) {
    //                 await player.resume().then((value) {
    //                   setState(() {
    //                     isplaying = true;
    //                     audioplayed = true;
    //                   });
    //                 }).catchError(() {
    //                   print("Error while playing audio.");
    //                 });
    //               } else if (audioplayed && !isplaying) {
    //                 await player.resume().then((value) {
    //                   setState(() {
    //                     isplaying = true;
    //                     audioplayed = true;
    //                   });
    //                 }).catchError(() {
    //                   print("Error on resume audio.");
    //                 });
    //               } else {
    //                 await player.pause().then((value) {
    //                   setState(() {
    //                     isplaying = false;
    //                   });
    //                 }).catchError(() {
    //                   print("Error on pause audio.");
    //                 });
    //               }
    //             },
    //             icon: Icon(isplaying ? Icons.pause : Icons.play_arrow),
    //             label: Text(isplaying ? "Pause" : "Play"),
    //           ),
    //           ElevatedButton.icon(
    //             onPressed: () async {
    //               await player.stop().then((value) {
    //                 setState(() {
    //                   isplaying = false;
    //                   audioplayed = false;
    //                   currentpos = 0;
    //                 });
    //               }).catchError(() {
    //                 print("Error on stop audio.");
    //               });
    //             },
    //             icon: Icon(Icons.stop),
    //             label: Text("Stop"),
    //           ),
    //           IconButton(
    //             onPressed: () {
    //               isMute = !isMute;

    //               isMute ? player.setVolume(0.0) : player.setVolume(1.0);
    //             },
    //             icon: isMute ? Icon(Icons.volume_off) : Icon(Icons.volume_up),
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}
