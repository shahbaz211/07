import 'package:aft/ATESTS/authentication/ASignup.dart';
import 'package:aft/ATESTS/models/APost.dart';
import 'package:aft/ATESTS/models/AUser.dart';
import 'package:aft/ATESTS/provider/AUserProvider.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ACountriesValues.dart';
import 'ACountries.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({Key? key}) : super(key: key);

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  String oneValue = '';
  var global = 'true';

  @override
  void initState() {
    super.initState();
    getValue();
    getValueG();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    var countryIndex = long.indexOf(oneValue);
    String flag = '';
    if (countryIndex >= 0) {
      flag = short[countryIndex];
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            width: 360,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  color: Colors.white,
                  child: TextButton(
                    child:
                        Text('Sign up', style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                  ),
                ),
                //

                Column(
                  children: [
                    global == 'true'
                        ? Text(
                            'Global',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              letterSpacing: 1,
                            ),
                          )
                        : Text(
                            'National',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              letterSpacing: 1,
                            ),
                          ),
                    AnimatedToggleSwitch<String>.rollingByHeight(
                        height: 34,
                        current: global,
                        values: const [
                          'true',
                          'false',
                        ],
                        onChanged: (valueg) => setValueG(valueg.toString()),
                        iconBuilder: rollingIconBuilderStringThree,
                        borderRadius: BorderRadius.circular(75.0),
                        indicatorSize: const Size.square(1.8),
                        innerColor: Color.fromARGB(255, 203, 203, 203),
                        indicatorColor: Colors.black,
                        borderColor: Colors.white,
                        iconOpacity: 1),
                  ],
                ),

                //
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      TextButton(
                        child: Text('Countries',
                            style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Countries()),
                          ).then((value) => {getValue()});
                        },
                      ),
                      oneValue == ''
                          ? Container()
                          : Image.asset('icons/flags/png/${flag}.png',
                              package: 'country_icons', height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Text(''),
    );
  }

  Widget rollingIconBuilderStringThree(
      String global, Size iconSize, bool foreground) {
    IconData data = Icons.flag;
    if (global == 'true') data = Icons.circle;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      oneValue = prefs.getString('selected_radio') ?? '';
    });
  }
}
