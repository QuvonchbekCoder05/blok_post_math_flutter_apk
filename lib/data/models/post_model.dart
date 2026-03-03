import 'package:hive/hive.dart';

part 'post_model.g.dart';

@HiveType(typeId: 1) // 0 FanModel, 1 PostModel, 2 TypeModel
class PostModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String type;

  @HiveField(3)
  late String fan;

  @HiveField(4)
  late List<String> blocks;

  @HiveField(5)
  late DateTime createdAt;
}
