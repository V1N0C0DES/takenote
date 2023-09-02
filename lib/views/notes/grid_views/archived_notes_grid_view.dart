import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takenote/services/cloud/cloud_note.dart';
import 'package:takenote/services/cloud/firebase_cloud_storage.dart';
import 'package:takenote/widgets/animations/animated_scroll_view_item.dart';

import '../../../constants/k_constants.dart';
import '../../../utilities/color_pallette.dart';
import '../../../utilities/dialogs/delete_dialog.dart';
import '../../../utilities/note_colours.dart';

typedef NoteCallBack = void Function(CloudNote note);

class ArchivedNotesGridView extends StatefulWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onNoteTap;

  const ArchivedNotesGridView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onNoteTap,
    required FirebaseCloudStorage notesService,
  }) : super(key: key);

  @override
  State<ArchivedNotesGridView> createState() => _ArchivedNotesGridViewState();
}

class _ArchivedNotesGridViewState extends State<ArchivedNotesGridView> {
  late final FirebaseCloudStorage _notesService;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScrollViewItem(
      child:
          // if widget is empty display centered container with empty text and icon else display gridview
          widget.notes.isEmpty
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
                  child: GridView.custom(
                    gridDelegate: twoBytwo,
                    childrenDelegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final note = widget.notes.elementAt(index);

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
                            child: Card(
                              color: NoteColor.getColor(note.noteColor),
                              margin: const EdgeInsets.all(6),
                              elevation: 3,
                              child: Visibility(
                                visible: widget.notes.isNotEmpty,
                                // child card with note title and note content inkwell container
                                child: InkWell(
                                  // onlongpress show optionsheet
                                  onLongPress: () {
                                    widget.onNoteTap(note);
                                    showOptionsSheet(
                                      // show optionsheet
                                      context,
                                      note,
                                    );
                                  },
                                  onTap: () {
                                    widget.onNoteTap(note);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note.noteTitle,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: kRichBlackFogra,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // Divider
                                        const Divider(
                                          color: kRichBlackFogra,
                                          thickness: 1.3,
                                        ),
                                        const SizedBox(height: 10),
                                        Expanded(
                                          child: Text(
                                            note.noteText,
                                            style: const TextStyle(
                                              //scale factor to make text smaller
                                              fontSize: 15,
                                              height: 1.5,
                                            ),
                                            maxLines: 6,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                        // date and time of note creation in the bottom right corner  of the card
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // show date and time of note creation with border
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                note.noteDate.toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // child: ListTile(
                                //   //onlongpress to share
                                //   onLongPress: () {
                                //     _showOptionsSheet(context, note);
                                //   },
                                //   contentPadding: const EdgeInsets.symmetric(
                                //       horizontal: 16, vertical: 8),

                                //   title: Text(
                                //     note.noteTitle,
                                //     maxLines: 1,
                                //     softWrap: true,
                                //     overflow: TextOverflow.fade,
                                //   ),
                                //   subtitle: Text(
                                //     note.noteText,
                                //     maxLines: 10,
                                //     softWrap: true,
                                //     overflow: TextOverflow.fade,
                                //   ),
                                //   //date positioned bottom right

                                //   onTap: () {
                                //     widget.onNoteTap(note);
                                //   },
                                // ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: widget.notes.length,
                      addAutomaticKeepAlives: true,
                    ),
                  )),
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
                physics: NeverScrollableScrollPhysics(),
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
                        // Unarchive Note Function
                        _notesService.archiveNote(
                          documentId: note.documentId,
                          archived: 0,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Iconsax.archive_minus),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Unarchive'),
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

                        await Share.share('$title\n$text');
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
                        showDeleteDialog(context).then((result) {
                          if (result) {
                            widget.onDeleteNote.call(note);
                          }
                          //pop
                          Navigator.pop(context);
                        });
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
