class LanguageData {
  String? langIso;
  String? lang;
  String? langID;

  LanguageData({this.langIso, this.lang, this.langID});

  LanguageData.fromJson(Map<String, dynamic> json) {
    langIso = json["langIso"];
    lang = json["lang"];
    langID = json["langID"];
  }
}
