import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../constants/k_constants.dart';
import '../../../enums/menu_action.dart';
import '../../../services/auth/bloc/auth_bloc.dart';
import '../../../services/auth/bloc/auth_event.dart';
import '../../../utilities/dialogs/logout_dialog.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isGridView = false;
  bool isTileView = true;
  // List<Notes> notesList = [];
  int selectedPageColor = 1;
  // final dbHelper = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();

  final FocusNode searchFocusNode = FocusNode();

  bool _showClearButton = false;

  // loadNotes(searchText) async {
  //   if (searchText.toString().isEmpty)
  //     notesList.clear();
  //   else
  //     await dbHelper.getNotesAll(searchText).then((value) {
  //       setState(() {
  //         print(value.length);
  //         notesList = value;
  //       });
  //     });
  // }

  @override
  void initState() {
    // loadNotes();
    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBdazalledBlue,
      appBar: AppBar(
        //dynaimc island ios
        backgroundColor: kOxfordBlue,

        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
          //   },
          //   icon: const Icon(Icons.add),
          // ),
          // //PopupMenuButton grid or list

          IconButton(
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
            //icon is grid or list
            icon: isGridView
                ? const Icon(Icons.view_module_rounded)
                : const Icon(Icons.list),
          ),
          PopupMenuButton<MenuAction>(
            // rounded corners
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            elevation: 10,
            offset: const Offset(0, 50),
            color: kJungleGreen,

            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    if (!mounted) {
                      return;
                    }
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: textLogoutStyle,
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 21, bottom: 20),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: TextField(
                    style: const TextStyle(color: Colors.white),
                    cursorColor: kPlatinum,

                    autofocus: true,
                    controller: _searchController,
                    decoration: InputDecoration(
                      floatingLabelStyle: const TextStyle(
                        color: kPlatinum,
                      ),
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                        color: kPlatinum,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // onChanged: (value) => loadNotes(value),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Visibility(
                    visible: _showClearButton,
                    child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                          });
                          // notesList.clear();
                        },
                        child: const Icon(Iconsax.close_circle)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _searchController.text.isEmpty,
            child: Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      height: 80,
                    ),
                    Icon(
                      Iconsax.search_status,
                      size: 100,
                      color: kJungleGreen,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Type to start searching.....',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 22,
                        color: kJungleGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: _searchController.text.isNotEmpty,
            child: Expanded(
                child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              // child: ListView.builder(
              //   physics: BouncingScrollPhysics(
              //       parent: AlwaysScrollableScrollPhysics()),
              //   itemBuilder: (context, index) {
              //     return NoteCardList(
              //       note: notesList[index],
              //       onTap: () {
              //         _showNoteReader(context, notesList[index]);
              //       },
              //     );
              //   },
              //   itemCount: notesList.length,
              // ),
            )),
          )
        ],
      ),
    );
  }
}
