import 'dart:async';
import 'dart:developer';
import 'package:aft/ATESTS/screens/profile_screen_edit.dart';
import 'package:aft/ATESTS/screens/report_user_screen.dart';
import 'package:aft/ATESTS/screens/settings.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../feeds/poll_card.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/poll.dart';
import '../other/utils.dart.dart';
import '../provider/user_provider.dart';
import 'filter_screen.dart';
import 'filter_arrays.dart';
import 'add_post.dart';
import '../feeds/message_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  var messages = 'true';
  var global = 'true';
  bool loading = false;
  // bool filter = true;
  // var userData = {};
  // var timerWidth = 2;
  String oneValue = '';
  String twoValue = '';
  String threeValue = '';
  int selectedCountryIndex = -1;
  User? user;

  // String flag = 'us';
  List<Post> postsList = [];
  StreamSubscription? loadDataStream;
  StreamController<Post> updatingStream = StreamController.broadcast();

  List<Poll> pollsList = [];
  StreamSubscription? loadDataStreamPoll;
  StreamController<Poll> updatingStreamPoll = StreamController.broadcast();

  // late Timer _timer;
  // int _start = 60;

  // late String _now;
  // late Timer _everySecond;

  // void startTimer() {
  //   const oneSec = const Duration(seconds: 1);
  //   _timer = new Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       if (_start == 0) {
  //         setState(() {
  //           timer.cancel();
  //         });
  //       } else {
  //         setState(() {
  //           _start--;
  //         });
  //       }
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    loadCountryFilterValue();
    getValueG().then(((value) => getValueM().then((value) => initList())));
    getValueG().then(((value) => getValueM().then((value) => initPollList())));

    // this has to be like this, to wait for the get functions to be executed first
    //new changes
    //we are changed ACountries file,
    //-----old changes
    //we are initialy filling postList when page is loaded.
    //every elements is subscribed on loadDataStream and listening on the event that is meant to it. (look at the changes in the Post class)
  }

  @override
  void dispose() {
    super.dispose();
    if (loadDataStream != null) {
      loadDataStream!.cancel();
    }
    if (loadDataStreamPoll != null) {
      loadDataStreamPoll!.cancel();
    }
  }

  // Future<void>
  initList() async {
    if (loadDataStream != null) {
      loadDataStream!.cancel();
      postsList = [];
    }
    loadDataStream = (global == "true"
            ? FirebaseFirestore.instance.collection('posts')
            : FirebaseFirestore.instance
                .collection('posts')
                .where("country", isEqualTo: short[selectedCountryIndex]))
        .where("global", isEqualTo: global)
        .orderBy("score", descending: true)
        .orderBy("datePublished", descending: false)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            postsList.add(Post.fromMap({
              ...change.doc.data()!,
              'updatingStream': updatingStream
            })); // we are adding to a local list when the element is added in firebase collection
            break; //the Post element we will send on pair with updatingStream, because a Post constructor makes a listener on a stream.
          case DocumentChangeType.modified:
            updatingStream.add(Post.fromMap({
              ...change.doc.data()!
            })); // we are sending a modified object in the stream.
            break;
          case DocumentChangeType.removed:
            postsList.remove(Post.fromMap({
              ...change.doc.data()!
            })); // we are removing a Post object from the local list.
            break;
        }
      }
      setState(() {});
    });
  }

  initPollList() async {
    if (loadDataStreamPoll != null) {
      loadDataStreamPoll!.cancel();
      pollsList = [];
    }
    loadDataStreamPoll = (global == "true"
            ? FirebaseFirestore.instance.collection('polls')
            : FirebaseFirestore.instance
                .collection('polls')
                .where("country", isEqualTo: short[selectedCountryIndex]))
        .where("global", isEqualTo: global)
        .orderBy("totalVotes", descending: true)
        .orderBy("datePublished", descending: false)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            pollsList.add(Poll.fromMap({
              ...change.doc.data()!,
              'updatingStreamPoll': updatingStreamPoll
            })); // we are adding to a local list when the element is added in firebase collection
            break; //the Post element we will send on pair with updatingStream, because a Post constructor makes a listener on a stream.
          case DocumentChangeType.modified:
            updatingStreamPoll.add(Poll.fromMap({
              ...change.doc.data()!
            })); // we are sending a modified object in the stream.
            break;
          case DocumentChangeType.removed:
            pollsList.remove(Poll.fromMap({
              ...change.doc.data()!
            })); // we are removing a Post object from the local list.
            break;
        }
      }
      setState(() {});
    });
  }

  Future<void> getValueG() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio3') != null) {
      setState(() {
        global = prefs.getString('selected_radio3')!;
      });
    }
  }

  Future<void> setValueG(String valueg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      global = valueg.toString();
      prefs.setString('selected_radio3', global);
      initList();
      initPollList();
    });
  }

  Future<void> getValueM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio4') != null) {
      setState(() {
        messages = prefs.getString('selected_radio4')!;
      });
    }
  }

  // Future<void>
  setValueM(String valuem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      messages = valuem.toString();
      if (valuem == "true") {
        initList();
        initPollList();
      }
      prefs.setString('selected_radio4', messages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 245, 245, 245),
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              // elevation: 1.5,
              // forceElevated: true,
              toolbarHeight: 108,

              backgroundColor: Color.fromARGB(255, 245, 245, 245),
              actions: [
                SafeArea(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        children: [
                          Container(
                            // color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, right: 12, left: 12
                                  // bottom: filter ? 8 : ,
                                  ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // setState(() {
                                      //   filter = !filter;
                                      // });
                                      Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             FilterScreen()))
                                              // .then((value) => {getValue()});
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Countries()))
                                          .then((value) async {
                                        await loadCountryFilterValue();
                                        initList();
                                        initPollList();
                                      });
                                    },
                                    child: Icon(Icons.filter_list,
                                        color: Colors.black),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SettingsScreen()),
                                      );
                                    },
                                    child: Icon(Icons.settings,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            // color: Colors.blue,

                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 12.0, left: 12, top: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  global == 'true'
                                      ? Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 1.0),
                                              child: Text(
                                                'Global',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.5,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            AnimatedToggleSwitch<
                                                    String>.rollingByHeight(
                                                height: 32,
                                                current: global,
                                                values: const [
                                                  'true',
                                                  'false',
                                                ],
                                                onChanged: (valueg) =>
                                                    setValueG(
                                                        valueg.toString()),
                                                iconBuilder:
                                                    rollingIconBuilderStringThree,
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                borderWidth: 0,
                                                indicatorSize:
                                                    const Size.square(1.8),
                                                innerColor: Color.fromARGB(
                                                    255, 228, 228, 228),
                                                indicatorColor: Color.fromARGB(
                                                    255, 157, 157, 157),
                                                borderColor: Color.fromARGB(
                                                    255, 135, 135, 135),
                                                iconOpacity: 1),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 1.0),
                                                  child: Text(
                                                    'National',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14.5,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                // threeValue == ''
                                                //     ? Container()
                                                //     :
                                                Container(
                                                  width: 24,
                                                  height: 16,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 2.0),
                                                    child: Image.asset(
                                                        'icons/flags/png/${short[selectedCountryIndex]}.png',
                                                        package:
                                                            'country_icons'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            AnimatedToggleSwitch<
                                                String>.rollingByHeight(
                                              height: 32,
                                              current: global,
                                              values: const [
                                                'true',
                                                'false',
                                              ],
                                              onChanged: (valueg) {
                                                setValueG(valueg.toString());
                                                // setState(() {
                                                //   loading == true;
                                                //   Future.delayed(
                                                //       const Duration(
                                                //           milliseconds:
                                                //               500), () {
                                                //     loading == false;
                                                //   });
                                                // });
                                              },
                                              iconBuilder:
                                                  rollingIconBuilderStringThree,
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              borderWidth: 0,
                                              indicatorSize:
                                                  const Size.square(1.8),
                                              innerColor: Color.fromARGB(
                                                  255, 228, 228, 228),
                                              indicatorColor: Color.fromARGB(
                                                  255, 157, 157, 157),
                                              borderColor: Color.fromARGB(
                                                  255, 135, 135, 135),
                                              iconOpacity: 1,
                                            ),
                                          ],
                                        ),
                                  InkWell(
                                    onTap: () {
                                      performLoggedUserActionProfile(
                                        context: context,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const EditProfile(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    // onTap: () {
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => ProfileScreen(
                                    //             // post: userData,
                                    //             )),
                                    //   );
                                    // },
                                    child: PhysicalModel(
                                      // elevation: 1,
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          // image: DecorationImage(
                                          //   image: NetworkImage(
                                          //       user?.photoUrl ?? ''),
                                          //   fit: BoxFit.cover,
                                          // ),
                                          image: DecorationImage(
                                            image: user?.photoUrl != null
                                                ? NetworkImage(
                                                    user?.photoUrl ?? '')
                                                : NetworkImage(
                                                    'https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max'),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50.0)),
                                          // border: Border.all(
                                          //   color:
                                          //       Color.fromARGB(255, 178, 178, 178),
                                          //   width: 0,
                                          // ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 1.0),
                                        child: Text(
                                          messages == 'true'
                                              ? 'Messages'
                                              : 'Polls',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      AnimatedToggleSwitch<
                                              String>.rollingByHeight(
                                          height: 32,
                                          current: messages,
                                          values: const [
                                            'true',
                                            'false',
                                          ],
                                          onChanged: (valuem) {
                                            setValueM(valuem.toString());
                                            // setState(() {
                                            //   loading = true;
                                            //   // print(loading);
                                            //   Future.delayed(
                                            //       const Duration(
                                            //           milliseconds: 500), () {
                                            //     loading = false;
                                            //     print(loading);
                                            //   });
                                            // });
                                          },
                                          iconBuilder:
                                              rollingIconBuilderStringTwo,
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderWidth: 0,
                                          indicatorSize: const Size.square(1.8),
                                          innerColor: Color.fromARGB(
                                              255, 228, 228, 228),
                                          indicatorColor: Color.fromARGB(
                                              255, 157, 157, 157),
                                          borderColor: Color.fromARGB(
                                              255, 135, 135, 135),
                                          iconOpacity: 1),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          body: //global == "true" && messages == "true"
              // ?
              //global variable doesn't look into here, because we are using unique list(postsList) for filling up model
              //look at the function initList(), it is called when global variable is changed
              postsList.length != 0 && messages == "true"
                  ? ListView.builder(
                      itemCount: postsList.length,
                      itemBuilder: (context, index) {
                        // Post post = Post.fromSnap(snapshot.data!.docs[index]);
                        final User? user =
                            Provider.of<UserProvider>(context).getUser;
                        return PostCardTest(
                          post: postsList[index],
                          indexPlacement: index,
                        );
                      })
                  : postsList.length == 0 &&
                          messages == "true" &&
                          global == "true"
                      ? Center(
                          child: Text(
                            'No messages yet.',
                            style: TextStyle(
                                color: Color.fromARGB(255, 114, 114, 114),
                                fontSize: 20),
                          ),
                        )
                      : postsList.length == 0 &&
                              messages == "true" &&
                              global == "false"
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No',
                                    style: TextStyle(
                                        fontSize: 20,

                                        // fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 114, 114, 114)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Container(
                                      width: 24,
                                      height: 16,
                                      child: Image.asset(
                                          'icons/flags/png/${short[selectedCountryIndex]}.png',
                                          package: 'country_icons'),
                                    ),
                                  ),
                                  Text('messages yet.',
                                      style: TextStyle(
                                          fontSize: 20,

                                          // fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 114, 114, 114))),
                                ],
                              ),
                            )
                          : pollsList.length != 0 && messages == "false"
                              ? ListView.builder(
                                  itemCount: pollsList.length,
                                  itemBuilder: (context, index) {
                                    final User? user =
                                        Provider.of<UserProvider>(context)
                                            .getUser;

                                    return PollCard(
                                      poll: pollsList[index],
                                      indexPlacement: index,
                                    );
                                  })
                              : pollsList.length == 0 &&
                                      messages == "false" &&
                                      global == "true"
                                  ? Center(
                                      child: Text(
                                        'No polls yet.',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 114, 114, 114),
                                            fontSize: 20),
                                      ),
                                    )
                                  : Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'No',
                                            style: TextStyle(
                                                fontSize: 20,

                                                // fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 114, 114, 114)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Container(
                                              width: 24,
                                              height: 16,
                                              child: Image.asset(
                                                  'icons/flags/png/${short[selectedCountryIndex]}.png',
                                                  package: 'country_icons'),
                                            ),
                                          ),
                                          Text(
                                            'polls yet.',
                                            style: TextStyle(
                                              fontSize: 20,

                                              // fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 114, 114, 114),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
        ),
      ),
    );
  }

  Widget rollingIconBuilderStringTwo(
      String messages, Size iconSize, bool foreground) {
    IconData data = Icons.poll;
    if (messages == 'true') data = Icons.message;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  Widget rollingIconBuilderStringThree(
      String global, Size iconSize, bool foreground) {
    IconData data = Icons.flag;
    if (global == 'true') data = Icons.public;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  loadCountryFilterValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCountryIndex = prefs.getInt('countryRadio') ?? -1;
      // prefs.getInt('selected_radio') ?? '';
      oneValue = prefs.getString('selected_radio') ?? '';
      twoValue = prefs.getString('selected_radio1') ?? '';
      threeValue = prefs.getString('selected_radio2') ?? '';
    });
  }
}

//   @override
//   void initState() {
//     super.initState();
//     // super.initState();
//     // // sets first value
//     // _now = DateTime.now().second.toString();

//     // // defines a timer
//     // _everySecond = Timer.periodic(Duration(seconds: 1), (Timer t) {
//     //   setState(() {
//     //     _now = DateTime.now().second.toString();
//     //   });
//     // });

//     // getValueG();
//     // getValueM();
//     // getValue();
//     loadCountryFilterValue();
//     getValueG().then(((value) => getValueM().then((value) => initList())));
//     // initList();
//     // getData();
//     // _selectedCommentSort = commentSorts.first;
//     // _selectedCommentFilter = commentFilters.first;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     if (loadDataStream != null) {
//       loadDataStream!.cancel();
//     }
//   }

//   Future<void> initList() async {
//     if (loadDataStream != null) {
//       loadDataStream!.cancel();
//       postsList = [];
//     }
//     loadDataStream = (global == "false"
//             ? FirebaseFirestore.instance.collection('posts')
//             : FirebaseFirestore.instance
//                 .collection('posts')
//                 .where("country", isEqualTo: short[selectedCountryIndex]))
//         .where("global", isEqualTo: global)
//         .orderBy("score", descending: true)
//         .orderBy("datePublished", descending: false)
//         .snapshots()
//         .listen((event) {
//       for (var change in event.docChanges) {
//         switch (change.type) {
//           case DocumentChangeType.added:
//             postsList.add(Post.fromMap({
//               ...change.doc.data()!,
//               'updatingStream': updatingStream
//             })); // we are adding to a local list when the element is added in firebase collection
//             break; //the Post element we will send on pair with updatingStream, because a Post constructor makes a listener on a stream.
//           case DocumentChangeType.modified:
//             updatingStream.add(Post.fromMap({
//               ...change.doc.data()!
//             })); // we are sending a modified object in the stream.
//             break;
//           case DocumentChangeType.removed:
//             postsList.remove(Post.fromMap({
//               ...change.doc.data()!
//             })); // we are removing a Post object from the local list.
//             break;
//         }
//       }
//       setState(() {});
//     });
//   }

//   // @override
//   // void deactivate() {
//   //   super.deactivate();
//   // }

//   //  getData() async {
//   //   try {
//   //     // var snap = await FirebaseFirestore.instance
//   //     //     .collection('users')
//   //     //     .doc(widget.uid)
//   //     //     .get();
//   //     var snap = await FirebaseFirestore.instance
//   //         .collection('posts')
//   //         .doc()
//   //         .snapshots();

//   //    Post post =
//   //                                 Post.fromSnap(snapshot.data!);
//   //     setState(() {});
//   //   } catch (e) {
//   //     // showSnackBar(cont
//   //     //   // context,
//   //     //   // e.toString(),
//   //     // );
//   //   }
//   // }

//   Future<void> getValueG() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (prefs.getString('selected_radio3') != null) {
//       setState(() {
//         global = prefs.getString('selected_radio3')!;
//       });
//     }
//   }

//   Future<void> setValueG(String valueg) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       global = valueg.toString();
//       prefs.setString('selected_radio3', global);
//     });
//   }

//   Future<void> getValueM() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (prefs.getString('selected_radio4') != null) {
//       setState(() {
//         messages = prefs.getString('selected_radio4')!;
//       });
//     }
//   }

//   Future<void> setValueM(String valuem) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       messages = valuem.toString();
//       if (valuem == "true") {
//         initList();
//       }
//       prefs.setString('selected_radio4', messages);
//     });
//   }

//   @override
  // Widget build(BuildContext context) {
    // var countryIndex = fouri.indexOf(threeValue);
    // // String flag = '';
    // String flag = 'us';
    // if (countryIndex >= 0) {
    //   flag = threei[countryIndex];
    // }
    // final User? user = Provider.of<UserProvider>(context).getUser;
    // user = Provider.of<UserProvider>(context).getUser;
//     final User? user = Provider.of<UserProvider>(context).getUser;
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Color.fromARGB(255, 245, 245, 245),
//         body: NestedScrollView(
//           floatHeaderSlivers: true,
//           headerSliverBuilder: (context, innerBoxIsScrolled) => [
//             SliverAppBar(
//               // elevation: 1.5,
//               // forceElevated: true,
//               toolbarHeight: 108,

//               backgroundColor: Color.fromARGB(255, 245, 245, 245),
//               actions: [
//                 SafeArea(
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 1,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0),
//                       child: Column(
//                         children: [
//                           Container(
//                             // color: Colors.blue,
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                   top: 10, right: 12, left: 12
//                                   // bottom: filter ? 8 : ,
//                                   ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   InkWell(
//                                     onTap: () {
//                                       // setState(() {
//                                       //   filter = !filter;
//                                       // });
//                                       Navigator.push(
//                                           //     context,
//                                           //     MaterialPageRoute(
//                                           //         builder: (context) =>
//                                           //             FilterScreen()))
//                                           // .then((value) => {getValue()});
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   Countries())).then((value) =>
//                                           {
//                                             loadCountryFilterValue(),
//                                             initList()
//                                           });
//                                     },
//                                     child: Icon(Icons.filter_list,
//                                         color: Colors.black),
//                                   ),
//                                   InkWell(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color:
//                                             Color.fromARGB(255, 250, 250, 250),
//                                         borderRadius: BorderRadius.circular(25),
//                                         border: Border.all(
//                                           width: 0,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 28.0, vertical: 4),
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               child: Row(
//                                                 children: [
//                                                   Container(
//                                                     width: 10,
//                                                     height: 20,
//                                                     alignment: Alignment.center,
//                                                     child: Text(
//                                                       '0',
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         color: Color.fromARGB(
//                                                             255, 124, 124, 124),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(width: 2),
//                                                   Container(
//                                                     width: 10,
//                                                     height: 20,
//                                                     alignment: Alignment.center,
//                                                     child: Text(
//                                                       '0',
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         color: Color.fromARGB(
//                                                             255, 124, 124, 124),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             SizedBox(width: 25),
//                                             Container(
//                                               width: 10,
//                                               height: 20,
//                                               alignment: Alignment.center,
//                                               child: Text(
//                                                 ':',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Color.fromARGB(
//                                                       255, 124, 124, 124),
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: 25),
//                                             Container(
//                                               width: 10,
//                                               height: 20,
//                                               alignment: Alignment.center,
//                                               child: Text(
//                                                 '0',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   color: Color.fromARGB(
//                                                       255, 124, 124, 124),
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: 2),
//                                             Container(
//                                               width: 10,
//                                               height: 20,
//                                               alignment: Alignment.center,
//                                               child: Text(
//                                                 '8',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   color: Color.fromARGB(
//                                                       255, 124, 124, 124),
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: 25),
//                                             Container(
//                                               width: 10,
//                                               height: 20,
//                                               alignment: Alignment.center,
//                                               child: Text(
//                                                 ':',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Color.fromARGB(
//                                                       255, 124, 124, 124),
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: 25),
//                                             Container(
//                                               width: 10,
//                                               height: 20,
//                                               alignment: Alignment.center,
//                                               child: Text(
//                                                 '2',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   color: Color.fromARGB(
//                                                       255, 124, 124, 124),
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: 2),
//                                             Container(
//                                               width: 10,
//                                               height: 20,
//                                               alignment: Alignment.center,
//                                               child: Text(
//                                                 '3',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   color: Color.fromARGB(
//                                                       255, 124, 124, 124),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     onTap: () {
//                                       showDialog(
//                                         context: context,
//                                         builder: (context) => SimpleDialog(
//                                           title: Center(
//                                               child: const Text('Timer')),
//                                           children: [
//                                             Center(
//                                               child: const Text(
//                                                 'The timer represents the total remaining time before the votings ends.',
//                                                 textAlign: TextAlign.center,
//                                               ),
//                                             ),
//                                             TextButton(
//                                               onPressed: () {
//                                                 Navigator.of(context).pop();
//                                               },
//                                               child: const Text('Close'),
//                                             )
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   InkWell(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 SettingsScreen()),
//                                       );
//                                     },
//                                     child: Icon(Icons.settings,
//                                         color: Colors.black),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Container(
//                             // color: Colors.blue,

//                             child: Padding(
//                               padding: EdgeInsets.only(
//                                   right: 12.0, left: 12, top: 12),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   global == 'true'
//                                       ? Column(
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   bottom: 1.0),
//                                               child: Text(
//                                                 'Global',
//                                                 style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 14.5,
//                                                   letterSpacing: 0.5,
//                                                 ),
//                                               ),
//                                             ),
//                                             AnimatedToggleSwitch<
//                                                     String>.rollingByHeight(
//                                                 height: 32,
//                                                 current: global,
//                                                 values: const [
//                                                   'true',
//                                                   'false',
//                                                 ],
//                                                 onChanged: (valueg) =>
//                                                     setValueG(
//                                                         valueg.toString()),
//                                                 iconBuilder:
//                                                     rollingIconBuilderStringThree,
//                                                 borderRadius:
//                                                     BorderRadius.circular(25.0),
//                                                 borderWidth: 0,
//                                                 indicatorSize:
//                                                     const Size.square(1.8),
//                                                 innerColor: Color.fromARGB(
//                                                     255, 228, 228, 228),
//                                                 indicatorColor: Color.fromARGB(
//                                                     255, 157, 157, 157),
//                                                 borderColor: Color.fromARGB(
//                                                     255, 135, 135, 135),
//                                                 iconOpacity: 1),
//                                           ],
//                                         )
//                                       : Column(
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           bottom: 1.0),
//                                                   child: Text(
//                                                     'National',
//                                                     style: const TextStyle(
//                                                       color: Colors.black,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 14.5,
//                                                       letterSpacing: 0.5,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 // threeValue == ''
//                                                 //     ? Container()
//                                                 //     :
//                                                 Container(
//                                                   width: 24,
//                                                   height: 16,
//                                                   child: Padding(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             bottom: 2.0),
//                                                     child: Image.asset(
//                                                         'icons/flags/png/${short[selectedCountryIndex]}.png',
//                                                         package:
//                                                             'country_icons'),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             AnimatedToggleSwitch<
//                                                 String>.rollingByHeight(
//                                               height: 32,
//                                               current: global,
//                                               values: const [
//                                                 'true',
//                                                 'false',
//                                               ],
//                                               onChanged: (valueg) =>
//                                                   setValueG(valueg.toString()),
//                                               iconBuilder:
//                                                   rollingIconBuilderStringThree,
//                                               borderRadius:
//                                                   BorderRadius.circular(25.0),
//                                               borderWidth: 0,
//                                               indicatorSize:
//                                                   const Size.square(1.8),
//                                               innerColor: Color.fromARGB(
//                                                   255, 228, 228, 228),
//                                               indicatorColor: Color.fromARGB(
//                                                   255, 157, 157, 157),
//                                               borderColor: Color.fromARGB(
//                                                   255, 135, 135, 135),
//                                               iconOpacity: 1,
//                                             ),
//                                           ],
//                                         ),
//                                   InkWell(
//                                     onTap: () {
//                                       performLoggedUserAction(
//                                         context: context,
//                                         action: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     const ProfileScreen()),
//                                           );
//                                         },
//                                       );
//                                     },
//                                     // onTap: () {
//                                     //   Navigator.push(
//                                     //     context,
//                                     //     MaterialPageRoute(
//                                     //         builder: (context) => ProfileScreen(
//                                     //             // post: userData,
//                                     //             )),
//                                     //   );
//                                     // },
//                                     child: PhysicalModel(
//                                       // elevation: 1,
//                                       color: Colors.white,
//                                       shape: BoxShape.circle,
//                                       child: Container(
//                                         width: 50.0,
//                                         height: 50.0,
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey,
//                                           // image: DecorationImage(
//                                           //   image: NetworkImage(
//                                           //       user?.photoUrl ?? ''),
//                                           //   fit: BoxFit.cover,
//                                           // ),
//                                           image: DecorationImage(
//                                             image: user?.photoUrl != null
//                                                 ? NetworkImage(
//                                                     user?.photoUrl ?? '')
//                                                 : NetworkImage(
//                                                     'https://images.nightcafe.studio//assets/profile.png?tr=w-1600,c-at_max'),
//                                             fit: BoxFit.cover,
//                                           ),
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(50.0)),
//                                           // border: Border.all(
//                                           //   color:
//                                           //       Color.fromARGB(255, 178, 178, 178),
//                                           //   width: 0,
//                                           // ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Column(
//                                     children: [
//                                       Padding(
//                                         padding:
//                                             const EdgeInsets.only(bottom: 1.0),
//                                         child: Text(
//                                           messages == 'true'
//                                               ? 'Messages'
//                                               : 'Polls',
//                                           style: const TextStyle(
//                                             color: Colors.black,
//                                             fontSize: 14.5,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 0.5,
//                                           ),
//                                         ),
//                                       ),
//                                       AnimatedToggleSwitch<
//                                               String>.rollingByHeight(
//                                           height: 32,
//                                           current: messages,
//                                           values: const [
//                                             'true',
//                                             'false',
//                                           ],
//                                           onChanged: (valuem) =>
//                                               setValueM(valuem.toString()),
//                                           iconBuilder:
//                                               rollingIconBuilderStringTwo,
//                                           borderRadius:
//                                               BorderRadius.circular(25.0),
//                                           borderWidth: 0,
//                                           indicatorSize: const Size.square(1.8),
//                                           innerColor: Color.fromARGB(
//                                               255, 228, 228, 228),
//                                           indicatorColor: Color.fromARGB(
//                                               255, 157, 157, 157),
//                                           borderColor: Color.fromARGB(
//                                               255, 135, 135, 135),
//                                           iconOpacity: 1),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],

//           body: //global == "true" && messages == "true"
//               // ?
//               //global variable doesn't look into here, because we are using unique list(postsList) for filling up model
//               //look at the function initList(), it is called when global variable is changed
//               messages == "true"
//                   ? ListView.builder(
//                       itemCount: postsList.length,
//                       itemBuilder: (context, index) {
//                         print('GETTING LIST');
//                         print(
//                             'snapshot.data!.docs[index].data(): ${postsList[index]}');
//                         // Post post = Post.fromSnap(snapshot.data!.docs[index]);
//                         final User? user =
//                             Provider.of<UserProvider>(context).getUser;
//                         print(
//                             '_post.plus.contains(user.uid): ${postsList[index].plus.contains(user?.uid)}');
//                         return PostCardTest(
//                           post: postsList[index],
//                           indexPlacement: index,
//                         );
//                       })
//                   /* : global == "false" && messages == "true"
//                   ? StreamBuilder(
//                       stream: FirebaseFirestore.instance
//                           .collection('posts')
//                           .where("global", isEqualTo: global)
//                           .where("country", isEqualTo: flag)
//                           .orderBy("score", descending: true)
//                           .orderBy("datePublished", descending: false)
//                           .snapshots(),
//                       builder: (context,
//                           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
//                               snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         return ListView.builder(
//                             itemCount: snapshot.data!.docs.length,
//                             itemBuilder: (context, index) {
//                               // print('GETTTING LIST');
//                               // print(
//                               //     'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
//                               Post post =
//                                   Post.fromSnap(snapshot.data!.docs[index]);
//                               final User? user =
//                                   Provider.of<UserProvider>(context).getUser;
//                               // print(
//                               //     '_post.plus.contains(user.uid): ${post.plus.contains(user?.uid)}');
//                               return PostCard(
//                                 post: post,
//                                 indexPlacement: index,
//                               );
//                             });
//                         //   itemCount: snapshot.data!.docs.length,
//                         //   itemBuilder: (context, index) {
//                         //     return PostCardTest(
//                         //       snap: snapshot.data!.docs[index].data(),
//                         //       indexPlacement: index,
//                         //     );
//                         //   },
//                         // );
//                       },
//                     )*/

//                   //DISPLAY POLLS LIST
//                   : global == "true" && messages == "false"
//                       ? StreamBuilder(
//                           stream: FirebaseFirestore.instance
//                               .collection('polls')
//                               .where("global", isEqualTo: global)
//                               .orderBy("totalVotes", descending: true)
//                               .orderBy("datePublished", descending: false)
//                               .snapshots(),
//                           builder: (context,
//                               AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
//                                   snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Center(
//                                 child: CircularProgressIndicator(),
//                               );
//                             }
//                             return ListView.builder(
//                                 itemCount: snapshot.data!.docs.length,
//                                 itemBuilder: (context, index) {
//                                   // print('GETTTING LIST');
//                                   // print(
//                                   //     'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
//                                   Poll poll =
//                                       Poll.fromSnap(snapshot.data!.docs[index]);
//                                   final User? user =
//                                       Provider.of<UserProvider>(context)
//                                           .getUser;
//                                   // print(
//                                   //     '_post.plus.contains(user.uid): ${poll.plus.contains(user?.uid)}');
//                                   return PollCard(
//                                     poll: poll,
//                                     indexPlacement: index,
//                                   );
//                                 });
//                             //   itemBuilder: (context, index) {
//                             //     return PostCardTest(
//                             //       snap: snapshot.data!.docs[index].data(),

//                             //       indexPlacement: index,
//                             //     );
//                             //   },
//                             // );
//                           },
//                         )
//                       : StreamBuilder(
//                           stream: FirebaseFirestore.instance
//                               .collection('polls')
//                               .where("global", isEqualTo: global)
//                               .where("country",
//                                   isEqualTo: short[selectedCountryIndex])
//                               .orderBy("totalVotes", descending: true)
//                               .orderBy("datePublished", descending: false)
//                               .snapshots(),
//                           builder: (context,
//                               AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
//                                   snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Center(
//                                 child: CircularProgressIndicator(),
//                               );
//                             }

//                             return ListView.builder(
//                                 itemCount: snapshot.data!.docs.length,
//                                 itemBuilder: (context, index) {
//                                   // print('GETTTING LIST');
//                                   // print(
//                                   //     'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
//                                   Poll poll =
//                                       Poll.fromSnap(snapshot.data!.docs[index]);
//                                   final User? user =
//                                       Provider.of<UserProvider>(context)
//                                           .getUser;
//                                   // print(
//                                   //     '_post.plus.contains(user.uid): ${poll.plus.contains(user?.uid)}');
//                                   return PollCard(
//                                     poll: poll,
//                                     indexPlacement: index,
//                                   );
//                                 });
//                           },
//                         ),

//           // body: global == "true" && messages == "true"
//           //     ? StreamBuilder(
//           //         stream: FirebaseFirestore.instance
//           //             .collection('posts')
//           //             .where("global", isEqualTo: global)
//           //             .orderBy("score", descending: true)
//           //             .orderBy("datePublished", descending: false)
//           //             .snapshots(),
//           //         builder: (context,
//           //             AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
//           //                 snapshot) {
//           //           if (snapshot.connectionState == ConnectionState.waiting) {
//           //             return const Center(
//           //               child: CircularProgressIndicator(),
//           //             );
//           //           }
//           //           return snapshot.data!.docs.length != 0
//           //               ? ListView.builder(
//           //                   itemCount: snapshot.data!.docs.length,
//           //                   itemBuilder: (context, index) {
//           //                     print('GETTTING LIST');
//           //                     print(
//           //                         'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
//           //                     Post post =
//           //                         Post.fromSnap(snapshot.data!.docs[index]);
//           //                     final User? user =
//           //                         Provider.of<UserProvider>(context).getUser;
//           //                     print(
//           //                         '_post.plus.contains(user.uid): ${post.plus.contains(user?.uid)}');
//           //                     return PostCardTest(
//           //                       post: post,
//           //                       indexPlacement: index,
//           //                     );
//           //                   })
//           //               : Row(
//           //                   mainAxisAlignment: MainAxisAlignment.center,
//           //                   children: [
//           //                     Text('No global messages yet.',
//           //                         style: TextStyle(
//           //                             fontSize: 20,

//           //                             // fontWeight: FontWeight.bold,
//           //                             color: Color.fromARGB(255, 95, 95, 95))),
//           //                   ],
//           //                 );
//           //         },
//           //       )
//           //     : global == "false" && messages == "true"
//           //         ? StreamBuilder(
//           //             stream: FirebaseFirestore.instance
//           //                 .collection('posts')
//           //                 .where("global", isEqualTo: global)
//           //                 .where("country", isEqualTo: flag)
//           //                 .orderBy("score", descending: true)
//           //                 .orderBy("datePublished", descending: false)
//           //                 .snapshots(),
//           //             builder: (context,
//           //                 AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
//           //                     snapshot) {
//           //               if (snapshot.connectionState ==
//           //                   ConnectionState.waiting) {
//           //                 return const Center(
//           //                   child: CircularProgressIndicator(),
//           //                 );
//           //               }

//           //               return snapshot.data!.docs.length != 0
//           //                   ? ListView.builder(
//           //                       itemCount: snapshot.data!.docs.length,
//           //                       itemBuilder: (context, index) {
//           //                         // print('GETTTING LIST');
//           //                         // print(
//           //                         //     'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
//           //                         Post post =
//           //                             Post.fromSnap(snapshot.data!.docs[index]);
//           //                         final User? user =
//           //                             Provider.of<UserProvider>(context)
//           //                                 .getUser;
//           //                         // print(
//           //                         //     '_post.plus.contains(user.uid): ${post.plus.contains(user?.uid)}');
//           //                         return PostCardTest(
//           //                           post: post,
//           //                           indexPlacement: index,
//           //                         );
//           //                       })
//           //                   : Row(
//           //                       mainAxisAlignment: MainAxisAlignment.center,
//           //                       children: [
//           //                         Text('No',
//           //                             style: TextStyle(
//           //                                 fontSize: 20,

//           //                                 // fontWeight: FontWeight.bold,
//           //                                 color:
//           //                                     Color.fromARGB(255, 95, 95, 95))),
//           //                         Padding(
//           //                           padding: const EdgeInsets.symmetric(
//           //                               horizontal: 8.0),
//           //                           child: Container(
//           //                             width: 24,
//           //                             height: 16,
//           //                             child: Image.asset(
//           //                                 'icons/flags/png/${flag}.png',
//           //                                 package: 'country_icons'),
//           //                           ),
//           //                         ),
//           //                         Text('messages yet.',
//           //                             style: TextStyle(
//           //                                 fontSize: 20,

//           //                                 // fontWeight: FontWeight.bold,
//           //                                 color:
//           //                                     Color.fromARGB(255, 95, 95, 95))),
//           //                       ],
//           //                     );
//           //               //   itemCount: snapshot.data!.docs.length,
//           //               //   itemBuilder: (context, index) {
//           //               //     return PostCardTest(
//           //               //       snap: snapshot.data!.docs[index].data(),
//           //               //       indexPlacement: index,
//           //               //     );
//           //               //   },
//           //               // );
//           //             },
//           //           )

//           //         //DISPLAY POLLS LIST
//           //         : global == "true" && messages == "false"
//           //             ? StreamBuilder(
//           //                 stream: FirebaseFirestore.instance
//           //                     .collection('polls')
//           //                     .where("global", isEqualTo: global)
//           //                     .orderBy("totalVotes", descending: true)
//           //                     .orderBy("datePublished", descending: false)
//           //                     .snapshots(),
//           //                 builder: (context,
//           //                     AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
//           //                         snapshot) {
//           //                   if (snapshot.connectionState ==
//           //                       ConnectionState.waiting) {
//           //                     return const Center(
//           //                       child: CircularProgressIndicator(),
//           //                     );
//           //                   }
//           //                   return snapshot.data!.docs.length != 0
//           //                       ? ListView.builder(
//           //                           itemCount: snapshot.data!.docs.length,
//           //                           itemBuilder: (context, index) {
//           //                             // print('GETTTING LIST');
//           //                             // print(
//           //                             //     'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
//           //                             Poll poll = Poll.fromSnap(
//           //                                 snapshot.data!.docs[index]);
//           //                             final User? user =
//           //                                 Provider.of<UserProvider>(context)
//           //                                     .getUser;
//           //                             // print(
//           //                             //     '_post.plus.contains(user.uid): ${poll.plus.contains(user?.uid)}');
//           //                             return PollCard(
//           //                               poll: poll,
//           //                               indexPlacement: index,
//           //                             );
//           //                           })
//           //                       : Row(
//           //                           mainAxisAlignment: MainAxisAlignment.center,
//           //                           children: [
//           //                             Text('No global polls yet.',
//           //                                 style: TextStyle(
//           //                                     fontSize: 20,

//           //                                     // fontWeight: FontWeight.bold,
//           //                                     color: Color.fromARGB(
//           //                                         255, 95, 95, 95))),

//           //                             // Text('polls yet.',
//           //                             //     style: TextStyle(
//           //                             //         fontSize: 20,

//           //                             //         // fontWeight: FontWeight.bold,
//           //                             //         color: Color.fromARGB(
//           //                             //             255, 95, 95, 95))),
//           //                           ],
//           //                         );
//           //                   //   itemBuilder: (context, index) {
//           //                   //     return PostCardTest(
//           //                   //       snap: snapshot.data!.docs[index].data(),

//           //                   //       indexPlacement: index,
//           //                   //     );
//           //                   //   },
//           //                   // );
//           //                 },
//           //               )
//           //             : StreamBuilder(
//           //                 stream: FirebaseFirestore.instance
//           //                     .collection('polls')
//           //                     .where("global", isEqualTo: global)
//           //                     .where("country", isEqualTo: flag)
//           //                     .orderBy("totalVotes", descending: true)
//           //                     .orderBy("datePublished", descending: false)
//           //                     .snapshots(),
//           //                 builder: (context,
//           //                     AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
//           //                         snapshot) {
//           //                   if (snapshot.connectionState ==
//           //                       ConnectionState.waiting) {
//           //                     return const Center(
//           //                       child: CircularProgressIndicator(),
//           //                     );
//           //                   }

//           //                   return snapshot.data!.docs.length != 0
//           //                       ? ListView.builder(
//           //                           itemCount: snapshot.data!.docs.length,
//           //                           itemBuilder: (context, index) {
//           //                             // print('GETTTING LIST');
//           //                             // print(
//           //                             //     'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
//           //                             Poll poll = Poll.fromSnap(
//           //                                 snapshot.data!.docs[index]);
//           //                             final User? user =
//           //                                 Provider.of<UserProvider>(context)
//           //                                     .getUser;
//           //                             // print(
//           //                             //     '_post.plus.contains(user.uid): ${poll.plus.contains(user?.uid)}');
//           //                             return PollCard(
//           //                               poll: poll,
//           //                               indexPlacement: index,
//           //                             );
//           //                           })
//           //                       : Row(
//           //                           mainAxisAlignment: MainAxisAlignment.center,
//           //                           children: [
//           //                             Text('No',
//           //                                 style: TextStyle(
//           //                                     fontSize: 20,

//           //                                     // fontWeight: FontWeight.bold,
//           //                                     color: Color.fromARGB(
//           //                                         255, 95, 95, 95))),
//           //                             Padding(
//           //                               padding: const EdgeInsets.symmetric(
//           //                                   horizontal: 8.0),
//           //                               child: Container(
//           //                                 width: 24,
//           //                                 height: 16,
//           //                                 child: Image.asset(
//           //                                     'icons/flags/png/${flag}.png',
//           //                                     package: 'country_icons'),
//           //                               ),
//           //                             ),
//           //                             Text('polls yet.',
//           //                                 style: TextStyle(
//           //                                     fontSize: 20,

//           //                                     // fontWeight: FontWeight.bold,
//           //                                     color: Color.fromARGB(
//           //                                         255, 95, 95, 95))),
//           //                           ],
//           //                         );
//           //                   //   itemCount: snapshot.data!.docs.length,
//           //                   //   itemBuilder: (context, index) {
//           //                   //     return PostCardTest(
//           //                   //       snap: snapshot.data!.docs[index].data(),
//           //                   //       indexPlacement: index,
//           //                   //     );
//           //                   //   },
//           //                   // );
//           //                 },
//           //               ),
//         ),
//       ),
//     );
//   }

//   Widget rollingIconBuilderStringTwo(
//       String messages, Size iconSize, bool foreground) {
//     IconData data = Icons.poll;
//     if (messages == 'true') data = Icons.message;
//     return Icon(data, size: iconSize.shortestSide, color: Colors.white);
//   }

//   Widget rollingIconBuilderStringThree(
//       String global, Size iconSize, bool foreground) {
//     IconData data = Icons.flag;
//     if (global == 'true') data = Icons.public;
//     return Icon(data, size: iconSize.shortestSide, color: Colors.white);
//   }

//   // getValue() async {
//   loadCountryFilterValue() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       // oneValue = prefs.getString('selected_radio') ?? '';
//       // twoValue = prefs.getString('selected_radio1') ?? '';
//       // threeValue = prefs.getString('selected_radio2') ?? '';
//       selectedCountryIndex = prefs.getInt('countryRadio') ?? -1;
//     });
//   }
// }