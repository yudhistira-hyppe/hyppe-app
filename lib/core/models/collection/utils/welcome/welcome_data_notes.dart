import 'dart:convert';

class WelcomeDataNotes {
  dynamic page;
  String? note;

  WelcomeDataNotes.fromJSON(Map<String, dynamic> body) {
    page = body["page"];
    note = jsonEncode(body["note"]);
  }
}