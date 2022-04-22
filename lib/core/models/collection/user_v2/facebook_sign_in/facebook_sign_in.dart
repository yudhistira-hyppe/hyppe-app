class FacebookSignIn {
  final String? id;
  final String? email;
  final String? name;
  final FacebookPicture? picture;

  const FacebookSignIn({this.id, this.email, this.name, this.picture});

  factory FacebookSignIn.fromJson(Map<String, dynamic> json) => FacebookSignIn(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        picture: FacebookPicture.fromJson(json['picture']['data']),
      );
}

class FacebookPicture {
  final String? url;
  final int? width;
  final int? height;

  const FacebookPicture({this.url, this.width, this.height});

  factory FacebookPicture.fromJson(Map<String, dynamic> json) =>
      FacebookPicture(
          url: json['url'], width: json['width'], height: json['height']);
}
