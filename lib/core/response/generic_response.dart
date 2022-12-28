class GenericResponse {
  dynamic responseData;
  int? responseCode;
  Messages? messages;

  GenericResponse({
    this.responseCode,
    this.responseData,
    this.messages,
  });

  GenericResponse.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    if(json['data'] != null){
      responseData = json['data'];
    }else if(json['arrdata'] != null){
      responseData = json['arrdata'];
    }
    messages = json['messages'] != null ? Messages.fromJson(json['messages']) : null;
  }
}

class Messages {
  List<String> nextFlow = [];
  List<String> info = [];

  Messages({this.nextFlow = const [], this.info = const []});

  Messages.fromJson(Map<String, dynamic> json) {
    nextFlow = json['nextFlow'] != null ? json['nextFlow'].cast<String>() : [];
    info = json['info'] != null ? json['info'].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nextFlow'] = nextFlow;
    data['info'] = info;
    return data;
  }
}
