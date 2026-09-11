import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;

void main() => runApp(const CalculatorApp());

abstract final class _Colors {
  static const background = Color(0xFF080E1C);
  static const panel = Color(0xFF111C30);
  static const line = Color(0xFF26354C);
  static const muted = Color(0xFFA5B4CC);
  static const white = Color(0xFFF2F6FF);
  static const mint = Color(0xFF76E6CD);
  static const violet = Color(0xFFC1ACFF);
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) => const CupertinoApp(
    title: 'Órbita · Calculadora',
    debugShowCheckedModeBanner: false,
    theme: CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: _Colors.mint,
      scaffoldBackgroundColor: _Colors.background,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          color: _Colors.white,
          fontFamily: 'sans-serif',
          fontSize: 15,
        ),
      ),
    ),
    home: _CalculatorHome(),
  );
}

class OpResult {
  final String name;
  final IconData icon;
  final double? value;
  final bool advanced;
  const OpResult(this.name, this.icon, this.value, {this.advanced = false});
}

class _CalculatorHome extends StatefulWidget {
  const _CalculatorHome();
  @override
  State<_CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<_CalculatorHome> {
  final _controllerA = TextEditingController();
  final _controllerB = TextEditingController();
  double? a;
  double? b;
  int _segment = 0;

  @override
  void initState() {
    super.initState();
    _controllerA.addListener(_onChanged);
    _controllerB.addListener(_onChanged);
  }

  void _onChanged() {
    final newA = _parseNumber(_controllerA.text);
    final newB = _parseNumber(_controllerB.text);
    if (newA != a || newB != b) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      a = newA;
      b = newB;
    });
  }

  double? _parseNumber(String text) {
    final value = double.tryParse(text.replaceAll(',', '.'));
    return value != null && value.isFinite ? value : null;
  }

  String _parity() {
    if (a! % 1 != 0 || b! % 1 != 0) {
      return 'La paridad solo aplica a números enteros';
    }
    final aEven = a! % 2 == 0;
    final bEven = b! % 2 == 0;
    if (aEven && bEven) return 'Ambos son pares';
    if (!aEven && !bEven) return 'Ambos son impares';
    return aEven ? 'A es par y B es impar' : 'A es impar y B es par';
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    super.dispose();
  }

  double? _nthRoot(double value, double n) {
    if (n == 0) return null;
    if (value < 0) {
      // Para radicandos negativos se admiten solo índices enteros impares.
      if (n % 1 != 0 || n % 2 == 0) return null;
      return -pow(-value, 1 / n).toDouble();
    }
    return pow(value, 1 / n).toDouble();
  }

  List<OpResult> _allResults() {
    if (a == null || b == null) return [];
    final av = a!, bv = b!;
    return [
      OpResult('Suma', CupertinoIcons.plus, av + bv),
      OpResult('Resta', CupertinoIcons.minus, av - bv),
      OpResult('Multiplicación', CupertinoIcons.multiply, av * bv),
      OpResult('División', CupertinoIcons.divide, bv != 0 ? av / bv : null),
      OpResult(
        'Cociente entero',
        CupertinoIcons.divide,
        bv != 0 && (av / bv).isFinite ? (av / bv).truncateToDouble() : null,
      ),
      OpResult(
        'Residuo',
        CupertinoIcons.percent,
        bv != 0 ? av.remainder(bv) : null,
      ),
      OpResult('Módulo', CupertinoIcons.percent, bv != 0 ? av % bv : null),
      OpResult(
        'Potenciación (aᵇ)',
        CupertinoIcons.arrow_up,
        pow(av, bv).toDouble(),
        advanced: true,
      ),
      OpResult(
        'Radicación (ᵇ√a)',
        CupertinoIcons.arrow_down,
        _nthRoot(av, bv),
        advanced: true,
      ),
      OpResult(
        'Logaritmación (log_b a)',
        CupertinoIcons.chart_bar,
        (av > 0 && bv > 0 && bv != 1) ? (log(av) / log(bv)) : null,
        advanced: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final hasValues = a != null && b != null;
    final results = _allResults()
        .where((r) => r.advanced == (_segment == 1))
        .toList();
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _SkyPainter())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _Colors.mint.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              CupertinoIcons.circle_grid_hex,
                              color: _Colors.mint,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'ÓRBITA',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          const Text(
                            'ESTUDIO / 01',
                            style: TextStyle(
                              color: _Colors.muted,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        'OBSERVATORIO MATEMÁTICO',
                        style: TextStyle(
                          color: _Colors.mint,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Dos números.\nUn universo de posibilidades.',
                        style: TextStyle(
                          fontSize: 34,
                          height: 1.12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Explora sus conexiones. Los resultados cambian contigo.',
                        style: TextStyle(color: _Colors.muted, height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final inputs = _Panel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Eyebrow(
                                  number: '01',
                                  title: 'Punto de partida',
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InputField(
                                        controller: _controllerA,
                                        label: 'NÚMERO A',
                                        accent: _Colors.mint,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _InputField(
                                        controller: _controllerB,
                                        label: 'NÚMERO B',
                                        accent: _Colors.violet,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Admite negativos y decimales con punto o coma.',
                                  style: TextStyle(
                                    color: _Colors.muted,
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _Colors.mint.withValues(alpha: .06),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _Colors.mint.withValues(
                                        alpha: .18,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.circle_lefthalf_fill,
                                            size: 14,
                                            color: _Colors.mint,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'PARIDAD',
                                            style: TextStyle(
                                              color: _Colors.mint,
                                              fontSize: 10,
                                              letterSpacing: 1.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        hasValues ? _parity() : 'Cada número tiene su propia naturaleza.',
                                        key: hasValues
                                            ? const ValueKey('parity')
                                            : null,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  onPressed: () {
                                    _controllerA.clear();
                                    _controllerB.clear();
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.arrow_counterclockwise,
                                        size: 14,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Empezar de nuevo',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                          final output = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _Eyebrow(
                                number: '02',
                                title: 'Explora los resultados',
                              ),
                              const SizedBox(height: 18),
                              CupertinoSlidingSegmentedControl<int>(
                                groupValue: _segment,
                                backgroundColor: _Colors.panel,
                                thumbColor: const Color(0xFF344665),
                                children: const {
                                  0: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Básicas',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  1: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Avanzadas',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                },
                                onValueChanged: (value) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _segment = value ?? 0);
                                },
                              ),
                              const SizedBox(height: 18),
                              AnimatedSwitcher(
                                duration: Duration(
                                  milliseconds: reducedMotion ? 0 : 220,
                                ),
                                child: hasValues
                                    ? LayoutBuilder(
                                        key: ValueKey(_segment),
                                        builder: (context, box) {
                                          final columns = box.maxWidth >= 540
                                              ? 2
                                              : 1;
                                          final width =
                                              (box.maxWidth -
                                                  (columns - 1) * 12) /
                                              columns;
                                          return Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children: [
                                              for (final op in results)
                                                SizedBox(
                                                  width: width,
                                                  child: _ResultCard(op: op),
                                                ),
                                            ],
                                          );
                                        },
                                      )
                                    : const _EmptyResults(
                                        key: ValueKey('placeholder'),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                hasValues
                                    ? '— indica un resultado no definido o fuera del rango numérico.'
                                    : 'Tu próxima idea empieza con A y B.',
                                style: const TextStyle(
                                  color: _Colors.muted,
                                  fontSize: 11,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          );
                          if (constraints.maxWidth >= 900) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 350, child: inputs),
                                const SizedBox(width: 32),
                                Expanded(child: output),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              inputs,
                              const SizedBox(height: 28),
                              output,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      Container(height: 1, color: _Colors.line),
                      const SizedBox(height: 18),
                      const Text(
                        'ÓRBITA     /     La belleza de encontrar la respuesta.',
                        style: TextStyle(
                          color: _Colors.muted,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF16243A), Color(0xFF101A2C)],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _Colors.line),
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: .15),
          blurRadius: 30,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: child,
  );
}

class _Eyebrow extends StatelessWidget {
  final String number;
  final String title;
  const _Eyebrow({required this.number, required this.title});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        number,
        style: const TextStyle(
          color: _Colors.mint,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color accent;
  const _InputField({
    required this.controller,
    required this.label,
    required this.accent,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 10),
      CupertinoTextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        textAlign: TextAlign.center,
        placeholder: '0',
        cursorColor: accent,
        style: TextStyle(
          fontSize: 32,
          color: accent,
          fontWeight: FontWeight.w500,
        ),
        placeholderStyle: const TextStyle(fontSize: 32, color: _Colors.muted),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
        decoration: BoxDecoration(
          color: _Colors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: .35)),
        ),
      ),
    ],
  );
}

class _ResultCard extends StatelessWidget {
  final OpResult op;
  const _ResultCard({required this.op});
  String _format(double? value) {
    if (value == null || !value.isFinite) return '—';
    if (value == 0) return '0';
    if (value.abs() >= 1e12 || value.abs() < 1e-6) {
      return value.toStringAsExponential(4);
    }
    return value.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final accent = op.advanced ? _Colors.violet : _Colors.mint;
    return Container(
      key: ValueKey('result-${op.name}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _Colors.panel.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Colors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(op.icon, size: 18, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  op.name,
                  style: const TextStyle(
                    color: _Colors.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: Duration(
                    milliseconds: MediaQuery.of(context).disableAnimations
                        ? 0
                        : 180,
                  ),
                  child: SizedBox(
                    key: ValueKey(_format(op.value)),
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _format(op.value),
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w500,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 24),
    decoration: BoxDecoration(
      border: Border.all(color: _Colors.line),
      borderRadius: BorderRadius.circular(24),
      color: _Colors.panel.withValues(alpha: .45),
    ),
    child: const Column(
      children: [
        SizedBox(
          width: 150,
          height: 100,
          child: CustomPaint(painter: _OrbitPainter()),
        ),
        SizedBox(height: 24),
        Text(
          'Todo está por descubrir',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        Text(
          'Ingresa ambos números\npara ver los resultados',
          textAlign: TextAlign.center,
          style: TextStyle(color: _Colors.muted, height: 1.6, fontSize: 14),
        ),
      ],
    ),
  );
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final angle in [-.5, .5]) {
      canvas.save();
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 140, height: 62),
        paint..color = _Colors.violet.withValues(alpha: .55),
      );
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, 9, Paint()..color = _Colors.mint);
    canvas.drawCircle(
      const Offset(57, -30),
      4,
      Paint()..color = _Colors.violet,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}

class _SkyPainter extends CustomPainter {
  const _SkyPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [Color(0xFF192746), _Colors.background],
        ).createShader(bounds),
    );
    final paint = Paint()..color = _Colors.muted.withValues(alpha: .12);
    for (double x = 24; x < size.width; x += 40) {
      for (double y = 24; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), .7, paint);
      }
    }
    canvas.drawCircle(
      Offset(size.width - 40, 100),
      220,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = _Colors.violet.withValues(alpha: .06),
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) => false;
}
