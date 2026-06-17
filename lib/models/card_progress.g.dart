// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardProgressAdapter extends TypeAdapter<CardProgress> {
  @override
  final int typeId = 0;

  @override
  CardProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardProgress(
      cardId: fields[0] as String,
      streak: fields[1] as int,
      attemptsTotal: fields[2] as int,
      correctTotal: fields[3] as int,
      mastered: fields[4] as bool,
      lastSeenTimestamp: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CardProgress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.cardId)
      ..writeByte(1)
      ..write(obj.streak)
      ..writeByte(2)
      ..write(obj.attemptsTotal)
      ..writeByte(3)
      ..write(obj.correctTotal)
      ..writeByte(4)
      ..write(obj.mastered)
      ..writeByte(5)
      ..write(obj.lastSeenTimestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
