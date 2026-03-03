import 'package:hive_flutter/hive_flutter.dart';
import 'models/post_model.dart';
import 'models/type_model.dart';
import 'models/fan_model.dart';

class HiveService {
  static const String postBoxName = 'postlar';
  static const String typeBoxName = 'turlar';
  static const String fanBoxName = 'fanlar';

  // Post saqlash
  static Future<void> savePost(PostModel post) async {
    final box = Hive.box<PostModel>(postBoxName);
    await box.add(post);
  }

  // Postlarni olish
  static List<PostModel> getPosts() {
    final box = Hive.box<PostModel>(postBoxName);
    final posts = box.values.toList();

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  // ✅ ENG TO‘G‘RI DELETE
  static Future<void> deletePost(PostModel post) async {
    await post.delete();
  }

  // Tur bo‘yicha filter
  static List<PostModel> related(String type) {
    final box = Hive.box<PostModel>(postBoxName);
    return box.values.where((post) => post.type == type).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> saveType(String name) async {
    final box = Hive.box<TypeModel>(typeBoxName);
    final exists = box.values.any((e) => e.name == name);
    if (!exists) {
      await box.add(TypeModel()..name = name);
    }
  }

  static Future<void> saveFan(String name) async {
    final box = Hive.box<FanModel>(fanBoxName);
    final exists = box.values.any((e) => e.name == name);
    if (!exists) {
      await box.add(FanModel()..name = name);
    }
  }

  static List<TypeModel> getTypes() =>
      Hive.box<TypeModel>(typeBoxName).values.toList();

  static List<FanModel> getFans() =>
      Hive.box<FanModel>(fanBoxName).values.toList();
}
