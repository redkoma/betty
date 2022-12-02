import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:betty/util/style.dart';

class Util102ImageSlide extends StatefulWidget {
  const Util102ImageSlide({Key? key}) : super(key: key);

  @override
  _Util102ImageSlide createState() => _Util102ImageSlide();
}

class _Util102ImageSlide extends State<Util102ImageSlide> {
  Map arguments = {};

  Map obj = {};
  List<Widget> listImages = [];
  bool loaded = false;
  int _numPages = 3, _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _pageController.jumpToPage(obj['index']);
    });
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Size size = MediaQuery.of(context).size;

    if (!loaded) {
      loaded = true;
      obj = arguments;
    }
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(color: Colors.black),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 18.0),
                          child: Text(
                            'X',
                            style: TextStyle(color: Colors.white, fontSize: 26),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    height: size.height - 150,
                    child: PageView.builder(
                      itemBuilder: (context, position) {
                        TransformationController _controllerT = TransformationController();
                        String url = '';
                        if (obj['images'][position] is String) {
                          url = obj['images'][position];
                        } else {
                          url = obj['images'][position]['url'] ?? '';
                        }
                        return InteractiveViewer(
                            transformationController: _controllerT,
                            clipBehavior: Clip.none,
                            minScale: 0.5,
                            maxScale: 4,
                            onInteractionEnd: (details) {
                              _controllerT.value = Matrix4.identity();
                            },
                            child: Image.network(url, width: size.width));
                      },
                      itemCount: (obj['images'] ?? []).length,
                      physics: ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
