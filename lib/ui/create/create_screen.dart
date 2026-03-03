import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/HiveService.dart';
import '../../data/models/post_model.dart';
import '../../data/models/type_model.dart';
import '../../data/models/fan_model.dart';
import '../../math/math_expression.dart';
import '../../math/math_keyboard.dart';

class CreateScreenForEdit extends StatefulWidget {
  final PostModel? post;

  const CreateScreenForEdit({super.key, this.post});

  @override
  State<CreateScreenForEdit> createState() => _CreateScreenForEditState();
}

class _CreateScreenForEditState extends State<CreateScreenForEdit> {
  final titleController = TextEditingController();
  final textController = TextEditingController();
  final typeController = TextEditingController();
  final fanController = TextEditingController();
  final MathExpression expression = MathExpression();
  final ScrollController _blocksScrollController = ScrollController();

  List<String> blocks = [];
  String selectedType = "";
  String selectedFan = "";
  bool expandedBlocksPreview = true;

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      titleController.text = widget.post!.title;
      selectedType = widget.post!.type;
      selectedFan = widget.post!.fan;
      blocks = List.from(widget.post!.blocks);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    typeController.dispose();
    fanController.dispose();
    _blocksScrollController.dispose();
    super.dispose();
  }

  void addTextBlock() {
    if (textController.text.trim().isEmpty) return;

    setState(() {
      blocks.add(textController.text.trim());
      textController.clear();
      _scrollToBottom();
    });
  }

  void addMathBlock() {
    final latex = expression.toLatex();
    if (latex.isEmpty) return;

    setState(() {
      blocks.add("MATH::$latex");
      expression.clear();
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_blocksScrollController.hasClients) {
        _blocksScrollController.animateTo(
          _blocksScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> createType() async {
    if (typeController.text.trim().isEmpty) return;

    await HiveService.saveType(typeController.text.trim());

    setState(() {
      selectedType = typeController.text.trim();
      typeController.clear();
    });
  }

  Future<void> createFan() async {
    if (fanController.text.trim().isEmpty) return;

    await HiveService.saveFan(fanController.text.trim());

    setState(() {
      selectedFan = fanController.text.trim();
      fanController.clear();
    });
  }

  // FIX: save() to'liq qayta yozildi
  Future<void> save() async {
    if (titleController.text.trim().isEmpty) return;

    try {
      if (widget.post != null) {
        // Mavjud postni yangilaymiz
        widget.post!.title = titleController.text.trim();
        widget.post!.type = selectedType;
        widget.post!.fan = selectedFan;
        // FIX: List.from() bilan yangi nusxa yaratamiz — Hive to'g'ri saqlasin
        widget.post!.blocks = List<String>.from(blocks);

        // FIX: post.save() — diskka yozilishini kafolatlaydigan yagona to'g'ri yo'l
        // Bu HiveService.savePost()'ga qaraganda ishonchliroq,
        // chunki mavjud HiveObject'ni uning original key'i bilan yangilaydi
        if (widget.post!.isInBox) {
          await widget.post!.save();
        } else {
          // Agar post qandaydur sabab boxdan tashqarida bo'lsa
          await HiveService.savePost(widget.post!);
        }
      } else {
        // Yangi post yaratamiz
        final post = PostModel()
          ..title = titleController.text.trim()
          ..type = selectedType
          ..fan = selectedFan
          ..blocks = List<String>.from(blocks)
          ..createdAt = DateTime.now();

        await HiveService.savePost(post);
      }
    } catch (e) {
      debugPrint("Saqlashda xatolik: $e");
    }

    // FIX: Navigator.pop try-catch dan TASHQARIDA — doim ishlaydi
    if (mounted) Navigator.pop(context, true);
  }

  Widget glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(28),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withAlpha(85),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget wrapMath(String latex) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        latex,
        mathStyle: MathStyle.display,
        textStyle: const TextStyle(fontSize: 22, color: Colors.black87),
      ),
    );
  }

  Widget buildBlockItem(String block, int index) {
    bool isMathBlock = block.startsWith("MATH::");
    final latex = isMathBlock ? block.replaceFirst("MATH::", "") : "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key("$index-${block.hashCode}"),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          setState(() {
            blocks.removeAt(index);
          });
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        child: glass(
          child: isMathBlock
              ? wrapMath(latex)
              : Text(
                  block,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildBlocksPreview() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              expandedBlocksPreview = !expandedBlocksPreview;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  expandedBlocksPreview ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black54,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "Blocks (${blocks.length})",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expandedBlocksPreview && blocks.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: blocks.length > 3 ? 300 : double.infinity,
            ),
            child: ListView.builder(
              controller: _blocksScrollController,
              shrinkWrap: true,
              physics: blocks.length > 3
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: blocks.length,
              itemBuilder: (context, index) =>
                  buildBlockItem(blocks[index], index),
            ),
          ),
        if (expandedBlocksPreview && blocks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "No blocks added yet",
              style: TextStyle(
                color: Colors.black38,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMathPreviewVisible = expression.toLatex().isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Image.asset(
            "assets/bg.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Header
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(38),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withAlpha(85),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black87, size: 24),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: glass(
                          child: TextField(
                            controller: titleController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Title",
                              hintStyle: TextStyle(
                                  color: Colors.black38, fontSize: 16),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// TYPE
                  ValueListenableBuilder(
                    valueListenable:
                        Hive.box<TypeModel>(HiveService.typeBoxName)
                            .listenable(),
                    builder: (context, Box<TypeModel> box, _) {
                      final types = box.values.toList();

                      return glass(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Type",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: selectedType.isEmpty ? null : selectedType,
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              hint: const Text("Select Type",
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 14,
                                  )),
                              items: types
                                  .map((e) => DropdownMenuItem(
                                        value: e.name,
                                        child: Text(e.name,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                            )),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedType = v ?? ""),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: typeController,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "New Type",
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Color(0xFF6366F1), size: 20),
                                    onPressed: createType,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  /// FAN
                  ValueListenableBuilder(
                    valueListenable:
                        Hive.box<FanModel>(HiveService.fanBoxName).listenable(),
                    builder: (context, Box<FanModel> box, _) {
                      final fans = box.values.toList();

                      return glass(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Subject",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: selectedFan.isEmpty ? null : selectedFan,
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              hint: const Text("Select Subject",
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 14,
                                  )),
                              items: fans
                                  .map((e) => DropdownMenuItem(
                                        value: e.name,
                                        child: Text(e.name,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                            )),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedFan = v ?? ""),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: fanController,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "New Subject",
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Color(0xFF6366F1), size: 20),
                                    onPressed: createFan,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  /// BLOCKS PREVIEW
                  buildBlocksPreview(),

                  const SizedBox(height: 16),

                  /// TEXT INPUT
                  glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add Text Block",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: textController,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Enter text...",
                                  hintStyle: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add,
                                    color: Color(0xFF6366F1), size: 20),
                                onPressed: addTextBlock,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// MATH INPUT
                  glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add Math Block",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (isMathPreviewVisible)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: wrapMath(expression.toLatex()),
                          ),
                        ProMathKeyboard(
                          expression: expression,
                          onRefresh: () => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add,
                                  color: Color(0xFF6366F1), size: 20),
                              onPressed: addMathBlock,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SAVE BUTTON
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withAlpha(85),
                            width: 1.2,
                          ),
                        ),
                        child: TextButton(
                          onPressed: save,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
