import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takenote/constants/k_constants.dart';
import 'package:takenote/services/cloud/cloud_note.dart';
import 'package:takenote/services/cloud/firebase_cloud_storage.dart';
import 'package:takenote/utilities/color_pallette.dart';
import 'package:takenote/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:takenote/utilities/dialogs/delete_dialog.dart';
import 'package:takenote/utilities/note_colours.dart';
import 'package:takenote/widgets/animations/animated_scroll_view_item.dart';


typedef NoteCallBack = void Function(CloudNote note);

class NotesListView extends StatefulWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onNoteTap;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onNoteTap,
    required FirebaseCloudStorage notesService,
  }) : super(key: key);

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  CloudNote? _note;

  late final FirebaseCloudStorage _notesService;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScrollViewItem(
      child: widget.notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Iconsax.note,
                    size: 100,
                    color: kJungleGreen,
                  ),
                  Text(
                    'No notes',
                    style: TextStyle(
                      fontSize: 20,
                      color: kJungleGreen,
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              bottom: false,
              child: ListView.builder(
                cacheExtent: 0,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                //refresh the list when the user scrolls to the top
                itemCount: widget.notes.length,
                itemBuilder: (context, index) {
                  final note = widget.notes.elementAt(index);
                  //wrap with dismissible to allow swipe to delete
                  return AnimatedScrollViewItem(
                    child: Dismissible(
                      key: Key(note.documentId),
                      onDismissed: (direction) {
                        _notesService.unarchiveNote(
                          documentId: note.documentId,
                          archived: 0,
                        );
                        _notesService.softDeleteNote(
                          documentId: note.documentId,
                          deleted: 1,
                        );
                      },
                      confirmDismiss: (direction) async {
                        final result = await showDeleteDialog(context);
                        return result;
                      },
                      //Red background when swiped with delete text
                      background: Container(
                        color: Colors.red,
                        child: const ListTile(
                          title: Text(
                            'Deleting...',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      child: Card(
                        color: NoteColor.getColor(note.noteColor),
                        elevation: 3,
                        child: ListTile(
                          // leading: CircleAvatar(
                          //   maxRadius: 14,
                          //   child: Text(
                          //     // note index + 1 to start at 1 instead of 0
                          //     '${index + 1}',
                          //   ),
                          // ),

                          //onlongpress to share
                          onLongPress: () {
                            showOptionsSheet(context, note);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(90),
                          ),
                          title: Text(
                            note.noteTitle,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            note.noteText,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                          //Trailing date if notedate is empty then show nothing
                          trailing: Text(
                            note.noteDate.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),

                          // trailing: IconButton(
                          //   onPressed: () async {
                          //     final shouldDelete =
                          //         await showDeleteDialog(context);
                          //     if (shouldDelete) {
                          //       widget.onDeleteNote(note);
                          //     }
                          //   },
                          //   icon: const Icon(Icons.delete, color: Colors.grey),
                          // ),
                          onTap: () {
                            widget.onNoteTap(note);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void showOptionsSheet(BuildContext context, CloudNote note) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        constraints: const BoxConstraints(),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Edit Note Function
                        widget.onNoteTap(note);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Iconsax.edit_2),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Archive Note Function
                        _notesService.archiveNote(
                          documentId: note.documentId,
                          archived: 1,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Iconsax.archive_add),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Archive'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //share note
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        // Share Note Function
                        final text = note.noteText;
                        final title = note.noteTitle;
                        if (_note == null || text.isEmpty || title.isEmpty) {
                          await showCannotShareEmptyNoteDialog(context);
                        } else {
                          Share.share('$title\n$text');
                        }
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Iconsax.share),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Share'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Delete Note Function

                        // soft delete
                        _notesService.softDeleteNote(
                          documentId: note.documentId,
                          deleted: 1,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Iconsax.note_remove),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // InkWell(
                    //   borderRadius: BorderRadius.circular(15),
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Row(
                    //       children: const <Widget>[
                    //         Padding(
                    //           padding: EdgeInsets.all(8.0),
                    //           child: Icon(Iconsax.close_circle),
                    //         ),
                    //         Padding(
                    //           padding: EdgeInsets.all(8.0),
                    //           child: Text('Cancel'),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      // onTap: () {
                      //   Navigator.pop(context);
                      //   _showColorPalette(context, _note);
                      // },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Iconsax.color_swatch),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Color Palette'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: false,
                          children: [
                            // For every color in pallette create a ColorPaletteButton
                            ColorPaletteButton(
                              color: NoteColor.getColor(0),
                              onTap: () {
                                _notesService.updateNoteColor(
                                  documentId: note.documentId,
                                  color: 0,
                                );
                                Navigator.pop(context);
                              },
                              isSelected: note.noteColor == 0,
                            ),
                            ColorPaletteButton(
                              color: NoteColor.getColor(1),
                              onTap: () {
                                _notesService.updateNoteColor(
                                  documentId: note.documentId,
                                  color: 1,
                                );
                                Navigator.pop(context);
                              },
                              isSelected: note.noteColor == 1,
                            ),
                            ColorPaletteButton(
                              color: NoteColor.getColor(2),
                              onTap: () {
                                _notesService.updateNoteColor(
                                  documentId: note.documentId,
                                  color: 2,
                                );
                                Navigator.pop(context);
                              },
                              isSelected: note.noteColor == 2,
                            ),
                            ColorPaletteButton(
                              color: NoteColor.getColor(3),
                              onTap: () {
                                _notesService.updateNoteColor(
                                  documentId: note.documentId,
                                  color: 3,
                                );
                                Navigator.pop(context);
                              },
                              isSelected: note.noteColor == 3,
                            ),
                            ColorPaletteButton(
                              color: NoteColor.getColor(4),
                              onTap: () {
                                _notesService.updateNoteColor(
                                  documentId: note.documentId,
                                  color: 4,
                                );
                                Navigator.pop(context);
                              },
                              isSelected: note.noteColor == 4,
                            ),
                            ColorPaletteButton(
                              color: NoteColor.getColor(5),
                              onTap: () {
                                _notesService.updateNoteColor(
                                  documentId: note.documentId,
                                  color: 5,
                                );
                                Navigator.pop(context);
                              },
                              isSelected: note.noteColor == 5,
                            ),
                            ColorPaletteButton(
                              color: NoteColor.getColor(6),
                              onTap: () {
                                _notesService.updateNoteColor(
                                  documentId: note.documentId,
                                  color: 6,
                                );
                                Navigator.pop(context);
                              },
                              isSelected: note.noteColor == 6,
                            ),
                            ColorPaletteButton(
                              color: NoteColor.getColor(7),
                              onTap: () {
                                _notesService.updateNoteColor(
                                  documentId: note.documentId,
                                  color: 7,
                                );
                                Navigator.pop(context);
                              },
                              isSelected: note.noteColor == 7,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
