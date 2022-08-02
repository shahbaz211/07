import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'filter_arrays.dart';

class Countries extends StatefulWidget {
  @override
  State<Countries> createState() => _CountriesState();
}

class _CountriesState extends State<Countries> {
  final TextEditingController _countriesController = TextEditingController();

  String searchText = '';

  int selectedCountryIndex = short.indexOf('us');
  bool textFieldFocus = true;
  bool textfield1selected = false;
  late final KeyboardVisibilityController _keyboardVisibilityController;
  late StreamSubscription<bool> keyboardSubscription;
  var oneValue = 'Highest Score';
  var oneiValue = 'Highest Score';
  var twoValue = '≤ 1';
  String idk = 'false';

  @override
  void initState() {
    super.initState();
    _keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        _keyboardVisibilityController.onChange.listen((isVisible) {
      print('aaaa');
      print(_keyboardVisibilityController.isVisible);
      print('abc');

      if (!isVisible) {
        print('bbbb');

        setState(() {
          textfield1selected = false;
        });

        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
    getValue();
    _countriesController.addListener(_filterList);
  }

  @override
  void dispose() {
    _countriesController.dispose();
    super.dispose();
  }

  void _filterList() {
    // this is calle on evey keystroke.
    print('Search value: ${_countriesController.text}');

    setState(() {
      searchText = _countriesController.text.toLowerCase();
    });
  }

  // Future<void>
  getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio') != null) {
      setState(() {
        selectedCountryIndex = prefs.getInt('countryRadio')!;
      });
    }
  }

  // Future<void>
  setValue(int countryIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCountryIndex = countryIndex;
      prefs.setInt('countryRadio', selectedCountryIndex);
      prefs.setString('selected_radio', long[selectedCountryIndex]);
    });
  }

  //Future<void>
  getValueOne() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio1') != null) {
      setState(() {
        twoValue = prefs.getString('selected_radio1')!;
      });
    }
  }

  //Future<void>
  setValueOne(String valueo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      twoValue = valueo.toString();
      prefs.setString('selected_radio1', twoValue);
    });
  }

  //Future<void>
  getValue1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio') != null) {
      setState(() {
        oneValue = prefs.getString('selected_radio')!;
      });
    }
  }

  //Future<void>
  setValue1(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      oneValue = value.toString();
      prefs.setString('selected_radio', oneValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> filtedlist = long
        .where(
            (c) => c.toLowerCase().startsWith(searchText) || searchText == '')
        .toList();

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            actions: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        height: 50,
                        child: PhysicalModel(
                          color: Colors.white,
                          // elevation: 0.4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.arrow_back,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  Center(
                                    child: Text('Filter',
                                        style: TextStyle(
                                            fontSize: 22,
                                            letterSpacing: 1,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, right: 14, left: 8, bottom: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 243, 243, 243),
                                    border: Border.all(
                                      width: 0,
                                      color: Color.fromARGB(255, 173, 173, 173),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(25.0),
                                    ),
                                  ),
                                  width: 200,
                                  height: 50,
                                  child: Theme(
                                    child: TextField(
                                      onEditingComplete: () {
                                        print('complete');
                                      },
                                      onTap: () {
                                        setState(() {
                                          textfield1selected = true;
                                        });
                                      },
                                      // onSubmitted: (t) {
                                      //   setState(() {
                                      //     textfield1selected = false;
                                      //   });
                                      // },
                                      maxLines: 1,
                                      controller: _countriesController,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.search,
                                            color: textfield1selected == false
                                                ? Colors.grey
                                                : Colors.black,
                                            size: 20),
                                        hintText: "Search Countries",
                                        labelStyle: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.normal,
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                          top: 0,
                                        ),
                                      ),
                                    ),
                                    data: ThemeData(
                                      colorScheme:
                                          ThemeData().colorScheme.copyWith(
                                                primary: Color.fromARGB(
                                                    255, 131, 135, 138),
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Center(
                            child: Text('-',
                                style: TextStyle(
                                    fontSize: 13.8,
                                    letterSpacing: 0.5,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Center(
                            child: Text('-',
                                style: TextStyle(
                                    fontSize: 13.8,
                                    letterSpacing: 0.5,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Center(
                            child: Text('Countries',
                                style: TextStyle(
                                    fontSize: 13.8,
                                    letterSpacing: 0.5,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    itemCount: one.length,
                    controller: ScrollController(),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => NoRadioListTile<String>(
                        value: one[index],
                        groupValue: idk != 'false' ? oneValue : 'Highest Score',
                        leading: one[index],
                        miscDays: false,
                        onChanged: (value) {
                          setValue1(
                            value.toString(),
                          );
                        }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: two.length,
                    controller: ScrollController(),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => NoRadioListTile<String>(
                      value: two[index],
                      groupValue: twoValue,
                      leading: two[index],
                      miscDays: true,
                      onChanged: (valueo) {
                        two[index] == '7'
                            ? setState(
                                () {
                                  idk = 'true';
                                },
                              )
                            : two[index] == '7'
                                ? setState(
                                    () {
                                      idk = 'false';
                                    },
                                  )
                                : null;
                        setValueOne(valueo.toString());
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtedlist.length,
                    controller: ScrollController(),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => MyRadioListTile(
                        selectedIndex: selectedCountryIndex,
                        index: long.indexOf(filtedlist[index]),
                        onChanged: (value) => setValue(value)),

                    // itemBuilder: (context, index) => NoRadioListTile<String>(
                    //   value: filtedlist[index],
                    //   groupValue: threeValue,
                    //   title: filtedlist[index],
                    //   countries: false,
                    //   weight: true,
                    //   onChanged: (valuet) {
                    //     setValueTwo(valuet.toString());
                    //   },
                    // ),
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

class NoRadioListTile<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final String leading;
  final ValueChanged<T?> onChanged;
  final bool miscDays;

  const NoRadioListTile({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.leading,
    required this.miscDays,
  });

  @override
  State<NoRadioListTile<T>> createState() => _NoRadioListTileState<T>();
}

class _NoRadioListTileState<T> extends State<NoRadioListTile<T>> {
  String twoValue = '';

  @override
  void initState() {
    super.initState();
    getValue9();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.value == widget.groupValue;

    return InkWell(
      onTap: () {
        widget.onChanged(widget.value);
        print(widget.value);
        print(widget.leading.toString());
        print(widget.miscDays);
      },
      child: Container(
        height: 41,
        child: Container(
          decoration: BoxDecoration(
              color:
                  isSelected ? Colors.grey : Color.fromARGB(255, 240, 240, 240),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  width: 0.2, color: isSelected ? Colors.black : Colors.grey)),
          // : null,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Container(
                    child: widget.leading == 'Highest Score'
                        ? Icon(
                            Icons.trending_up,
                            color: isSelected ? Colors.white : Colors.grey,
                            size: 21,
                          )
                        : widget.leading == 'Most Recent'
                            ? Icon(
                                Icons.stars,
                                color: isSelected ? Colors.white : Colors.grey,
                                size: 21,
                              )
                            : null),
              ),
              const SizedBox(width: 4),
              Center(
                child: Container(
                  width: widget.miscDays
                      ? MediaQuery.of(context).size.width / 3 - 60
                      : MediaQuery.of(context).size.width / 3 - 60,
                  child: Text(
                    widget.leading,
                    textAlign: widget.miscDays == true
                        ? TextAlign.center
                        : TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600]!,
                      // fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getValue9() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      twoValue = prefs.getString('selected_radio1') ?? '';
    });
  }
}

class MyRadioListTile extends StatelessWidget {
  final int selectedIndex;
  final int index;
  final ValueChanged<int> onChanged;

  const MyRadioListTile({
    required this.onChanged,
    required this.selectedIndex,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    String flag = short[index];
    return InkWell(
      onTap: () => onChanged(index),
      child: Container(
        height: 41,
        // decoration: BoxDecoration(border: Border.all(width: 0)),
        child: Container(
          child: InkWell(
            onTap: () => onChanged(index),
            child: Container(
              height: 41,
              child: Container(
                width: 200,
                padding: EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                    color: index == selectedIndex
                        ? Colors.grey
                        : Color.fromARGB(255, 240, 240, 240),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        width: 0.2,
                        color: index == selectedIndex
                            ? Colors.black
                            : Colors.grey)),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, right: 2),
                      child: Container(
                        width: 25,
                        height: 15,
                        child: Image.asset('icons/flags/png/${flag}.png',
                            package: 'country_icons'),
                      ),
                    ),
                    Center(
                      child: Container(
                        // color: Colors.blue,
                        width: MediaQuery.of(context).size.width / 3 - 50,
                        child: Text(
                          long[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: index == selectedIndex
                                ? Colors.white
                                : Colors.grey[600]!,
                            // fontSize: isSelected ? 10 : 10,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
