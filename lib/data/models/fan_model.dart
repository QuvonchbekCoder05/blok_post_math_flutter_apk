import 'package:hive/hive.dart';

part 'fan_model.g.dart';

@HiveType(typeId: 0) // Har bir model uchun alohida typeId beriladi
class FanModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String name;
}
