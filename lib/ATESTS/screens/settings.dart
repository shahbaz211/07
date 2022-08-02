import 'package:aft/ATESTS/screens/profile_screen_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authentication/signup.dart';
import '../methods/auth_methods.dart';
import '../models/user.dart';
import '../other/utils.dart.dart';
import '../provider/user_provider.dart';
import 'blocked_list.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // var userData = {};

  // @override
  // void initState() {
  //   super.initState();
  //   getData();
  // }

  // getData() async {
  //   try {
  //     // var snap = await FirebaseFirestore.instance
  //     //     .collection('users')
  //     //     .doc(widget.uid)
  //     //     .get();
  //     var postSnap = await FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: _post.uid)
  //     // userData = snap.data()!;
  //     setState(() {});
  //   } catch (e) {
  //     // showSnackBar(cont
  //     //   // context,
  //     //   // e.toString(),
  //     // );
  //   }
  // }

  _contactInfo(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              // width: double.infinity,
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.37,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              padding: EdgeInsets.fromLTRB(20, 45, 20, 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 14.0,
                    ),
                    child: Text('Contact Information',
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold)),
                  ),
                  Container(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 18),
                    child: Text(
                        'Have any questions, suggestions, inquiries or simply need help?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            // fontWeight: FontWeight.w500,
                            fontSize: 15.5,
                            color: Colors.black)),
                  ),
                  Text('Contact us at:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          // fontWeight: FontWeight.w500,
                          fontSize: 15.5,
                          color: Colors.black)),
                  Text(
                    'Email@Gmail.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -50,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                child: CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  radius: 43.5,
                  child: FittedBox(
                    child: Icon(
                      Icons.email_outlined,
                      size: 55,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    bool isUserLoggedIn = user != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20),
          child: Text('Settings',
              style: TextStyle(
                  color: Colors.black, fontSize: 21, letterSpacing: 0.5)),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.transparent,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(
                        // top: BorderSide(width: 0, color: Colors.grey),
                        // bottom: BorderSide(width: 0, color: Colors.grey),
                        ),
                  ),
                  //ACCOUNT CONTROLS CONTAINER
                  child: Container(
                    child: isUserLoggedIn
                        ? Container(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 32, top: 20),
                                  width: MediaQuery.of(context).size.width * 1,
                                  // color: Colors.blue,
                                  child: Text('Personalization',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Material(
                                    color: Colors.white,
                                    child: InkWell(
                                      splashColor: Colors.grey.withOpacity(0.5),
                                      onTap: () {
                                        Future.delayed(
                                            const Duration(milliseconds: 150),
                                            () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProfile()),
                                          );
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 32, top: 19, bottom: 19),
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_outline,
                                                size: 23),
                                            Container(width: 15),
                                            Container(
                                              child: Text(
                                                'Profile',
                                                style: const TextStyle(
                                                    fontSize: 16.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Material(
                                    color: Colors.white,
                                    child: InkWell(
                                      splashColor: Colors.grey.withOpacity(0.5),
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 32, top: 19, bottom: 19),
                                        child: Row(
                                          children: [
                                            Icon(Icons.translate, size: 23),
                                            Container(width: 15),
                                            Container(
                                              child: Text(
                                                'Language',
                                                style: const TextStyle(
                                                    fontSize: 16.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Material(
                                    color: Colors.white,
                                    child: InkWell(
                                      splashColor: Colors.grey.withOpacity(0.5),
                                      onTap: () {
                                        Future.delayed(
                                            const Duration(milliseconds: 150),
                                            () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BlockedList()),
                                          );
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 32, top: 19, bottom: 19),
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Icon(Icons.block, size: 23),
                                              Container(width: 15),
                                              Text(
                                                'Blocked List',
                                                style: const TextStyle(
                                                    fontSize: 16.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        // top: BorderSide(width: 0, color: Colors.grey),
                                        // bottom: BorderSide(width: 0, color: Colors.grey),
                                        ),
                                  ),
                                  //ACCOUNT CONTROLS CONTAINER
                                  child: Column(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: 32, top: 19),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        // color: Colors.blue,
                                        child: Text('Information',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            onTap: () {},
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons.security_outlined,
                                                        size: 23),
                                                    Container(width: 15),
                                                    Text(
                                                      'Data Privacy',
                                                      style: const TextStyle(
                                                          fontSize: 16.5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            onTap: () {},
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .speaker_notes_outlined,
                                                        size: 23),
                                                    Container(width: 15),
                                                    Text(
                                                      'Terms & Conditions',
                                                      style: const TextStyle(
                                                          fontSize: 16.5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            splashColor:
                                                Colors.grey.withOpacity(0.5),
                                            onTap: () {
                                              // Future.delayed(
                                              //     const Duration(
                                              //         milliseconds: 150), () {
                                              _contactInfo(context);
                                              // });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.email_outlined,
                                                      size: 23),
                                                  Container(width: 15),
                                                  Container(
                                                    child: Text(
                                                      'Contact Us',
                                                      style: const TextStyle(
                                                          fontSize: 16.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        // top: BorderSide(width: 0, color: Colors.grey),
                                        // bottom: BorderSide(width: 0, color: Colors.grey),
                                        ),
                                  ),
                                  //ACCOUNT CONTROLS CONTAINER
                                  child: Column(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: 32, top: 19),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        // color: Colors.blue,
                                        child: Text('Account Controls',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            splashColor:
                                                Colors.grey.withOpacity(0.5),
                                            onTap: () {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 150), () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProfile()),
                                                );
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .folder_shared_outlined,
                                                      size: 23),
                                                  Container(width: 15),
                                                  Container(
                                                    child: Text(
                                                      'Account Information',
                                                      style: const TextStyle(
                                                          fontSize: 16.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            splashColor:
                                                Colors.grey.withOpacity(0.5),
                                            onTap: () async {
                                              if (isUserLoggedIn) {
                                                var val = await AuthMethods()
                                                    .signOut();
                                                Provider.of<UserProvider>(
                                                        context,
                                                        listen: false)
                                                    .logoutUser();
                                              }
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 150), () {
                                                goToLogin(context);
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.login, size: 23),
                                                    Container(width: 15),
                                                    Text(
                                                      'Logout',
                                                      style: const TextStyle(
                                                          fontSize: 16.5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //       // border: Border(
                                      //       //     bottom: BorderSide(width: 0, color: Colors.black),
                                      //       //     top: BorderSide(width: 0, color: Colors.black))),
                                      //       ),
                                      //   width:
                                      //       MediaQuery.of(context).size.width *
                                      //           1,
                                      //   child: Material(
                                      //     color: Colors.white,
                                      //     child: InkWell(
                                      //       onTap: () {
                                      //         Future.delayed(
                                      //             const Duration(
                                      //                 milliseconds: 150), () {
                                      //           Navigator.of(context).push(
                                      //             MaterialPageRoute(
                                      //                 builder: (context) =>
                                      //                     VerifyOne()),
                                      //           );
                                      //         });
                                      //       },
                                      //       child: isUserLoggedIn
                                      //           ? Row()
                                      //           : Container(
                                      //               child: Padding(
                                      //                 padding:
                                      //                     const EdgeInsets.only(
                                      //                         left: 32,
                                      //                         top: 19,
                                      //                         bottom: 19),
                                      //                 child: Row(
                                      //                   children: [
                                      //                     Icon(
                                      //                         Icons
                                      //                             .verified_user_outlined,
                                      //                         size: 23),
                                      //                     Container(width: 15),
                                      //                     Container(
                                      //                       child: Text(
                                      //                         'Sign Up',
                                      //                         style:
                                      //                             const TextStyle(
                                      //                                 fontSize:
                                      //                                     16.5),
                                      //                       ),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //     ),
                                      //   ),
                                      // ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            splashColor:
                                                Colors.grey.withOpacity(0.5),
                                            onTap: () async {
                                              // final User? user = Provider.of<UserProvider>(context).getUser;
                                              // bool isUserLoggedIn = user != null;
                                              return showDialog(
                                                context: context,
                                                builder: (_) => Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  insetPadding: EdgeInsets.zero,
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    alignment: Alignment.center,
                                                    children: <Widget>[
                                                      Container(
                                                        // width: double.infinity,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.85,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.365,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color:
                                                                Colors.white),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                20, 45, 20, 10),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                top: 14.0,
                                                              ),
                                                              child: Text(
                                                                  'Are you sure?',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          21,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 12.0,
                                                                      bottom:
                                                                          10),
                                                              child: Column(
                                                                children: [
                                                                  // Text('Are you sure?',
                                                                  //     textAlign: TextAlign.center,
                                                                  //     style: TextStyle(
                                                                  //         fontWeight: FontWeight.w500,
                                                                  //         fontSize: 15.5,
                                                                  //         color: Colors.black)),
                                                                  Text(
                                                                      'Deleting your account is permanent and this action cannot be undone.',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          // fontWeight: FontWeight.w500,
                                                                          fontSize: 15.5,
                                                                          color: Colors.black)),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              color:
                                                                  Colors.white,
                                                              height: 45,
                                                              child: Material(
                                                                color: Colors
                                                                    .white,
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    AuthMethods()
                                                                        .deleteUser(
                                                                            user.uid);
                                                                    if (isUserLoggedIn) {
                                                                      var val =
                                                                          await AuthMethods()
                                                                              .signOut();
                                                                      Provider.of<UserProvider>(
                                                                              context,
                                                                              listen: false)
                                                                          .logoutUser();
                                                                    }
                                                                    Future.delayed(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                150),
                                                                        () {
                                                                      goToLogin(
                                                                          context);
                                                                      showSnackBar(
                                                                          'Account Deleted',
                                                                          context);
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      'Delete Account',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .red,
                                                                          fontSize:
                                                                              17,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              color:
                                                                  Colors.white,
                                                              height: 45,
                                                              child: Material(
                                                                color: Colors
                                                                    .white,
                                                                child: InkWell(
                                                                  splashColor: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                  onTap: () {
                                                                    Future.delayed(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                150),
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      'Cancel',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: -50,
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.white,
                                                          radius: 50,
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    103,
                                                                    103),
                                                            radius: 43.5,
                                                            child: FittedBox(
                                                              child: Icon(
                                                                Icons
                                                                    .delete_forever_outlined,
                                                                size: 65,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .delete_forever_outlined,
                                                      size: 23,
                                                      color: Colors.black),
                                                  Container(width: 15),
                                                  Container(
                                                    child: Text(
                                                      'Delete Account',
                                                      style: const TextStyle(
                                                          fontSize: 16.5,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                  // top: BorderSide(width: 0, color: Colors.grey),
                                  // bottom: BorderSide(width: 0, color: Colors.grey),
                                  ),
                            ),
                            //ACCOUNT CONTROLS CONTAINER
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 32, top: 19),
                                  width: MediaQuery.of(context).size.width * 1,
                                  // color: Colors.blue,
                                  child: Text('Account Controls',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                ),
                                // Container(
                                //   width: MediaQuery.of(context).size.width * 1,
                                //   child: Material(
                                //     color: Colors.white,
                                //     child: InkWell(
                                //       onTap: () {
                                //         Future.delayed(
                                //             const Duration(milliseconds: 150), () {
                                //           Navigator.of(context).push(
                                //             MaterialPageRoute(
                                //                 builder: (context) =>
                                //                     ProfileScreen()),
                                //           );
                                //         });
                                //       },
                                //       child: Padding(
                                //         padding: const EdgeInsets.only(
                                //             left: 32, top: 19, bottom: 19),
                                //         child: Row(
                                //           children: [
                                //             Icon(Icons.folder_shared_outlined,
                                //                 size: 23),
                                //             Container(width: 15),
                                //             Container(
                                //               child: Text(
                                //                 'Account Information',
                                //                 style:
                                //                     const TextStyle(fontSize: 16.5),
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Material(
                                    color: Colors.white,
                                    child: InkWell(
                                      splashColor: Colors.grey.withOpacity(0.5),
                                      onTap: () async {
                                        if (isUserLoggedIn) {
                                          var val =
                                              await AuthMethods().signOut();
                                          Provider.of<UserProvider>(context,
                                                  listen: false)
                                              .logoutUser();
                                        }
                                        Future.delayed(
                                            const Duration(milliseconds: 150),
                                            () {
                                          goToLogin(context);
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 32, top: 19, bottom: 19),
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Icon(Icons.login, size: 23),
                                              Container(width: 15),
                                              Text(
                                                'Login',
                                                style: const TextStyle(
                                                    fontSize: 16.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      // border: Border(
                                      //     bottom: BorderSide(width: 0, color: Colors.black),
                                      //     top: BorderSide(width: 0, color: Colors.black))),
                                      ),
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Material(
                                    color: Colors.white,
                                    child: InkWell(
                                      splashColor: Colors.grey.withOpacity(0.5),
                                      onTap: () {
                                        Future.delayed(
                                            const Duration(milliseconds: 150),
                                            () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignupScreen()),
                                          );
                                        });
                                      },
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 32, top: 19, bottom: 19),
                                          child: Row(
                                            children: [
                                              Icon(Icons.verified_user,
                                                  size: 23),
                                              Container(width: 15),
                                              Container(
                                                child: Text(
                                                  'Sign Up',
                                                  style: const TextStyle(
                                                      fontSize: 16.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        // top: BorderSide(width: 0, color: Colors.grey),
                                        // bottom: BorderSide(width: 0, color: Colors.grey),
                                        ),
                                  ),
                                  //ACCOUNT CONTROLS CONTAINER
                                  child: Column(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: 32, top: 19),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        // color: Colors.blue,
                                        child: Text('Information',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            splashColor:
                                                Colors.grey.withOpacity(0.5),
                                            onTap: () async {},
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons.security_outlined,
                                                        size: 23),
                                                    Container(width: 15),
                                                    Text(
                                                      'Data Privacy',
                                                      style: const TextStyle(
                                                          fontSize: 16.5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            splashColor:
                                                Colors.grey.withOpacity(0.5),
                                            onTap: () async {},
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .speaker_notes_outlined,
                                                        size: 23),
                                                    Container(width: 15),
                                                    Text(
                                                      'Terms & Conditions',
                                                      style: const TextStyle(
                                                          fontSize: 16.5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            splashColor:
                                                Colors.grey.withOpacity(0.5),
                                            onTap: () {
                                              _contactInfo(context);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.email_outlined,
                                                      size: 23),
                                                  Container(width: 15),
                                                  Container(
                                                    child: Text(
                                                      'Contact Us',
                                                      style: const TextStyle(
                                                          fontSize: 16.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        // top: BorderSide(width: 0, color: Colors.grey),
                                        // bottom: BorderSide(width: 0, color: Colors.grey),
                                        ),
                                  ),
                                  //ACCOUNT CONTROLS CONTAINER
                                  child: Column(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: 32, top: 20),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        // color: Colors.blue,
                                        child: Text('Personalization',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            splashColor:
                                                Colors.grey.withOpacity(0.5),
                                            onTap: () {},
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 32,
                                                  top: 19,
                                                  bottom: 19),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.translate,
                                                      size: 23),
                                                  Container(width: 15),
                                                  Container(
                                                    child: Text(
                                                      'Language',
                                                      style: const TextStyle(
                                                          fontSize: 16.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
