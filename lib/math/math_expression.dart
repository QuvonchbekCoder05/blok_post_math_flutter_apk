class MathExpression {
  String _text = "";
  int _cursor = 0;

  String toLatex() => _text;
  bool get isEmpty => _text.isEmpty;

  String get displayLatex =>
      _text.substring(0, _cursor) + r"\cursor" + _text.substring(_cursor);

  void insert(String value) {
    _text = _text.substring(0, _cursor) + value + _text.substring(_cursor);
    _cursor += value.length;
  }

  void insertFraction() {
    insert(r"\frac{}{}");
    _cursor -= 3;
  }

  void insertSqrt() {
    insert(r"\sqrt{}");
    _cursor -= 1;
  }

  void insertIntegral() {
    insert(r"\int_{}^{}");
    _cursor -= 4;
  }

  void insertPower() {
    insert(r"^{}");
    _cursor -= 1;
  }

  void insertSubscript() {
    insert(r"_{}");
    _cursor -= 1;
  }

  void insertMultiplication() {
    insert(r"\cdot ");
  }

  void insertDivision() {
    insert(r"\div ");
  }

  void insertParenthesis() {
    insert("()");
    _cursor -= 1;
  }

  void insertPi() => insert(r"\pi ");
  void insertE() => insert("e ");
  void insertPercent() => insert(r"\% ");

  void insertAbs() {
    insert(r"\left| \right|");
    _cursor -= 8;
  }

  void insertSum() {
    insert(r"\sum_{}^{}");
    _cursor -= 4;
  }

  void insertLimit() {
    insert(r"\lim_{}");
    _cursor -= 1;
  }

  void insertLog() {
    insert(r"\log ");
  }

  void insertLn() {
    insert(r"\ln ");
  }

  void insertAlpha() {
    insert(r"\alpha ");
  }

  void insertBeta() {
    insert(r"\beta ");
  }

  void insertDegree() {
    insert(r"^{\circ}");
  }

  void insertGamma() {
    insert(r"\gamma ");
  }

  void insertDelta() {
    insert(r"\delta ");
  }

  void insertTheta() {
    insert(r"\theta ");
  }

  void insertLambda() {
    insert(r"\lambda ");
  }

  void insertSigma() {
    insert(r"\sigma ");
  }

  void insertOmega() {
    insert(r"\omega ");
  }

  void insertInfinity() {
    insert(r"\infty ");
  }

  void insertSin() {
    insert(r"\sin ");
  }

  void insertCos() {
    insert(r"\cos ");
  }

  void insertTan() {
    insert(r"\tan ");
  }

  void insertNotEqual() {
    insert(r"\neq ");
  }

  void insertLessEqual() {
    insert(r"\leq ");
  }

  void insertGreaterEqual() {
    insert(r"\geq ");
  }

  void insertPlusMinus() {
    insert(r"\pm ");
  }

  void moveLeft() {
    if (_cursor > 0) _cursor--;
  }

  void moveRight() {
    if (_cursor < _text.length) _cursor++;
  }

  void backspace() {
    if (_cursor == 0) return;
    _text = _text.substring(0, _cursor - 1) + _text.substring(_cursor);
    _cursor--;
  }

  void clear() {
    _text = "";
    _cursor = 0;
  }
}
