import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takenote/services/cloud/cloud_note.dart';
import 'package:takenote/services/cloud/firebase_cloud_storage.dart';
import 'package:takenote/views/notes/animated_scroll_view_item.dart';

import '../../constants/k_constants.dart';
import '../../utilities/color_pallette.dart';
import '../../utilities/dialogs/cannot_share_empty_note_dialog.dart';
import '../../utilities/dialogs/delete_dialog.dart';
import '../../utilities/note_colours.dart';

typedef NoteCallBack = void Function(CloudNote note);

class ArchivedNotesGridView extends StatefulWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onNoteTap;
  final FirebaseCloudStorage _notesService;

  const ArchivedNotesGridView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onNoteTap,
    required FirebaseCloudStorage notesService,
  })  : _notesService = notesService,
        super(key: key);

  @override
  State<ArchivedNotesGridView> createState() => _ArchivedNotesGridViewState();
}

class _ArchivedNotesGridViewState extends State<ArchivedNotesGridView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    await _notesService.archiveNote(
      documentId: note.documentId,
      archived: 1,
    );

    await _notesService.updateNoteColor(
      documentId: note.documentId,
      color: note.noteColor,
    );
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
                    gridDelegate: SliverQuiltedGridDelegate(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      repeatPattern: QuiltedGridRepeatPattern.inverted,
                      pattern: [
                        const QuiltedGridTile(2, 1),
                        const QuiltedGridTile(1, 1),
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final note = widget.notes.elementAt(index);

                        return AnimatedScrollViewItem(
                          child: Dismissible(
                            key: Key(note.documentId),
                            onDismissed: (direction) {
                              widget.onDeleteNote(note);
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
                                child: ListTile(
                                  //onlongpress to share
                                  onLongPress: () {
                                    _showOptionsSheet(context, note);
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),

                                  title: Text(
                                    note.noteTitle,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                  ),
                                  subtitle: Text(
                                    note.noteText,
                                    maxLines: 10,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                  ),

                                  onTap: () {
                                    widget.onNoteTap(note);
                                  },
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

  void _showOptionsSheet(BuildContext context, CloudNote note) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        constraints: const BoxConstraints(),
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Container(
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
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const <Widget>[
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Iconsax.close_circle),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Cancel'),
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
