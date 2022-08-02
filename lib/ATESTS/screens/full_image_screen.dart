import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';

class FullImageScreen extends StatefulWidget {
  final Post post;
  const FullImageScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<FullImageScreen> createState() => _FullImageScreenState();
}

class _FullImageScreenState extends State<FullImageScreen> {
  late Post _post;

  @override
  void initState() {
    _post = widget.post;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var safePadding = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              elevation: 0,
              backgroundColor:
                  Color.fromARGB(255, 235, 235, 235).withOpacity(0.25),
              title:
                  Text('Image Viewer', style: TextStyle(color: Colors.black))),
          backgroundColor: Color.fromARGB(255, 235, 235, 235),
          body: Container(
            // height: MediaQuery.of(context).size.height * 1 -
            //     safePadding -
            //     kToolbarHeight,
            // width: MediaQuery.of(context).size.width * 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Container(
                //   height: MediaQuery.of(context).size.height * 0.06,
                //   child: Container(
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Color.fromARGB(255, 186, 186, 186),
                //     ),
                //     alignment: Alignment.center,
                //     child: InkWell(
                //       onTap: () {
                //         Navigator.of(context).pop();
                //       },
                //       child: const Icon(
                //         Icons.clear,
                //         color: Colors.white,
                //         size: 40,
                //       ),
                //     ),
                //   ),
                // ),
                InteractiveViewer(
                  clipBehavior: Clip.none,
                  minScale: 1,
                  maxScale: 4,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 1 -
                        safePadding -
                        kToolbarHeight,
                    width: MediaQuery.of(context).size.width * 0.95,
                    decoration: BoxDecoration(
                      // color: Colors.blue,
                      color: Color.fromARGB(255, 235, 235, 235),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: Image.network(
                      _post.postUrl,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      // color: Colors.grey,
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
