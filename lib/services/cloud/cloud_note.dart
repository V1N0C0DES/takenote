// 3 Properties - Identifier, TextField , OwnerUserId
import 'package:cloud_firestore/cloud_firestore.dart';
//cloud_storage_storage_constants import
import 'package:takenote/services/cloud/cloud_storage_constants.dart';

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String noteText;
  final String noteDate;
  final String noteTitle;
  final int noteArchived;
  final int noteDeleted;
  final int noteColor;

  CloudNote(
    this.documentId,
    this.ownerUserId,
    this.noteText,
    this.noteDate,
    this.noteTitle,
    this.noteArchived,
    this.noteDeleted,
    this.noteColor,
  );

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        noteText = snapshot.data()[textFieldName] as String,
        // noteDate format is dd/mm/yyyy hh:mm
        noteDate = snapshot.data()[dateFieldName] as String,
        noteTitle = snapshot.data()[titleFieldName] as String,
        noteArchived = snapshot.data()[archivedFieldName] as int,
        noteDeleted = snapshot.data()[deletedFieldName] as int,
        noteColor = snapshot.data()[colorFieldName] as int;
}
