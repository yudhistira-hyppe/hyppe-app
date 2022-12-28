class TicketArgument{
  String? id;
  String? iduser;
  String? idUserTicket;
  String? type;
  String? status;
  String? body;
  String? category;
  int? page;
  int? limit;
  bool? descending;
  String? email;


  TicketArgument({
    this.id,
    this.iduser,
    this.idUserTicket,
    this.page,
    this.limit,
    this.descending,
    this.type,
    this.status,
    this.body,
    this.email,
  });

  TicketArgument.fromJson(Map<String, dynamic> map){
    id = map['id'];
    iduser = map['iduser'];
    type = map['type'];
    category = map['jenis'];
    page = map['page'];
    limit = map['limit'];
    descending = map['descending'];
    email = map['email'];
  }

  Map<String, dynamic> toJson(){
    final result = <String, dynamic>{};
    if(id != null){
      result['id'] = id;
    }
    if(iduser != null){
      result['iduser'] = iduser;
    }
    if(type != null){
      result['type'] = type;
    }
    if(category != null){
      result['jenis'] = category;
    }
    if(page != null){
      result['page'] = page;
    }
    if(limit != null){
      result['limit'] = limit;
    }
    if(descending != null){
      result['descending'] = descending;
    }
    if(email != null){
      result['email'] = email;
    }
    if(status != null){
      result['status'] = status;
    }
    if(body != null){
      result['body'] = body;
    }
    if(idUserTicket != null){
      result['IdUserticket'] = idUserTicket;
    }

    return result;
  }
}