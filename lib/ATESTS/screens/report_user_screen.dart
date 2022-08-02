import 'dart:convert';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../other/utils.dart.dart';
import '../provider/user_provider.dart';

class ReportUserScreen extends StatefulWidget {
  const ReportUserScreen({Key? key}) : super(key: key);

  @override
  _ReportUserScreenState createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  User? user;
  String one = 'one';
  String two = 'two';

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context).getUser;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 241, 241, 241),
          body: Column(
            children: [
              InkWell(
                onTap: () {
                  sendEmail(
                    receiverName: user?.username ?? '',
                    // receiverEmail: user?.email ?? '',
                    receiverEmail: 'seb.doyon21@gmail.com',
                    senderEmail: 'seb.doyon21@gmail.com',
                    senderName: 'Raj Thakur',
                    subject: 'From Admin',
                    message: one,
                  );
                },
                child: Container(
                  color: Colors.blue,
                  width: 150,
                  height: 40,
                  child: Text(one),
                ),
              ),
              InkWell(
                onTap: () {
                  sendEmail(
                    receiverName: user?.username ?? '',
                    // receiverEmail: user?.email ?? '',
                    receiverEmail: 'seb.doyon21@gmail.com',
                    senderEmail: 'seb.doyon21@gmail.com',
                    senderName: 'Raj Thakur',
                    subject: 'From Admin',
                    message: two,
                  );
                },
                child: Container(
                  color: Colors.orange,
                  width: 150,
                  height: 40,
                  child: Text(two),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future sendEmail({
    // Sender
    required String senderName,
    required String senderEmail,

    // Receiver
    required String receiverName,
    required String receiverEmail,

    // Email
    required String subject,
    required String message,
  }) async {
    var url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    var response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'service_id': 'service_4gvh2of',
        'template_id': 'template_ln69u1g',
        'user_id': 'Kil1lduE_7f94fMy1',
        'template_params': {
          'sender_name': senderName,
          'sender_email': senderEmail,
          'receiver_name': receiverName,
          'receiver_email': receiverEmail,
          'subject': subject,
          'message': message,
        }
      }),
    );

    print('response: ${response.body}');
    showSnackBar('Email sent successfully to $receiverEmail.', context);
  }
}
