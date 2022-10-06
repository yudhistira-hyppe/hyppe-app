// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllContentsAdapter extends TypeAdapter<AllContents> {
  @override
  final int typeId = 0;

  @override
  AllContents read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AllContents(
      story: (fields[0] as List?)?.cast<ContentData>(),
      video: (fields[1] as List?)?.cast<ContentData>(),
      diary: (fields[2] as List?)?.cast<ContentData>(),
      pict: (fields[3] as List?)?.cast<ContentData>(),
    );
  }

  @override
  void write(BinaryWriter writer, AllContents obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.story)
      ..writeByte(1)
      ..write(obj.video)
      ..writeByte(2)
      ..write(obj.diary)
      ..writeByte(3)
      ..write(obj.pict);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllContentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContentDataAdapter extends TypeAdapter<ContentData> {
  @override
  final int typeId = 1;

  @override
  ContentData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContentData(
      metadata: fields[0] as Metadata?,
      mediaBasePath: fields[1] as String?,
      postType: fields[2] as String?,
      mediaUri: fields[3] as String?,
      isLiked: fields[4] as bool?,
      description: fields[5] as String?,
      active: fields[6] as bool?,
      privacy: fields[7] as Privacy?,
      mediaType: fields[8] as String?,
      mediaThumbEndPoint: fields[9] as String?,
      postID: fields[10] as String?,
      title: fields[11] as String?,
      isViewed: fields[12] as bool?,
      tags: (fields[13] as List?)?.cast<String>(),
      allowComments: fields[14] as bool?,
      certified: fields[15] as bool?,
      createdAt: fields[16] as String?,
      insight: fields[17] as ContentDataInsight?,
      mediaThumbUri: fields[18] as String?,
      mediaEndpoint: fields[19] as String?,
      email: fields[20] as String?,
      updatedAt: fields[21] as String?,
      username: fields[22] as String?,
      fullThumbPath: fields[23] as String?,
      fullContentPath: fields[24] as String?,
      avatar: fields[25] as UserProfileAvatarModel?,
      location: fields[27] as String?,
      visibility: fields[26] as String?,
      cats: (fields[28] as List?)?.cast<Cats>(),
      tagPeople: (fields[29] as List?)?.cast<TagPeople>(),
      likes: fields[30] as int?,
      saleAmount: fields[31] as num?,
      saleView: fields[32] as bool?,
      saleLike: fields[33] as bool?,
      isApsara: fields[34] as bool?,
      apsaraId: fields[35] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ContentData obj) {
    writer
      ..writeByte(36)
      ..writeByte(0)
      ..write(obj.metadata)
      ..writeByte(1)
      ..write(obj.mediaBasePath)
      ..writeByte(2)
      ..write(obj.postType)
      ..writeByte(3)
      ..write(obj.mediaUri)
      ..writeByte(4)
      ..write(obj.isLiked)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.active)
      ..writeByte(7)
      ..write(obj.privacy)
      ..writeByte(8)
      ..write(obj.mediaType)
      ..writeByte(9)
      ..write(obj.mediaThumbEndPoint)
      ..writeByte(10)
      ..write(obj.postID)
      ..writeByte(11)
      ..write(obj.title)
      ..writeByte(12)
      ..write(obj.isViewed)
      ..writeByte(13)
      ..write(obj.tags)
      ..writeByte(14)
      ..write(obj.allowComments)
      ..writeByte(15)
      ..write(obj.certified)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.insight)
      ..writeByte(18)
      ..write(obj.mediaThumbUri)
      ..writeByte(19)
      ..write(obj.mediaEndpoint)
      ..writeByte(20)
      ..write(obj.email)
      ..writeByte(21)
      ..write(obj.updatedAt)
      ..writeByte(22)
      ..write(obj.username)
      ..writeByte(23)
      ..write(obj.fullThumbPath)
      ..writeByte(24)
      ..write(obj.fullContentPath)
      ..writeByte(25)
      ..write(obj.avatar)
      ..writeByte(26)
      ..write(obj.visibility)
      ..writeByte(27)
      ..write(obj.location)
      ..writeByte(28)
      ..write(obj.cats)
      ..writeByte(29)
      ..write(obj.tagPeople)
      ..writeByte(30)
      ..write(obj.likes)
      ..writeByte(31)
      ..write(obj.saleAmount)
      ..writeByte(32)
      ..write(obj.saleView)
      ..writeByte(33)
      ..write(obj.saleLike)
      ..writeByte(34)
      ..write(obj.isApsara)
      ..writeByte(35)
      ..write(obj.apsaraId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetadataAdapter extends TypeAdapter<Metadata> {
  @override
  final int typeId = 2;

  @override
  Metadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Metadata(
      duration: fields[0] as int?,
      postRoll: fields[1] as int?,
      preRoll: fields[2] as int?,
      midRoll: fields[3] as int?,
      postID: fields[4] as String?,
      email: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Metadata obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.duration)
      ..writeByte(1)
      ..write(obj.postRoll)
      ..writeByte(2)
      ..write(obj.preRoll)
      ..writeByte(3)
      ..write(obj.midRoll)
      ..writeByte(4)
      ..write(obj.postID)
      ..writeByte(5)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrivacyAdapter extends TypeAdapter<Privacy> {
  @override
  final int typeId = 4;

  @override
  Privacy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Privacy(
      isPrivate: fields[2] as bool?,
      isCelebrity: fields[1] as bool?,
      isPostPrivate: fields[0] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Privacy obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isPostPrivate)
      ..writeByte(1)
      ..write(obj.isCelebrity)
      ..writeByte(2)
      ..write(obj.isPrivate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CatsAdapter extends TypeAdapter<Cats> {
  @override
  final int typeId = 7;

  @override
  Cats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cats(
      id: fields[0] as String?,
      interestName: fields[1] as String?,
      langIso: fields[2] as String?,
      icon: fields[3] as String?,
      createdAt: fields[4] as String?,
      updatedAt: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Cats obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.interestName)
      ..writeByte(2)
      ..write(obj.langIso)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TagPeopleAdapter extends TypeAdapter<TagPeople> {
  @override
  final int typeId = 8;

  @override
  TagPeople read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TagPeople(
      email: fields[0] as String?,
      username: fields[1] as String?,
      status: fields[2] as String?,
      avatar: fields[3] as Avatar?,
    );
  }

  @override
  void write(BinaryWriter writer, TagPeople obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.avatar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagPeopleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AvatarAdapter extends TypeAdapter<Avatar> {
  @override
  final int typeId = 9;

  @override
  Avatar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Avatar(
      mediaBasePath: fields[0] as String?,
      mediaUri: fields[1] as String?,
      mediaType: fields[2] as String?,
      mediaEndpoint: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Avatar obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.mediaBasePath)
      ..writeByte(1)
      ..write(obj.mediaUri)
      ..writeByte(2)
      ..write(obj.mediaType)
      ..writeByte(3)
      ..write(obj.mediaEndpoint);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
