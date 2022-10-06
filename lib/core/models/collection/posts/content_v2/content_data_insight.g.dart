// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_data_insight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentDataInsightAdapter extends TypeAdapter<ContentDataInsight> {
  @override
  final int typeId = 3;

  @override
  ContentDataInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContentDataInsight(
      shares: fields[0] as int?,
      insightLogs: (fields[9] as List?)?.cast<InsightLogs>(),
      follower: fields[1] as int?,
      comments: fields[2] as int?,
      following: fields[3] as int?,
      reactions: fields[4] as int?,
      views: fields[5] as int?,
      likes: fields[6] as int?,
    )
      ..isPostLiked = fields[7] as bool
      ..isView = fields[8] as bool;
  }

  @override
  void write(BinaryWriter writer, ContentDataInsight obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.shares)
      ..writeByte(1)
      ..write(obj.follower)
      ..writeByte(2)
      ..write(obj.comments)
      ..writeByte(3)
      ..write(obj.following)
      ..writeByte(4)
      ..write(obj.reactions)
      ..writeByte(5)
      ..write(obj.views)
      ..writeByte(6)
      ..write(obj.likes)
      ..writeByte(7)
      ..write(obj.isPostLiked)
      ..writeByte(8)
      ..write(obj.isView)
      ..writeByte(9)
      ..write(obj.insightLogs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentDataInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightLogsAdapter extends TypeAdapter<InsightLogs> {
  @override
  final int typeId = 5;

  @override
  InsightLogs read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InsightLogs(
      sId: fields[0] as String?,
      insightID: fields[1] as String?,
      active: fields[2] as bool?,
      createdAt: fields[3] as String?,
      updatedAt: fields[4] as String?,
      mate: fields[5] as String?,
      postID: fields[6] as String?,
      eventInsight: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InsightLogs obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.sId)
      ..writeByte(1)
      ..write(obj.insightID)
      ..writeByte(2)
      ..write(obj.active)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.mate)
      ..writeByte(6)
      ..write(obj.postID)
      ..writeByte(7)
      ..write(obj.eventInsight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightLogsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
