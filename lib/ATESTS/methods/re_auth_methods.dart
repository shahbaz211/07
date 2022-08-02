import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../other/utils.dart.dart';
import '../provider/user_provider.dart';
import 'auth_methods.dart';

class ReAuthenticationDialog extends StatefulWidget {
  final username;
  const ReAuthenticationDialog({Key? key, required this.username})
      : super(key: key);

  @override
  State<ReAuthenticationDialog> createState() => _ReAuthenticationDialogState();
}

class _ReAuthenticationDialogState extends State<ReAuthenticationDialog> {
  bool _isLoading = false;
  bool _authenticationFailed = false;
  bool _passwordVisible = false;
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            // width: double.infinity,
            // width: MediaQuery.of(context).size.width * 0.85,
            // height: MediaQuery.of(context).size.height * 0.44,
            width: 300,
            height: _authenticationFailed ? 275 : 255,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: Colors.white),
            padding: const EdgeInsets.fromLTRB(10, 55, 10, 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: Text('This action requires password confirmation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 83, 83, 83))),
                ),
                // const Padding(
                //   padding: EdgeInsets.only(top: 0.0),
                //   child: Text('Please enter your password below.',
                //       style: TextStyle(
                //         fontSize: 16,
                //       )),
                // ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                    left: 10,
                    right: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: _authenticationFailed,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            // color: Colors.blue,
                            height: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error,
                                    size: 16,
                                    color: Color.fromARGB(255, 220, 105, 96)),
                                Container(width: 4),
                                Text('Wrong password.',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 220, 105, 96))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 237, 237, 237),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 0,
                                color: Color.fromARGB(255, 212, 212, 212)),
                          ),
                          child: TextField(
                            // hintText: 'Enter your password',
                            // textInputType: TextInputType.text,
                            // textEditingController: passwordController,
                            // isPass: true,
                            controller: passwordController,
                            obscureText: !_passwordVisible,
                            onChanged: (val) {
                              setState(() {
                                _authenticationFailed = false;
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your password',
                              contentPadding: EdgeInsets.only(left: 8, top: 14),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                child: Icon(
                                  // Based on passwordVisible state choose the icon
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      _isLoading = true;
                    });

                    final User? user =
                        Provider.of<UserProvider>(context, listen: false)
                            .getUser;
                    print('user?.email: ${user?.email}');
                    print(
                        'passwordController.text: ${passwordController.text}');
                    String res = await AuthMethods().loginUser(
                      email: user?.email ?? '',
                      password: passwordController.text,
                    );

                    if (res == "success") {
                      setState(() {
                        _authenticationFailed = false;
                        _isLoading = false;
                      });
                      showSnackBar(
                          widget.username
                              ? 'Username successfully changed.'
                              : 'Email successfully changed.',
                          context);
                      Navigator.pop(context, true);
                    } else {
                      setState(() {
                        _authenticationFailed = true;
                        _isLoading = false;
                      });
                      // showSnackBar('Wrong password.', context);
                    }
                  },
                  child: Card(
                    elevation: 3,
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.blueGrey,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                height: 19,
                                width: 19,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('CONFIRM',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    )),
                                // Container(width: 10),
                                // Icon(Icons.login,
                                //     size: 22, color: Colors.white)
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -50,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: FittedBox(
                child: RotatedBox(
                  quarterTurns: 2,
                  child: Icon(
                    Icons.info,
                    size: 200,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
