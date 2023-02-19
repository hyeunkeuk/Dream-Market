import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopping/screens/qt/qts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_audio_manager_plus/flutter_audio_manager_plus.dart';

class QTScreen extends StatefulWidget {
  // const QTScreen({Key key}) : super(key: key);
  static const routeName = '/qt';

  @override
  State<QTScreen> createState() => _QTScreenState();
}

class _QTScreenState extends State<QTScreen> {
  final _controller = new TextEditingController();

  bool expend = false;
  bool showDone = false;
  bool showAdd = true;

  // final qtAudio = QTAudio();

  final _contentFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _enteredTitle = '';
  var _enteredContent = '';

  var engKor = 'Korean';

  bool isplaying = false;

  bool audioplayed = false;

  bool isMute = true;

  AudioPlayer player = AudioPlayer();
  // AudioInput _currentInput = AudioInput("unknow", 0);
  // List<AudioInput> _availableInputs = [];

  // Future<void> init() async {
  //   FlutterAudioManagerPlus.setListener(() async {
  //     print("-----changed-------");
  //     await _getInput();
  //     setState(() {});
  //   });

  //   await _getInput();
  //   if (!mounted) return;
  //   setState(() {});
  // }

  // _getInput() async {
  //   _currentInput = await FlutterAudioManagerPlus.getCurrentOutput();
  //   print("current:$_currentInput");
  //   _availableInputs = await FlutterAudioManagerPlus.getAvailableInputs();
  //   print("available $_availableInputs");
  // }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await player.setSource(AssetSource('audio/qt_audio.mp3'));
      isMute ? player.stop() : player.resume();
    });
    // init();
    // FlutterAudioManagerPlus.changeToSpeaker();
    // player.play(att);
    super.initState();
  }

  void changeLanguage(lang) {
    setState(() {
      engKor = lang;
    });
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    player.stop();
    super.dispose();
  }

  void _postQT(qtRoomId) async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      print('Save form state is not valid');
      return;
    }

    _form.currentState.save();

    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    CollectionReference qtRooms = FirebaseFirestore.instance.collection('qt');
    final timestamp = DateTime.now();
    final createdAt = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timestamp);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((value) {
      qtRooms.doc(qtRoomId).collection('qts').add(
        {
          'createdAt': createdAt,
          'creatorId': user.uid,
          'creatorName': value.data()['lastName'],
          'title': _enteredTitle,
          'content': _enteredContent,
        },
      );
    });
    setState(() {
      showDone = false;
      expend = false;
    });
    // _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.now();
    final today = DateFormat('EEE, MMM/d/yyyy').format(timestamp);
    final date = DateFormat('yyMMdd').format(timestamp);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(today),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: engKor == 'English'
                      ? Colors.amber[100]
                      : Colors.blue[100]),
              onPressed: () {
                if (engKor == 'English') {
                  changeLanguage('Korean');
                } else {
                  changeLanguage('English');
                }
              },
              child: Text(engKor),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 100,
          ),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('qt')
                .where('date', isEqualTo: date)
                .snapshots(),
            builder: (ctx, qtSnapshot) {
              if (qtSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final qtDocs = qtSnapshot.data.docs;
              if (qtDocs.length > 0) {
                final todayQT = qtDocs[0];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 30),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                todayQT['verse'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isMute = !isMute;
                              });
                              isMute ? player.stop() : player.resume();
                            },
                            icon: isMute
                                ? Icon(Icons.volume_off)
                                : Icon(Icons.volume_up),
                          ),
                          // QTAudio(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            engKor == 'English'
                                ? todayQT['kor']
                                : todayQT['eng'],
                            style: TextStyle(
                              fontSize: 17,
                              letterSpacing: 1,
                              // wordSpacing: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    showAdd == true
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                expend = true;
                                showAdd = false;
                              });
                            },
                            icon: Icon(Icons.playlist_add_circle),
                          )
                        : SizedBox.shrink(),
                    expend == false
                        ? SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Form(
                                key: _form,
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 191, 219, 241)),
                                      onPressed: () {
                                        _postQT(todayQT.id);
                                      },
                                      child: Text('Post'),
                                    ),
                                    TextFormField(
                                      // initialValue: _initValues['title'],
                                      decoration: InputDecoration(
                                        labelText: 'Title',
                                      ),
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context)
                                            .requestFocus(_contentFocusNode);
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please write the title';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        // print('im here ');
                                        _enteredTitle = value;
                                      },
                                    ),
                                    TextFormField(
                                      // initialValue: 'What is your application?',
                                      decoration: InputDecoration(
                                        // labelText: 'Write...',
                                        border: OutlineInputBorder(),
                                      ),
                                      minLines: 3,
                                      maxLines: 10,
                                      keyboardType: TextInputType.multiline,
                                      focusNode: _contentFocusNode,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please write your application';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _enteredContent = value;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    QTs(todayQT.id),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
