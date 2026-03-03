import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/post_model.dart';
import '../../data/HiveService.dart';
import '../widgets/glass_card.dart';
import '../create/create_screen.dart';

class DetailScreen extends StatefulWidget {
  final PostModel post;

  const DetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _fadeAnimation;

  // FIX: widget.post o'rniga local mutable variable ishlatamiz
  late PostModel _post;

  List<PostModel> relatedPosts = [];

  @override
  void initState() {
    super.initState();

    // FIX: local _post ni initialize qilamiz
    _post = widget.post;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _blurAnimation = Tween<double>(begin: 0, end: 20).animate(_controller);
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    loadRelatedPosts();

    if (Hive.isBoxOpen(HiveService.postBoxName)) {
      Hive.box<PostModel>(HiveService.postBoxName).listenable().addListener(() {
        if (mounted) loadRelatedPosts();
      });
    }
  }

  void loadRelatedPosts() {
    final allPosts = HiveService.getPosts();
    // FIX: widget.post o'rniga _post ishlatamiz
    relatedPosts = allPosts.where((p) {
      return (p.type == _post.type || p.fan == _post.fan) && p.key != _post.key;
    }).toList();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> deletePost() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O\'chirishni tasdiqlang'),
        content: const Text('Haqiqatan ham o\'chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Yo\'q'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ha'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await HiveService.deletePost(_post);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        debugPrint("O'chirishda xatolik: $e");
      }
    }
  }

  Widget glassBox({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _blurAnimation.value,
          sigmaY: _blurAnimation.value,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Future<void> editPost() async {
    // FIX: result ni qabul qilamiz
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateScreenForEdit(post: _post),
      ),
    );

    // FIX: save muvaffaqiyatli bo'lsa, Hive'dan yangi ma'lumotni yuklaymiz
    if (result == true && mounted) {
      if (Hive.isBoxOpen(HiveService.postBoxName)) {
        final box = Hive.box<PostModel>(HiveService.postBoxName);
        final key = _post.key;
        if (key != null && box.containsKey(key)) {
          final freshPost = box.get(key);
          if (freshPost != null) {
            setState(() {
              _post = freshPost;
            });
            loadRelatedPosts();
            return;
          }
        }
      }
      setState(() {});
      loadRelatedPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final paddingHorizontal = isMobile ? 12.0 : 20.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Scaffold(
          body: Stack(
            children: [
              Image.asset(
                "assets/bg.jpg",
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal,
                      vertical: isMobile ? 8 : 12,
                    ),
                    child: ListView(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black),
                              iconSize: isMobile ? 24 : 28,
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.black),
                              iconSize: isMobile ? 24 : 28,
                              onPressed: deletePost,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              iconSize: isMobile ? 24 : 28,
                              onPressed: editPost,
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 12 : 20),
                        glassBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // FIX: _post ishlatamiz
                              Text(
                                _post.title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isMobile ? 20 : 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: isMobile ? 8 : 10),
                              Text(
                                "${_post.type} • ${_post.fan}",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),
                              SizedBox(height: isMobile ? 6 : 10),
                              Text(
                                "${_post.createdAt.day}.${_post.createdAt.month}.${_post.createdAt.year}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: isMobile ? 11 : 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        glassBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // FIX: _post.blocks ishlatamiz
                            children: _post.blocks.map((block) {
                              if (block.startsWith("MATH::")) {
                                final latex = block.replaceFirst("MATH::", "");
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 8 : 12,
                                  ),
                                  child: Math.tex(
                                    latex,
                                    textStyle: TextStyle(
                                      fontSize: isMobile ? 16 : 24,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 4 : 6,
                                  ),
                                  child: Text(
                                    block,
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 18,
                                      color: Colors.black,
                                      height: 1.5,
                                    ),
                                  ),
                                );
                              }
                            }).toList(),
                          ),
                        ),
                        if (relatedPosts.isNotEmpty) ...[
                          SizedBox(height: isMobile ? 20 : 30),
                          Text(
                            "O'xshash postlar",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isMobile ? 16 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isMobile ? 12 : 20),
                          ...relatedPosts.map((post) {
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(post: post),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 6 : 8,
                                ),
                                child: GlassCard(post: post),
                              ),
                            );
                          }).toList(),
                        ],
                        SizedBox(height: isMobile ? 20 : 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
