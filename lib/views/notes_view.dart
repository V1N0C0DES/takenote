import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takenote/views/notes/grid_views/notes_grid_view.dart';
import 'package:takenote/views/notes/list_views/notes_list_view.dart';
import 'package:takenote/widgets/animations/fade_animation.dart';
import 'package:takenote/constants/k_constants.dart';
import 'package:takenote/constants/routes.dart';
import 'package:takenote/services/auth/auth_service.dart';
import 'package:takenote/services/auth/bloc/auth_bloc.dart';
import 'package:takenote/services/auth/bloc/auth_event.dart';
import 'package:takenote/services/cloud/cloud_note.dart';
import 'package:takenote/services/cloud/firebase_cloud_storage.dart';
import 'package:takenote/utilities/dialogs/logout_dialog.dart';

import '../enums/menu_action.dart';

enum ViewType { tile, grid }

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;
  bool isGridView = true;
  bool isTileView = false;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    // _notesService.open();
    //Ensure DB OPEN NEGATES THE EXTRA CALL
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      delay: 0.2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: NotesAppBarContainer,
          title: const Text(
            'Notes',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white,),
          ),
          actions: [
            IconButton(
              color: Colors.white,
              onPressed: () {
                setState(() {
                  isGridView = !isGridView;
                  //Show Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: isGridView
                          ? const Text(
                              'Grid View',
                              textAlign: TextAlign.center,
                            )
                          : const Text(
                              'List View',
                              textAlign: TextAlign.center,
                            ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: kJungleGreen.withOpacity(0.3),
                    ),
                  );
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
              child: Icon(
                Icons.more_vert,
                color: Colors.white, // Set the icon color here
              ),
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: shouldLogout
                            ? const Text(
                                'Logging Out',
                                textAlign: TextAlign.center,
                              )
                            : const Text(
                                'Cancelled',
                                textAlign: TextAlign.center,
                              ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: kJungleGreen.withOpacity(0.3),
                      ),
                    );
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
                  //Set firstName and lastName
                ];
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData && isGridView) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesGridView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onNoteTap: (CloudNote note) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                    notesService: _notesService,
                  );
                } else if (snapshot.hasData && !isGridView) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onNoteTap: (CloudNote note) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                    notesService: _notesService,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              default:
                return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
