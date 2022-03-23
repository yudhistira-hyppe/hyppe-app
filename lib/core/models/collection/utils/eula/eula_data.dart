import 'dart:convert';

class EulaData {
  String? eulaContent;
  String? eulaID;
  String? version;

  EulaData.fromJSON(Map<String, dynamic> body) {
    if (body['eulaContent'] != null && body['eulaContent'].isNotEmpty) {
      body['eulaContent'].forEach((v) {
        String _widget = json.encode(v);
        eulaContent = _widget;
      });
    }
    eulaID = body['eulaID'];
    version = body['version'];
  }
}
