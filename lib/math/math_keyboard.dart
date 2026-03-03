import 'package:flutter/material.dart';
import 'math_expression.dart';

class ProMathKeyboard extends StatefulWidget {
  final MathExpression expression;
  final VoidCallback onRefresh;

  const ProMathKeyboard({
    super.key,
    required this.expression,
    required this.onRefresh,
  });

  @override
  State<ProMathKeyboard> createState() => _ProMathKeyboardState();
}

class _ProMathKeyboardState extends State<ProMathKeyboard> {
  bool isMathMode = false;
  bool isUpperCase = false;
  bool isAdvancedMode = false;
  bool isGreekMode = false;

  // Android-style Colors
  static const Color keyBackground = Color(0xFFFFFFFF);
  static const Color specialKeyBg = Color(0xFFDFE1E5);
  static const Color accentColor = Color(0xFF4285F4);
  static const Color operatorColor = Color(0xFF5F6368);
  static const Color deleteColor = Color(0xFF5F6368);
  static const Color keyboardBg = Color(0xFFE8EAED);
  static const Color borderColor = Color(0xFFD1D3D8);
  static const Color shadowColor = Color(0x1A000000);

  void _insertText(String value) {
    widget.expression.insert(isUpperCase ? value.toUpperCase() : value);
    widget.onRefresh();
  }

  Widget _buildKey({
    required String label,
    VoidCallback? onTap,
    Color? bgColor,
    Color? textColor,
    double flex = 1,
    double fontSize = 20,
    IconData? icon,
    bool isAccent = false,
  }) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap();
              } else {
                _insertText(label);
              }
              widget.onRefresh();
            },
            borderRadius: BorderRadius.circular(8),
            splashColor: accentColor.withOpacity(0.2),
            highlightColor: accentColor.withOpacity(0.1),
            child: Ink(
              decoration: BoxDecoration(
                color: bgColor ?? keyBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Container(
                height: 46,
                alignment: Alignment.center,
                child: icon != null
                    ? Icon(
                        icon,
                        size: 22,
                        color: textColor ?? operatorColor,
                      )
                    : Text(
                        label,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                          color: textColor ?? Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextKeyboard() {
    List<List<String>> rows = [
      ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
      ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
      ["z", "x", "c", "v", "b", "n", "m"]
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: rows[0].map((key) {
              return _buildKey(
                label: isUpperCase ? key.toUpperCase() : key,
                fontSize: 18,
              );
            }).toList(),
          ),
        ),
        // Row 2 (centered)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: rows[1].map((key) {
              return _buildKey(
                label: isUpperCase ? key.toUpperCase() : key,
                fontSize: 18,
              );
            }).toList(),
          ),
        ),
        // Row 3 with shift and backspace
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "⇧",
                bgColor: isUpperCase ? accentColor : specialKeyBg,
                textColor: isUpperCase ? Colors.white : operatorColor,
                flex: 1.5,
                onTap: () => setState(() => isUpperCase = !isUpperCase),
              ),
              ...rows[2].map((key) {
                return _buildKey(
                  label: isUpperCase ? key.toUpperCase() : key,
                  fontSize: 18,
                );
              }),
              _buildKey(
                label: "⌫",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                flex: 1.5,
                onTap: () => widget.expression.backspace(),
              ),
            ],
          ),
        ),
        // Bottom row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "123",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                flex: 1.2,
                fontSize: 14,
                onTap: () => setState(() => isMathMode = true),
              ),
              _buildKey(
                label: ",",
                bgColor: specialKeyBg,
                flex: 0.8,
              ),
              _buildKey(
                label: " ",
                bgColor: keyBackground,
                flex: 4,
                onTap: () => _insertText(r"\ "),
              ),
              _buildKey(
                label: ".",
                bgColor: specialKeyBg,
                flex: 0.8,
              ),
              _buildKey(
                label: "←",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                flex: 1,
                onTap: () => widget.expression.moveLeft(),
              ),
              _buildKey(
                label: "→",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                flex: 1,
                onTap: () => widget.expression.moveRight(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMathKeyboard() {
    if (isGreekMode) {
      return _buildGreekKeyboard();
    }

    if (isAdvancedMode) {
      return _buildAdvancedMathKeyboard();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Special functions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "√",
                bgColor: specialKeyBg,
                fontSize: 22,
                onTap: () => widget.expression.insertSqrt(),
              ),
              _buildKey(
                label: "π",
                bgColor: specialKeyBg,
                fontSize: 20,
                onTap: () => widget.expression.insertPi(),
              ),
              _buildKey(
                label: "^",
                bgColor: specialKeyBg,
                fontSize: 18,
                onTap: () => widget.expression.insertPower(),
              ),
              _buildKey(
                label: "!",
                bgColor: specialKeyBg,
              ),
              _buildKey(
                label: "αβ",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 16,
                onTap: () => setState(() => isGreekMode = true),
              ),
            ],
          ),
        ),
        // Row 2: 7 8 9 ÷ ()
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(label: "7", fontSize: 22),
              _buildKey(label: "8", fontSize: 22),
              _buildKey(label: "9", fontSize: 22),
              _buildKey(
                label: "÷",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                fontSize: 22,
                onTap: () => widget.expression.insertDivision(),
              ),
              _buildKey(
                label: "()",
                bgColor: specialKeyBg,
                fontSize: 18,
                onTap: () => widget.expression.insertParenthesis(),
              ),
            ],
          ),
        ),
        // Row 3: 4 5 6 × frac
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(label: "4", fontSize: 22),
              _buildKey(label: "5", fontSize: 22),
              _buildKey(label: "6", fontSize: 22),
              _buildKey(
                label: "×",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                fontSize: 22,
                onTap: () => widget.expression.insertMultiplication(),
              ),
              _buildKey(
                label: "a/b",
                bgColor: accentColor,
                textColor: Colors.white,
                fontSize: 16,
                onTap: () => widget.expression.insertFraction(),
              ),
            ],
          ),
        ),
        // Row 4: 1 2 3 - %
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(label: "1", fontSize: 22),
              _buildKey(label: "2", fontSize: 22),
              _buildKey(label: "3", fontSize: 22),
              _buildKey(
                label: "−",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                fontSize: 22,
              ),
              _buildKey(
                label: "%",
                bgColor: specialKeyBg,
                fontSize: 20,
                onTap: () => widget.expression.insertPercent(),
              ),
            ],
          ),
        ),
        // Row 5: More 0 . + °
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "f(x)",
                bgColor: specialKeyBg,
                textColor: accentColor,
                fontSize: 14,
                onTap: () => setState(() => isAdvancedMode = true),
              ),
              _buildKey(label: "0", fontSize: 22),
              _buildKey(label: ".", fontSize: 22),
              _buildKey(
                label: "+",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                fontSize: 22,
              ),
              _buildKey(
                label: "°",
                bgColor: specialKeyBg,
                fontSize: 20,
                onTap: () => widget.expression.insertDegree(),
              ),
            ],
          ),
        ),
        // Row 6: ABC ← → = ⌫
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "ABC",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                fontSize: 14,
                onTap: () => setState(() => isMathMode = false),
              ),
              _buildKey(
                label: "←",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                onTap: () => widget.expression.moveLeft(),
              ),
              _buildKey(
                label: "→",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                onTap: () => widget.expression.moveRight(),
              ),
              _buildKey(
                label: "=",
                bgColor: accentColor,
                textColor: Colors.white,
                fontSize: 22,
              ),
              _buildKey(
                label: "⌫",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                onTap: () => widget.expression.backspace(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedMathKeyboard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: sin cos tan log ln
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "sin",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 14,
                onTap: () => widget.expression.insertSin(),
              ),
              _buildKey(
                label: "cos",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 14,
                onTap: () => widget.expression.insertCos(),
              ),
              _buildKey(
                label: "tan",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 14,
                onTap: () => widget.expression.insertTan(),
              ),
              _buildKey(
                label: "log",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 14,
                onTap: () => widget.expression.insertLog(),
              ),
              _buildKey(
                label: "ln",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 14,
                onTap: () => widget.expression.insertLn(),
              ),
            ],
          ),
        ),
        // Row 2: |x| Σ ∫ lim ∞
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "|x|",
                bgColor: specialKeyBg,
                fontSize: 16,
                onTap: () => widget.expression.insertAbs(),
              ),
              _buildKey(
                label: "Σ",
                bgColor: specialKeyBg,
                fontSize: 20,
                onTap: () => widget.expression.insertSum(),
              ),
              _buildKey(
                label: "∫",
                bgColor: specialKeyBg,
                fontSize: 22,
                onTap: () => widget.expression.insertIntegral(),
              ),
              _buildKey(
                label: "lim",
                bgColor: specialKeyBg,
                fontSize: 14,
                onTap: () => widget.expression.insertLimit(),
              ),
              _buildKey(
                label: "∞",
                bgColor: specialKeyBg,
                fontSize: 20,
                onTap: () => widget.expression.insertInfinity(),
              ),
            ],
          ),
        ),
        // Row 3: ^ _ e ≠ ±
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "xⁿ",
                bgColor: specialKeyBg,
                fontSize: 16,
                onTap: () => widget.expression.insertPower(),
              ),
              _buildKey(
                label: "xₙ",
                bgColor: specialKeyBg,
                fontSize: 16,
                onTap: () => widget.expression.insertSubscript(),
              ),
              _buildKey(
                label: "e",
                bgColor: specialKeyBg,
                fontSize: 18,
                onTap: () => widget.expression.insertE(),
              ),
              _buildKey(
                label: "≠",
                bgColor: specialKeyBg,
                fontSize: 20,
                onTap: () => widget.expression.insertNotEqual(),
              ),
              _buildKey(
                label: "±",
                bgColor: specialKeyBg,
                fontSize: 20,
                onTap: () => widget.expression.insertPlusMinus(),
              ),
            ],
          ),
        ),
        // Row 4: ≤ ≥ < > ()
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "≤",
                bgColor: specialKeyBg,
                fontSize: 20,
                onTap: () => widget.expression.insertLessEqual(),
              ),
              _buildKey(
                label: "≥",
                bgColor: specialKeyBg,
                fontSize: 20,
                onTap: () => widget.expression.insertGreaterEqual(),
              ),
              _buildKey(
                label: "<",
                bgColor: specialKeyBg,
                fontSize: 20,
              ),
              _buildKey(
                label: ">",
                bgColor: specialKeyBg,
                fontSize: 20,
              ),
              _buildKey(
                label: "()",
                bgColor: specialKeyBg,
                fontSize: 18,
                onTap: () => widget.expression.insertParenthesis(),
              ),
            ],
          ),
        ),
        // Row 5: Clear Back 123 ← →
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "C",
                bgColor: const Color(0xFFFFCDD2),
                textColor: Colors.red.shade700,
                fontSize: 16,
                onTap: () => widget.expression.clear(),
              ),
              _buildKey(
                label: "123",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                fontSize: 14,
                onTap: () => setState(() => isAdvancedMode = false),
              ),
              _buildKey(
                label: "ABC",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                fontSize: 14,
                onTap: () => setState(() {
                  isMathMode = false;
                  isAdvancedMode = false;
                }),
              ),
              _buildKey(
                label: "←",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                onTap: () => widget.expression.moveLeft(),
              ),
              _buildKey(
                label: "→",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                onTap: () => widget.expression.moveRight(),
              ),
              _buildKey(
                label: "⌫",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                onTap: () => widget.expression.backspace(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreekKeyboard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: α β γ δ ε
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "α",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => widget.expression.insertAlpha(),
              ),
              _buildKey(
                label: "β",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => widget.expression.insertBeta(),
              ),
              _buildKey(
                label: "γ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => widget.expression.insertGamma(),
              ),
              _buildKey(
                label: "δ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => widget.expression.insertDelta(),
              ),
              _buildKey(
                label: "ε",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\epsilon "),
              ),
            ],
          ),
        ),
        // Row 2: θ λ μ σ ω
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "θ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => widget.expression.insertTheta(),
              ),
              _buildKey(
                label: "λ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => widget.expression.insertLambda(),
              ),
              _buildKey(
                label: "μ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\mu "),
              ),
              _buildKey(
                label: "σ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => widget.expression.insertSigma(),
              ),
              _buildKey(
                label: "ω",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => widget.expression.insertOmega(),
              ),
            ],
          ),
        ),
        // Row 3: φ ψ ρ τ η
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "φ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\phi "),
              ),
              _buildKey(
                label: "ψ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\psi "),
              ),
              _buildKey(
                label: "ρ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\rho "),
              ),
              _buildKey(
                label: "τ",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\tau "),
              ),
              _buildKey(
                label: "η",
                bgColor: accentColor.withOpacity(0.1),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\eta "),
              ),
            ],
          ),
        ),
        // Row 4: Δ Σ Ω Π Φ
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "Δ",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\Delta "),
              ),
              _buildKey(
                label: "Σ",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\Sigma "),
              ),
              _buildKey(
                label: "Ω",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\Omega "),
              ),
              _buildKey(
                label: "Π",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\Pi "),
              ),
              _buildKey(
                label: "Φ",
                bgColor: accentColor.withOpacity(0.15),
                textColor: accentColor,
                fontSize: 22,
                onTap: () => _insertText(r"\Phi "),
              ),
            ],
          ),
        ),
        // Row 5: Back 123 ABC ← → ⌫
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildKey(
                label: "123",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                fontSize: 14,
                onTap: () => setState(() => isGreekMode = false),
              ),
              _buildKey(
                label: "ABC",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                fontSize: 14,
                onTap: () => setState(() {
                  isMathMode = false;
                  isGreekMode = false;
                }),
              ),
              _buildKey(
                label: "←",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                onTap: () => widget.expression.moveLeft(),
              ),
              _buildKey(
                label: "→",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                onTap: () => widget.expression.moveRight(),
              ),
              _buildKey(
                label: "⌫",
                bgColor: specialKeyBg,
                textColor: operatorColor,
                onTap: () => widget.expression.backspace(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: keyboardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 2,
            right: 2,
            top: 8,
            bottom: 4,
          ),
          child: isMathMode ? _buildMathKeyboard() : _buildTextKeyboard(),
        ),
      ),
    );
  }
}
