import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContentPage extends StatefulWidget {
  final String pageName;

  const ContentPage({super.key, required this.pageName});

  @override
  State<StatefulWidget> createState() {
    return ContentPageState();
  }
}

class ContentPageState extends State<ContentPage>
    with SingleTickerProviderStateMixin {
  Alignment alignment = Alignment.centerLeft;

  //list view
  List<String> musicList = [];
  Future<void> loadMusicFiles() async {
    String jsonString = await rootBundle.loadString('assets/json/musics.json');
    final jsonData = json.decode(jsonString);
    setState(() {
      musicList = List<String>.from(jsonData['musicList']);
    });
  }

  //audio player
  final audioPlayer = AudioPlayer();
  bool isPlay = false;
  bool isStop = true;
  int currentIndex = 0;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  PlayerState status = PlayerState.playing;

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  String playerStateToString(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        return 'PlayerState.playing';
      case PlayerState.paused:
        return 'PlayerState.paused';
      case PlayerState.stopped:
        return 'PlayerState.stopped';
      default:
        return 'Unknown';
    }
  }

  Future setAudio(String musicName) async {

    String path = 'musics/$musicName';
    await audioPlayer.setSource(AssetSource(path));
  }

  void playMusic(int index) {
    String musicPath = 'musics/' + musicList[index];
    audioPlayer.play(AssetSource(musicPath));
    setState(() {
      currentIndex = index;
    });
  }
  void playNextSong() {
    int nextIndex = currentIndex + 1;
    if(nextIndex < musicList.length){
      playMusic(nextIndex);
    } else {
      audioPlayer.stop();
      print('Đã phát hết nhạc trong danh sách');
    }
  }


  @override
  void initState() {
    super.initState();
    loadMusicFiles();
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      print('Current player state: $s');
      setState(() {
        status = s;
        isPlay = s == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() => duration = d);
    });
    audioPlayer.onPositionChanged.listen((Duration p) {
      print('Current position: $p');
      setState(() => position = p);
    });
    audioPlayer.onPlayerComplete.listen((event) {
      if(currentIndex == musicList.length-1){
        currentIndex=0;
        playMusic(currentIndex);
      } else {
        playNextSong();
      }
    });
  }

  Future<void> togglePlay() async {
    if (!isPlay) {
      await audioPlayer.resume();
    }
  }

  Future<void> togglePause() async {
    if (isPlay) {
      await audioPlayer.pause();
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _contentPage(widget.pageName);
  }

  Widget itemContent(String note) {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              iconSize: 25,
              onPressed: () {
                setState(() {});
              },
              icon: Icon(
                Icons.upload_file,
                color: Colors.blue,
              )),
          IconButton(
              iconSize: 25,
              onPressed: () {
                setState(() {
                  isStop = false;
                  setAudio(note);
                  audioPlayer.play(AssetSource(note));
                });
              },
              icon: Icon(
                Icons.play_arrow,
                color: Colors.blue,
              )),
        ],
      ),
    );
  }

  Widget _contentPage(String text) {
    switch (text) {
      case 'Src':
        return Expanded(
          child: ListView.builder(
              itemCount: musicList.length,
              itemBuilder: (context, index) {
                final note = musicList[index];
                final name = note.split('.').first;
                return ListTile(
                  title: Text(name),
                  subtitle: Text(note),
                  onTap: () {
                    setState(() {
                      isStop = false;
                      setAudio(note);
                      playMusic(index);
                    });
                  },
                  trailing: itemContent(note),
                );
              }),
        );
      case 'Ctrl':
        return Expanded(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ctrlStatusButton("Pause"),
                  ctrlStatusButton("Stop"),
                  ctrlStatusButton("Resume"),
                  ctrlStatusButton("Release"),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Volume'),
                  Row(
                    children: [
                      ctrlVolumeButton(0.0),
                      ctrlVolumeButton(0.5),
                      ctrlVolumeButton(1.0),
                      ctrlVolumeButton(2.0),
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Balance'),
                  Row(
                    children: [
                      ctrlBalanceButton(-1.0),
                      ctrlBalanceButton(-0.5),
                      ctrlBalanceButton(-0.0),
                      ctrlBalanceButton(1.0),
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rate'),
                  Row(
                    children: [
                      ctrlRateButton(0.0),
                      ctrlRateButton(0.5),
                      ctrlRateButton(1.0),
                      ctrlRateButton(2.0),
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Player Mode'),
                  Row(
                    children: [
                      buildButton('mediaPlayer', isLeft: true),
                      buildButton('lowLatency', isRight: true),
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Release Mode'),
                  Row(
                    children: [
                      buildButton('release', isLeft: true),
                      buildButton('loop'),
                      buildButton('stop', isRight: true),
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Seek'),
                  Row(
                    children: [
                      ctrlSeekButton(0.0),
                      ctrlSeekButton(0.5),
                      ctrlSeekButton(1.0),
                      ctrlItemButton("Custom"),
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
      case 'Stream':
        return Expanded(child: contentStream());
      case 'Ctx':
        return const Text('Ctx data');
      case 'Log':
        return const Text('Log data');
      default:
        return const Text('unknown');
    }
  }

  Widget ctrlItemButton(String text) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 2))
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 30,
        child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue,
              side: const BorderSide(color: Colors.transparent),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              minimumSize: const Size(50, 30),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Widget ctrlStatusButton(String text) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 2))
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 30,
        child: OutlinedButton(
            onPressed: () async {
              switch (text) {
                case 'Pause':
                  return audioPlayer.pause();
                case 'Stop':
                  return audioPlayer.stop();
                case 'Resume':
                  return audioPlayer.resume();
                case 'Release':
                  return audioPlayer.release();
              }
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue,
              side: const BorderSide(color: Colors.transparent),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              minimumSize: const Size(50, 30),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Widget ctrlVolumeButton(double text) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 2))
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 30,
        child: OutlinedButton(
            onPressed: () {
              audioPlayer.setVolume(text);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue,
              side: const BorderSide(color: Colors.transparent),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              minimumSize: const Size(50, 30),
            ),
            child: Text(
              '$text',
              style: const TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Widget ctrlBalanceButton(double text) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 2))
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 30,
        child: OutlinedButton(
            onPressed: () {
              audioPlayer.setBalance(text);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue,
              side: const BorderSide(color: Colors.transparent),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              minimumSize: const Size(50, 30),
            ),
            child: Text(
              '$text',
              style: const TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Widget ctrlRateButton(double text) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 2))
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 30,
        child: OutlinedButton(
            onPressed: () {
              audioPlayer.setPlaybackRate(text);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue,
              side: const BorderSide(color: Colors.transparent),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              minimumSize: const Size(50, 30),
            ),
            child: Text(
              '$text',
              style: const TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Widget ctrlSeekButton(double text) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 2))
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 30,
        child: OutlinedButton(
            onPressed: () {
              audioPlayer.seek(duration * text);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue,
              side: const BorderSide(color: Colors.transparent),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              minimumSize: const Size(50, 30),
            ),
            child: Text(
              '$text',
              style: const TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  String? _selectedButton;
  Widget buildButton(String text, {bool isLeft = false, bool isRight = false}) {
    bool isPressed = _selectedButton == text;
    return SizedBox(
      height: 50,
      child: OutlinedButton(
          onPressed: () {
            setState(() {
              _selectedButton = text;
            });
          },
          style: OutlinedButton.styleFrom(
              backgroundColor: isPressed ? Colors.cyan[100] : Colors.white,
              side: BorderSide(
                  color: isPressed ? Colors.blueAccent : Colors.grey, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                left: isLeft ? const Radius.circular(10) : Radius.zero,
                right: isRight ? const Radius.circular(10) : Radius.zero,
              )),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              minimumSize: const Size(50, 30)),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
            ),
          )),
    );
  }

  Widget contentStream() {
    return Column(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 50,
                    onPressed: () {
                      setState(() {
                        isStop = false;
                        togglePlay();
                      });

                    },
                    icon: Icon(
                      Icons.play_arrow,
                      color: isPlay ? Colors.grey : Colors.blue,
                    ),
                  ),
                  IconButton(
                    iconSize: 50,
                    onPressed: () {
                      setState(() {
                        togglePause();
                      });
                    },
                    icon: Icon(
                      Icons.pause,
                      color: isPlay ? Colors.blue : Colors.grey,
                    ),
                  ),
                  IconButton(
                    iconSize: 50,
                    onPressed: () {
                      setState(() {
                        isStop = !isStop;
                        audioPlayer.stop();
                      });
                    },
                    icon: Icon(
                      Icons.stop,
                      color: isStop ? Colors.grey : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            //play music
            Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) {
                  final position = Duration(seconds: value.toInt());
                  audioPlayer.seek(position);
                  if (!isPlay) {
                    audioPlayer.resume();
                  }
                }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(formatTime(position)),
                      Text('/'),
                      Text(formatTime(duration))
                    ],
                  ),
                  Text(playerStateToString(status))
                ],
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.5),
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                )),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Text('Streams'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 25),
                            child: Icon(
                              Icons.timelapse_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formatTime(duration)),
                              Text('Duration Stream')
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 25),
                            child: Icon(
                              Icons.timer,
                              color: Colors.grey,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formatTime(position)),
                              Text('Position Stream')
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 25),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.grey,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(playerStateToString(status)),
                              Text('State Stream')
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Properties'),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        audioPlayer.stop();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        minimumSize: Size(100, 30),
                        backgroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        )),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Refresh',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
