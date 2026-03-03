import 'package:hive/hive.dart';

part 'type_model.g.dart';

@HiveType(typeId: 2) // FanModel (0), PostModel (1), endi bunga (2) beramiz
class TypeModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String name;
}
