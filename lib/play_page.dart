import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:radio_web/fullScreen.dart';
import 'package:video_player/video_player.dart';
//import 'package:wakelock/wakelock.dart';

class VideoClip {
  final String fileName;
  final String thumbName;
  final String title;
  final String parent;
  int runningTime;

  VideoClip(
      this.title, this.fileName, this.thumbName, this.runningTime, this.parent);
}

class PlayPage extends StatefulWidget {
  // PlayPage({Key key, }) : super(key: key);

  //final List<VideoClip> clips;

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  VideoPlayerController? _controller;
  final resultVideoEst = FirebaseFirestore.instance.collection('videoest');

  //=      VideoPlayerController.network('')..initialize();

  List<VideoClip> _clips = [];

  Future<void> _getEstaciones() async {
    await resultVideoEst.get().then((query) {
      query.docs.forEach((element) async {
        VideoClip _videos = VideoClip(
            element['name'].toString(),
            element['descripcion'],
            element['imgURL'].toString(),
            0,
            element['link']);

        print('Link ${element['link'].toString()}');

        setState(() {
          _clips.add(_videos);
        });
      });
    }).catchError((onError) {
      print('Error $onError');
    });
    _initializeAndPlay(0);

    // return clips;
  }

  var _playingIndex = -1;
  var _disposed = false;
  var _isFullScreen = false;
  var _isEndOfClip = false;
  var _progress = 0.0;
  var _showingDialog = false;
  // late Timer _timerVisibleControl;
  double _controlAlpha = 1.0;
  bool isLoading = false;
  var _playing = false;
  bool get _isPlaying {
    return _playing;
  }
/*
  set _isPlaying(bool value) {
        setState(() {
      isLoading = true;
    });
    _playing = value;
    _timerVisibleControl?.cancel();
    if (value) {
      _timerVisibleControl = Timer(Duration(seconds: 2), () {
        if (_disposed) return;
        setState(() {
          _controlAlpha = 0.0;
        });
      });
    } else {
      _timerVisibleControl = Timer(Duration(milliseconds: 200), () {
        if (_disposed) return;
        setState(() {
          _controlAlpha = 1.0;
        });
      });
    }
        setState(() {
      isLoading = false;
    });
  } 

  void _onTapVideo() {
    debugPrint("_onTapVideo $_controlAlpha");
    setState(() {
      _controlAlpha = _controlAlpha > 0 ? 0 : 1;
    });
    _timerVisibleControl?.cancel();
    _timerVisibleControl = Timer(Duration(seconds: 2), () {
      if (_isPlaying) {
        setState(() {
          _controlAlpha = 0.0;
        });
      }
    });
  }
*/
  @override
  void initState() {
    _getEstaciones();
    document.documentElement!.setAttribute('video', 'controls');
    //document.getElementsByTagName('video').set
    //Wakelock.enable();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.initState();
  }

  @override
  void dispose() {
    _disposed = true;
   // _timerVisibleControl?.cancel();
    // Wakelock.disable();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _exitFullScreen();
    _controller?.pause(); // mute instantly
    _controller?.dispose();
    // _controller = null;
    super.dispose();
  }

  void _toggleFullscreen() async {
    if (_isFullScreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  void _enterFullScreen() async {
    debugPrint("enterFullScreen");

    /*  Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (BuildContext context, _, __) {
          return FullScreenPage(controllerS : _controller, index: _playingIndex,);
        },
      ),
    ); */
    //  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    //  await SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    if (_disposed) return;
    setState(() {
      _isFullScreen = true;
    });
  }

  void _exitFullScreen() async {
    document.exitFullscreen();
    debugPrint("exitFullScreen");
    //  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    //  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (_disposed) return;
    setState(() {
      _isFullScreen = false;
    });
  }

  void _initializeAndPlay(int index) async {
    print("_initializeAndPlay ---------> $index");
    final clip = _clips[index];

    final controller = VideoPlayerController.network(clip.parent);
    // : VideoPlayerController.asset(clip.videoPath());

    final old = _controller;
    if (old != null) {
   //   old.removeListener(_onControllerUpdated);
      old.pause();
      debugPrint("---- old contoller paused.");
    }

    debugPrint("---- controller changed.");
    setState(() {});

    _controller = controller
      ..initialize().then((value) {
        debugPrint("---- controller initialized");
        old?.dispose();
        _playingIndex = index;
        _duration = _controller!.value.duration;
        _position = _controller!.value.position;
      //  controller.addListener(_onControllerUpdated);

        setState(() {});
      });

    if (!old!.value.isPlaying) {
      _controller!.play();
    } else {
      old.pause();
    }
  }

  var _updateProgressInterval = 0.0;
  late Duration _duration;
  late Duration _position;
/*
  void _onControllerUpdated() async {
    if (_disposed) return;
    // blocking too many updation
    // important !!
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_updateProgressInterval > now) {
      return;
    }
    _updateProgressInterval = now + 500.0;

    final controller = _controller;
    if (controller == null) return;
    if (!controller.value.isInitialized) return;
    if (_duration == null) {
      _duration = _controller!.value.duration;
    }
    var duration = _duration;
    if (duration == null) return;

    var position = await controller.position;
    _position = position!;
    final playing = controller.value.isPlaying;
    final isEndOfClip = position.inMilliseconds > 0 &&
        position.inSeconds + 1 >= duration.inSeconds;
    if (playing) {
      // handle progress indicator
      if (_disposed) return;
      setState(() {
        _progress = position.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }

    // handle clip end
    if (_isPlaying != playing || _isEndOfClip != isEndOfClip) {
      _isPlaying = playing;
      _isEndOfClip = isEndOfClip;
      debugPrint(
          "updated -----> isPlaying=$playing / isEndOfClip=$isEndOfClip");
      if (isEndOfClip && !playing) {
        debugPrint(
            "========================== End of Clip / Handle NEXT ========================== ");
        final isComplete = _playingIndex == _clips.length - 1;
        if (isComplete) {
          print("played all!!");
          if (!_showingDialog) {
            _showingDialog = true;
            _showPlayedAllDialog().then((value) {
              _exitFullScreen();
              _showingDialog = false;
            });
          }
        } else {
          _initializeAndPlay(_playingIndex + 1);
        }
      }
    }
  }

  Future<Future<bool?>> _showPlayedAllDialog() async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(child: Text("Played all videos.")),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Close"),
              ),
            ],
          );
        });
  }
*/
  @override
  Widget build(BuildContext context) {
    return 
    isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.purple, backgroundColor: Colors.blue,),
            )
          : 
    _isFullScreen
        ? SizedBox()
        : /*SingleChildScrollView(
            child: */
        Container(
            height: 420,
            width: 300,
            child: Column(children: <Widget>[
              Container(
                child: Center(child: _playView(context)),
                decoration: BoxDecoration(color: Colors.black),
              ),
              Expanded(
                child: _listView(),
              ),
            ]),
          );
  }

  void _onTapCard(int index) {
    _initializeAndPlay(index);
  }

  Widget _playView(BuildContext context) {
    final controller = _controller;

    if (controller != null && controller.value.isInitialized) {
      return AspectRatio(
        //aspectRatio: controller.value.aspectRatio,
        aspectRatio: 16.0 / 9.0,
        child: Stack(
          children: <Widget>[
            VideoPlayer(controller),
/*

            GestureDetector(
              child: VideoPlayer(controller),
             onTap: _onTapVideo,
            ),
            _controlAlpha > 0
                ? AnimatedOpacity(
                    opacity: _controlAlpha,
                    duration: Duration(milliseconds: 250),
                    child: _controlView(context),
                  )
                : Container(), */
          ],
        ),
      );
    } else {
      // _initializeAndPlay(0);
      print('Controller Null');
      return AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: Center(child: CircularProgressIndicator(color: Colors.purple, backgroundColor: Colors.blue,)),
      );
    }
  }

  Widget _listView() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _clips.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          splashColor: Colors.blue[100],
          onTap: () {
            _onTapCard(index);
          },
          child: _buildCard(index),
        );
      },
    ).build(context);
  }
/*
  Widget _controlView(BuildContext context) {
    return Column(
      children: <Widget>[
        _topUI(),
        Expanded(
          child: _centerUI(),
        ),
        _bottomUI()
      ],
    );
  }

  Widget _centerUI() {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () async {
            final index = _playingIndex - 1;
            if (index > 0 && _clips.length > 0) {
              _initializeAndPlay(index);
            }
          },
          child: Icon(
            Icons.fast_rewind,
            size: 36.0,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_isPlaying) {
              _controller?.pause();
              _isPlaying = false;
            } else {
              final controller = _controller;
              if (controller != null) {
                final pos = _position?.inSeconds ?? 0;
                final dur = _duration?.inSeconds ?? 0;
                final isEnd = pos == dur;
                if (isEnd) {
                  _initializeAndPlay(_playingIndex);
                } else {
                  controller.play();
                }
              }
            }
            setState(() {});
          },
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 56.0,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () async {
            final index = _playingIndex + 1;
            if (index < _clips.length - 1) {
              _initializeAndPlay(index);
            }
          },
          child: Icon(
            Icons.fast_forward,
            size: 36.0,
            color: Colors.white,
          ),
        ),
      ],
    ));
  }

  String convertTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Widget _topUI() {
    final noMute = (_controller?.value?.volume ?? 0) > 0;
    final duration = _duration?.inSeconds ?? 0;
    final head = _position?.inSeconds ?? 0;
    final remained = max(0, duration - head);
    final min = convertTwo(remained ~/ 60.0);
    final sec = convertTwo(remained % 60);
    return Row(
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 4.0,
                      color: Color.fromARGB(50, 0, 0, 0)),
                ]),
                child: Icon(
                  noMute ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                )),
          ),
          onTap: () {
            if (noMute) {
              _controller?.setVolume(0);
            } else {
              _controller?.setVolume(1.0);
            }
            setState(() {});
          },
        ),
        Expanded(
          child: Container(),
        ),
        Text(
          "$min:$sec",
          style: TextStyle(
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0.0, 1.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        SizedBox(width: 10)
      ],
    );
  }

  Widget _bottomUI() {
    return Row(
      children: <Widget>[
        SizedBox(width: 20),
        Expanded(
          child: Slider(
            value: max(0, min(_progress * 100, 100)),
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() {
                _progress = value * 0.01;
              });
            },
            onChangeStart: (value) {
              debugPrint("-- onChangeStart $value");
              _controller?.pause();
            },
            onChangeEnd: (value) {
              debugPrint("-- onChangeEnd $value");
              final duration = _controller?.value?.duration;
              if (duration != null) {
                var newValue = max(0, min(value, 99)) * 0.01;
                var millis = (duration.inMilliseconds * newValue).toInt();
                _controller?.seekTo(Duration(milliseconds: millis));
                _controller?.play();
              }
            },
          ),
        ),
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.yellow,
          icon: Icon(
            Icons.fullscreen,
            color: Colors.white,
          ),
          onPressed: _toggleFullscreen,
        ),
      ],
    );
  }
*/
  Widget _buildCard(int index) {
    double _screenWidth = MediaQuery.of(context).size.width;
    int minSize = 500;
    double itemWidth = 450;
    double viewportFraction = 0.85;
    bool fontS = _screenWidth < 1024.0;
    bool minS = _screenWidth <= minSize;

    if (_screenWidth <= minSize) {
      itemWidth = _screenWidth / 2.0;
      viewportFraction = 0.55;
    } else {
      itemWidth = _screenWidth; // / 2.5;
      viewportFraction = 0.275;
    }
    final clip = _clips[index];
    print('_buildCard index $index pindex $_playingIndex');
    final playing = index == _playingIndex;
    String runtime;
    if (clip.runningTime > 60) {
      runtime = "${clip.runningTime ~/ 60} ${clip.runningTime % 60}";
    } else {
      runtime = "${clip.runningTime % 60}";
    }
    return Column(children: [
      Container(
        padding: EdgeInsets.all(4),
        decoration: playing
            ? BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.blue,
                    Colors.black,
                    Colors.black,
                    Colors.purple
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              )
            : BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
              ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(clip.thumbName,
                      width: 70, height: 50, fit: BoxFit.fill)),
            ),
            Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(clip.title,
                        style: TextStyle(
                            fontSize: minS ? 10 : 16,
                            fontWeight: FontWeight.bold,
                            color: playing ? Colors.white : Colors.black45)),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: playing
                  ? Icon(
                      Icons.play_arrow,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.stop,
                      color: Colors.grey.shade300,
                    ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 10,
      )
    ]);
  }
}
