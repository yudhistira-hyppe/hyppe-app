class KTPModel {
  String? cardPictNumber;
  int? persetaseCardNumber;
  bool? cardNumber;
  String? cardPictName;
  int? persetaseCardName;
  bool? cardName;
  bool? statusKYC;

  KTPModel({this.cardPictNumber, this.persetaseCardNumber, this.cardNumber, this.cardPictName, this.persetaseCardName, this.cardName, this.statusKYC});

  KTPModel.fromJson(Map<String, dynamic> json) {
    cardPictNumber = json['cardPictNumber'];
    persetaseCardNumber = json['persetaseCardNumber'];
    cardNumber = json['CardNumber'];
    cardPictName = json['cardPictName'];
    final percentage = json['persetaseCardName'];
    if(percentage is double){
      persetaseCardName = percentage.toInt();
    }else{
      persetaseCardName = percentage;
    }

    cardName = json['CardName'];
    statusKYC = json['StatusKYC'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cardPictNumber'] = cardPictNumber;
    data['persetaseCardNumber'] = persetaseCardNumber;
    data['CardNumber'] = cardNumber;
    data['cardPictName'] = cardPictName;
    data['persetaseCardName'] = persetaseCardName;
    data['CardName'] = cardName;
    data['StatusKYC'] = statusKYC;
    return data;
  }
}
