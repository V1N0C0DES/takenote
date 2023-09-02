import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:takenote/constants/k_constants.dart';
import 'package:takenote/services/auth/auth_service.dart';
import 'package:takenote/views/archived_view.dart';
import 'package:takenote/views/notes/default/delete_view.dart';
import 'package:takenote/views/notes_view.dart';

import '../../constants/routes.dart';

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  // Get the current user's ID
  String get userId => AuthService.firebase().currentUser!.id;
  bool isGridView = false;
  late PageController _pageController;
  int _page = 0;

  // List of views for the PageView
  final _pageList = <Widget>[
    const NotesView(),
    const ArchivedView(),
    const DeleteView(),
  ];

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the floating action button location
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: kBdazalledBlue.withOpacity(0.95),

      body: Container(
        // Apply gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              kJungleGreen.withOpacity(0.9),
              kOxfordBlue,
              kOxfordBlue,
              kOxfordBlue,
              kOxfordBlue,
              kOxfordBlue,
              kOxfordBlue,
              kOxfordBlue,
            ],
          ),
        ),
        child: PageView(
          scrollDirection: Axis.vertical,
          physics: const RangeMaintainingScrollPhysics(),
          onPageChanged: onPageChanged,
          controller: _pageController,
          children: _pageList,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        backgroundColor: kOxfordBlue.withOpacity(0.9),
        selectedItemColor: kJungleGreen,
        iconSize: 30,
        unselectedItemColor: Colors.grey,
        elevation: 55,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.note),
            activeIcon: Icon(Iconsax.note1),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.archive),
            activeIcon: Icon(Iconsax.archive_11),
            label: 'Archive',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.trash),
            activeIcon: Icon(Iconsax.trash4),
            label: 'Deleted',
          ),
        ],
        currentIndex: _page,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        onTap: navigationTapped,
      ),
      // Build the appropriate floating action button based on the current page
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Build the floating action button based on the current page
  Widget _buildFloatingActionButton() {
    if (_page == 1) {
      return FloatingActionButton(
        tooltip: 'Add Archived Note',
        backgroundColor: kJungleDarkGreen.withOpacity(0.6),
        hoverColor: kBdazalledBlue,
        splashColor: kBdazalledBlue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        elevation: 10,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateArchiveNoteRoute);
        },
        child: const Icon(Iconsax.archive_add4, size: 30),
      );
    } else if (_page == 0) {
      return FloatingActionButton(
        tooltip: 'Add Note',
        backgroundColor: kJungleDarkGreen.withOpacity(0.6),
        hoverColor: kBdazalledBlue,
        splashColor: kBdazalledBlue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        elevation: 10,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        child: const Icon(Iconsax.pen_add, size: 30),
      );
    } else {
      return const SizedBox(); // Return an empty container for other pages
    }
  }
}
