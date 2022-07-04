import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

class ReportUserScreen extends StatefulWidget {
  const ReportUserScreen({Key? key}) : super(key: key);

  @override
  _ReportUserScreenState createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 241, 241, 241),
          body: Column(
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  color: Colors.blue,
                  width: 150,
                  height: 40,
                  child: Text('one'),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  color: Colors.orange,
                  width: 150,
                  height: 40,
                  child: Text('two'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
