import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:share_plus/share_plus.dart';
import 'package:takenote/widgets/animations/fade_animation.dart';
import 'package:takenote/services/cloud/cloud_note.dart';
import 'package:takenote/services/cloud/firebase_cloud_storage.dart';
import 'package:takenote/widgets/animations/animated_scroll_view_item.dart';

import '../../../constants/k_constants.dart';
import '../../../utilities/color_pallette.dart';
import '../../../utilities/dialogs/cannot_share_empty_note_dialog.dart';
import '../../../utilities/note_colours.dart';

typedef NoteCallBack = void Function(CloudNote note);

class NotesGridView extends StatefulWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onNoteTap;

  const NotesGridView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onNoteTap,
    required FirebaseCloudStorage notesService,
  }) : super(key: key);

  @override
  State<NotesGridView> createState() => _NotesGridViewState();
}

class _NotesGridViewState extends State<NotesGridView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  bool isSelectionMode = false;

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
                        //if note is archived display it else don't
                        return AnimatedScrollViewItem(
                          child: FadeAnimation(
                            delay: 0.2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: NoteColor.getColor(note.noteColor),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: NoteColor.getColor(note.noteColor)
                                          .withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Visibility(
                                  visible: widget.notes.isNotEmpty,
                                  // child card with note title and note content inkwell container
                                  child: InkWell(
                                    // onlongpress show optionsheet
                                    onLongPress: () {
                                      _note = note;
                                      showOptionsSheet(context, note);
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
                                          //button to share more options
                                          // Divider
                                          const Divider(
                                            color: kRichBlackFogra,
                                            thickness: 1.3,
                                          ),
                                          Expanded(
                                            child: Text(
                                              note.noteText,
                                              style: const TextStyle(
                                                //scale factor to make text smaller
                                                fontSize: 15,
                                                height: 1.5,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                          // date and time of note creation in the bottom right corner  of the card

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              // show date and time of note creation with border
                                              Expanded(
                                                child: SizedBox(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      note.noteDate,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
              // var formattedDate =
              //     DateFormat.yMMMd().format(note.noteDateCreated.toDate());
              // var time = DateFormat.jm().format(noteData.creationDate.toDate());
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
                    // InkWell(
                    //   borderRadius: BorderRadius.circular(15),
                    //   onTap: () {
                    //     // Archive Note Function
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(
                    //         content: Text('UPDATED date type'),
                    //       ),
                    //     );
                    //     _notesService.updateNoteDate();
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Row(
                    //       children: const <Widget>[
                    //         Padding(
                    //           padding: EdgeInsets.all(8.0),
                    //           child: Icon(Icons.update),
                    //         ),
                    //         Padding(
                    //           padding: EdgeInsets.all(8.0),
                    //           child: Text('Update field'),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

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
