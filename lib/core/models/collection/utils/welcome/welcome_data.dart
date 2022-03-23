import 'package:hyppe/core/models/collection/utils/welcome/welcome_data_notes.dart';

class WelcomeData {
  List<WelcomeDataNotes> notesData = [];

  WelcomeData.fromJSON(Map<String, dynamic> json) {
    if (json["notesData"] != null) {
      json["notesData"].forEach((v) {
        notesData.add(WelcomeDataNotes.fromJSON(v));
      });
    }
  }
}
