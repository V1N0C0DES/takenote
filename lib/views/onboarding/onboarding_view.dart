import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takenote/constants/k_constants.dart';

import '../../services/auth/bloc/auth_bloc.dart';
import '../../services/auth/bloc/auth_event.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  late PageController _pageController;
  late SharedPreferences prefs;
  bool newUser = true;

  int _page = 0;

  void navigationForward(int page) {
    _pageController.animateToPage(page + 1,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
    // _pageController.jumpToPage(page);
  }

  void navigationBackward(int page) {
    _pageController.animateToPage(page - 1,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
    // _pageController.jumpToPage(page);
  }

  getPref() async {
    prefs = await SharedPreferences.getInstance();
    newUser = prefs.getBool('newUser') ?? true;
    if (!newUser) {
      if (mounted) {
        BlocProvider.of<AuthBloc>(context).add(const AuthEventInitialize());
      }
      //auth state logged in
    }
  }

  @override
  void initState() {
    super.initState();
    //If user is initialized then skip the onboarding

    getPref();
    _pageController = PageController();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kPlatinum,
            kJungleGreen,
            kJungleGreen,
            kRichBlackFogra,
          ],
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: FlexColorScheme.themedSystemNavigationBar(
          context,
          systemNavBarStyle: FlexSystemNavBarStyle.background,
          useDivider: false,
          opacity: 0,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: PageView(
            controller: _pageController,
            onPageChanged: onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: const [
              ScreenOne(),
              ScreenTwo(),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: kJungleGreen.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_page != 0)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () {
                          navigationBackward(_page);
                        },
                        child: Row(
                          children: const [
                            Icon(CupertinoIcons.back),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Back'),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        navigationForward(_page);
                        if (_page == 1) {
                          setState(() {
                            //AuthEventInitialize

                            BlocProvider.of<AuthBloc>(context)
                                .add(const AuthEventInitialize());
                            //Navigate to Register Page
                          });

                          // prefs.setBool('newUser', false);
                        }
                      },
                      child: Row(
                        children: const [
                          SizedBox(
                            width: 10,
                          ),
                          Text('Next'),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(CupertinoIcons.forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScreenOne extends StatefulWidget {
  const ScreenOne({Key? key}) : super(key: key);

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        const Text(
          'Welcome to',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        //hero animation
        Hero(
          tag: 'logo',
          child: Image.asset(
            'assets/icon/icontext.png',
            height: 190,
          ),
        ),
      ],
    );
  }
}

class ScreenTwo extends StatefulWidget {
  const ScreenTwo({Key? key}) : super(key: key);

  @override
  State<ScreenTwo> createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Take note logo with text

            // Hero
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/icon/icon.png',
                  height: 190,
                  width: 200,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Divider(
              color: Colors.white,
              thickness: 1,
            ),
            const SizedBox(height: 30),

            const SizedBox(height: 10),
            // app logo

            ListTile(
              leading: Image.asset(
                'assets/icon/icon.png',
                height: 30,
              ),
              // Center Title
              title: const Center(
                child: Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              trailing: const Icon(
                Iconsax.add_circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(
              color: Colors.white,
              thickness: 1,
              indent: 40,
              endIndent: 40,
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 10),
            ListTile(
              leading: Image.asset(
                'assets/icon/icon.png',
                height: 30,
              ),
              // Center Title
              title: const Center(
                child: Text(
                  'Archive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              trailing: const Icon(
                Iconsax.archive,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),
            const Divider(
              color: Colors.white,
              thickness: 1,
              indent: 40,
              endIndent: 40,
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 10),
            ListTile(
              leading: Image.asset(
                'assets/icon/icon.png',
                height: 30,
              ),
              // Center Title
              title: const Center(
                child: Text(
                  'Color Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              trailing: const Icon(
                Iconsax.color_swatch,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
