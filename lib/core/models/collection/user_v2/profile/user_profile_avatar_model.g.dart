// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_avatar_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAvatarModelAdapter
    extends TypeAdapter<UserProfileAvatarModel> {
  @override
  final int typeId = 6;

  @override
  UserProfileAvatarModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileAvatarModel(
      createdAt: fields[0] as String?,
      mediaBasePath: fields[1] as String?,
      mediaUri: fields[2] as String?,
      active: fields[3] as bool?,
      mediaType: fields[4] as String?,
      mediaEndpoint: fields[5] as String?,
      updatedAt: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileAvatarModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.mediaBasePath)
      ..writeByte(2)
      ..write(obj.mediaUri)
      ..writeByte(3)
      ..write(obj.active)
      ..writeByte(4)
      ..write(obj.mediaType)
      ..writeByte(5)
      ..write(obj.mediaEndpoint)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAvatarModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
