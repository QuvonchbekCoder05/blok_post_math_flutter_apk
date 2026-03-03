import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/HiveService.dart';
// Mana bu yerga o'z loyihangiz nomini qo'ying (pubspec.yaml dagi name: math_blog bo'lsa):
import 'package:math_blog/data/models/post_model.dart';
import 'package:math_blog/data/models/type_model.dart';
import 'package:math_blog/data/models/fan_model.dart';
import 'package:math_blog/data/HiveService.dart';
import 'package:math_blog/ui/home/home_screen.dart';

void main() async {
  // 1. Flutter bog'lamalarini tekshirish
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Hive-ni inicializatsiya qilish (IsarService.init o'rniga)
  await Hive.initFlutter();

  // 3. Adapterlarni ro'yxatdan o'tkazish (Bu juda muhim!)
  Hive.registerAdapter(FanModelAdapter());
  Hive.registerAdapter(PostModelAdapter());
  Hive.registerAdapter(TypeModelAdapter());

  // 4. Qutilarni (Box) ochish
  await Hive.openBox<FanModel>('fanlar');
  await Hive.openBox<PostModel>('postlar');
  await Hive.openBox<TypeModel>('turlar');

  runApp(const MathBlogApp());
}

class MathBlogApp extends StatelessWidget {
  const MathBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Math Blog',
      home: HomeScreen(),
    );
  }
}
