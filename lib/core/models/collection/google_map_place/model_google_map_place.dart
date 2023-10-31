
class ModelGoogleMapPlace {
  ModelGoogleMapPlace({
    this.predictions,
    this.status,
  });

  List<Prediction>? predictions;
  String? status;

  factory ModelGoogleMapPlace.fromJson(Map<String, dynamic> json) => ModelGoogleMapPlace(
        predictions: List<Prediction>.from(json["predictions"].map((x) => Prediction.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "predictions": List<dynamic>.from(predictions?.map((x) => x.toJson()) ?? []),
        "status": status,
      };
}

class Prediction {
  Prediction({
    this.description,
    this.matchedSubstrings,
    this.placeId,
    this.reference,
    this.structuredFormatting,
    this.terms,
    this.types,
  });

  String? description;
  List<MatchedSubstring>? matchedSubstrings;
  String? placeId;
  String? reference;
  StructuredFormatting? structuredFormatting;
  List<Term>? terms;
  List<String>? types;

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        description: json["description"],
        matchedSubstrings: List<MatchedSubstring>.from(json["matched_substrings"].map((x) => MatchedSubstring.fromJson(x))),
        placeId: json["place_id"],
        reference: json["reference"],
        structuredFormatting: StructuredFormatting.fromJson(json["structured_formatting"]),
        terms: List<Term>.from(json["terms"].map((x) => Term.fromJson(x))),
        types: List<String>.from(json["types"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "matched_substrings": List<dynamic>.from(matchedSubstrings?.map((x) => x.toJson()) ?? []),
        "place_id": placeId,
        "reference": reference,
        "structured_formatting": structuredFormatting?.toJson(),
        "terms": List<dynamic>.from(terms?.map((x) => x.toJson()) ?? []),
        "types": List<dynamic>.from(types?.map((x) => x) ?? []),
      };
}

class MatchedSubstring {
  MatchedSubstring({
    this.length,
    this.offset,
  });

  int? length;
  int? offset;

  factory MatchedSubstring.fromJson(Map<String, dynamic> json) => MatchedSubstring(
        length: json["length"],
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "length": length,
        "offset": offset,
      };
}

class StructuredFormatting {
  StructuredFormatting({
    this.mainText,
    this.mainTextMatchedSubstrings,
    this.secondaryText,
  });

  String? mainText;
  List<MatchedSubstring>? mainTextMatchedSubstrings;
  String? secondaryText;

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) => StructuredFormatting(
        mainText: json["main_text"],
        mainTextMatchedSubstrings: List<MatchedSubstring>.from(json["main_text_matched_substrings"].map((x) => MatchedSubstring.fromJson(x))),
        secondaryText: json["secondary_text"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "main_text": mainText,
        "main_text_matched_substrings": List<dynamic>.from(mainTextMatchedSubstrings?.map((x) => x.toJson()) ?? []),
        "secondary_text": secondaryText,
      };
}

class Term {
  Term({
    this.offset,
    this.value,
  });

  int? offset;
  String? value;

  factory Term.fromJson(Map<String, dynamic> json) => Term(
        offset: json["offset"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "offset": offset,
        "value": value,
      };
}

class LocationResponse{
  List<MapResults>? results;
  LocationResponse({this.results});

  factory LocationResponse.fromJson(Map<String, dynamic> json) => LocationResponse(
    results: List<MapResults>.from(json["results"].map((x) => MapResults.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results?.map((x) => x.toJson()) ?? []),
  };
}

class MapResults{
  List<AddressComponent>? addressComponents;
  String? formattedAddress;

  MapResults({this.addressComponents, this.formattedAddress});

  factory MapResults.fromJson(Map<String, dynamic> json) => MapResults(
    addressComponents: List<AddressComponent>.from(json["address_components"].map((x) => AddressComponent.fromJson(x))),
    formattedAddress: json['formatted_address']
  );

  Map<String, dynamic> toJson() => {
    "address_components": List<dynamic>.from(addressComponents?.map((x) => x.toJson()) ?? []),
    "formatted_address": formattedAddress
  };
}

class AddressComponent{
  String? longName;
  String? shortName;
  List<String>? types;

  AddressComponent({this.longName, this.shortName, this.types});

  factory AddressComponent.fromJson(Map<String, dynamic> json) => AddressComponent(
      longName: json["long_name"],
      shortName: json["short_name"],
      types: List<String>.from(json["types"].map((x) => x))
  );

  Map<String, dynamic> toJson() => {
    "address_components": List<dynamic>.from(types?.map((x) => x) ?? []),
    "long_name": longName,
    "short_name": shortName
  };
}
