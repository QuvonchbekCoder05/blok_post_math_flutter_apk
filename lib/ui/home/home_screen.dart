import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/HiveService.dart';
import '../../data/models/post_model.dart';
import '../../data/models/type_model.dart';
import '../../data/models/fan_model.dart';
import '../create/create_screen.dart';
import '../detail/detail_screen.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<PostModel> posts = [];
  List<PostModel> filtered = [];

  String search = "";
  String selectedType = "";
  String selectedFan = "";

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    load();

    Hive.box<PostModel>(HiveService.postBoxName).listenable().addListener(() {
      load();
    });
    Hive.box<TypeModel>(HiveService.typeBoxName).listenable().addListener(() {
      setState(() {});
    });
    Hive.box<FanModel>(HiveService.fanBoxName).listenable().addListener(() {
      setState(() {});
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void load() {
    posts = HiveService.getPosts();
    applyFilter();
  }

  void applyFilter() {
    filtered = posts.where((p) {
      final matchSearch = p.title.toLowerCase().contains(search.toLowerCase());
      final matchType = selectedType.isEmpty || p.type == selectedType;
      final matchFan = selectedFan.isEmpty || p.fan == selectedFan;
      return matchSearch && matchType && matchFan;
    }).toList();

    setState(() {});
  }

  Widget buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Qidirish",
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) {
                    search = v;
                    applyFilter();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? Colors.amber.withOpacity(0.8)
              : Colors.white.withOpacity(0.15),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ================= TYPE SHEET =================

  void openTypeSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final types =
            Hive.box<TypeModel>(HiveService.typeBoxName).values.toList();
        final TextEditingController newTypeController = TextEditingController();

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Turi bo'yicha filtrlash",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                title: const Text(
                  "Barcha turlar",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                onTap: () {
                  selectedType = "";
                  applyFilter();
                  Navigator.pop(context);
                },
              ),
              ...types.map((e) => ListTile(
                    dense: true,
                    title: Text(e.name,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14)),
                    onTap: () {
                      selectedType = e.name;
                      applyFilter();
                      Navigator.pop(context);
                    },
                  )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newTypeController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Yangi tur",
                          hintStyle: const TextStyle(
                              color: Colors.black54, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        if (newTypeController.text.trim().isEmpty) return;
                        await HiveService.saveType(
                            newTypeController.text.trim());
                        selectedType = newTypeController.text.trim();
                        applyFilter();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.black, size: 20),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ================= FAN SHEET =================

  void openFanSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final fans = Hive.box<FanModel>(HiveService.fanBoxName).values.toList();
        final TextEditingController newFanController = TextEditingController();

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Fan bo'yicha filtrlash",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                title: const Text(
                  "Barcha fanlar",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                onTap: () {
                  selectedFan = "";
                  applyFilter();
                  Navigator.pop(context);
                },
              ),
              ...fans.map((e) => ListTile(
                    dense: true,
                    title: Text(e.name,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14)),
                    onTap: () {
                      selectedFan = e.name;
                      applyFilter();
                      Navigator.pop(context);
                    },
                  )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newFanController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Yangi fan",
                          hintStyle: const TextStyle(
                              color: Colors.black54, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        if (newFanController.text.trim().isEmpty) return;
                        await HiveService.saveFan(newFanController.text.trim());
                        selectedFan = newFanController.text.trim();
                        applyFilter();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.black, size: 20),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/bg.jpg",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          FadeTransition(
            opacity: _fade,
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 16 : 20),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 20,
                    ),
                    child: isMobile
                        ? Column(
                            children: [
                              buildSearchBar(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: buildFilterButton(
                                      "TURI",
                                      selectedType.isNotEmpty,
                                      openTypeSheet,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: buildFilterButton(
                                      "FAN",
                                      selectedFan.isNotEmpty,
                                      openFanSheet,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: buildSearchBar()),
                              const SizedBox(width: 10),
                              buildFilterButton(
                                "TURI",
                                selectedType.isNotEmpty,
                                openTypeSheet,
                              ),
                              const SizedBox(width: 8),
                              buildFilterButton(
                                "FAN",
                                selectedFan.isNotEmpty,
                                openFanSheet,
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: isMobile ? 20 : 30),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        left: isMobile ? 12 : 20,
                        right: isMobile ? 12 : 20,
                        bottom: 120,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final post = filtered[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(post: post),
                              ),
                            );
                            if (result == true) {
                              load();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(post: post),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: isMobile ? 30 : 40,
            right: isMobile ? 20 : 40,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateScreenForEdit(),
                  ),
                );
                load();
              },
              child: Container(
                height: isMobile ? 60 : 70,
                width: isMobile ? 60 : 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.amber.shade200, Colors.amber.shade700],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  Icons.add,
                  size: isMobile ? 28 : 35,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
