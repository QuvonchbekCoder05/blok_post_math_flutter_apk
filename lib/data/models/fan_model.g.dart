// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FanModelAdapter extends TypeAdapter<FanModel> {
  @override
  final int typeId = 0;

  @override
  FanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FanModel()
      ..id = fields[0] as int?
      ..name = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, FanModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
