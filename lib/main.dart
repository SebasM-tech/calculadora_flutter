import 'dart:math';
import 'dart:ui' show FontFeature;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
 
void main() {
  runApp(const CalculatorApp());
}
 
/// Raíz de la app: escucha el brillo del sistema para alternar
/// automáticamente entre modo claro y oscuro, como cualquier app de Apple.
class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});
 
  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}
 
class _CalculatorAppState extends State<CalculatorApp> with WidgetsBindingObserver {
  late Brightness _brightness;
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }
 
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
 
  @override
  void didChangePlatformBrightness() {
    setState(() {
      _brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    final isDark = _brightness == Brightness.dark;
    final palette = _Palette(isDark);
 
    return CupertinoApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: _brightness,
        primaryColor: palette.accent,
        scaffoldBackgroundColor: palette.background,
        barBackgroundColor: palette.background,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: '.SF Pro Text',
            color: palette.textPrimary,
          ),
        ),
      ),
      home: CalculatorHome(palette: palette),
    );
  }
}
 
/// Paleta de colores centralizada para modo claro/oscuro (estilo iOS).
class _Palette {
  final bool isDark;
  const _Palette(this.isDark);
 
  Color get background => isDark ? CupertinoColors.black : const Color(0xFFF2F2F7);
  Color get card => isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white;
  Color get separator => isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);
  Color get segmentedBg => isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA);
  Color get segmentedThumb => isDark ? const Color(0xFF636366) : CupertinoColors.white;
  Color get textPrimary => isDark ? CupertinoColors.white : const Color(0xFF1C1C1E);
  Color get textSecondary => isDark ? const Color(0xFF98989D) : const Color(0xFF8E8E93);
  Color get accent => isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
}
 
/// Representa el resultado de una operación matemática entre A y B.
class OpResult {
  final String name;
  final IconData icon;
  final double? value;
  final bool advanced;
  const OpResult(this.name, this.icon, this.value, {this.advanced = false});
}
 
class CalculatorHome extends StatefulWidget {
  final _Palette palette;
  const CalculatorHome({super.key, required this.palette});
 
  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}
 
class _CalculatorHomeState extends State<CalculatorHome> {
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
    final newA = double.tryParse(_controllerA.text.replaceAll(',', '.'));
    final newB = double.tryParse(_controllerB.text.replaceAll(',', '.'));
    if (newA != a || newB != b) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      a = newA;
      b = newB;
    });
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
      if (n % 2 == 0) return null; // sin solución real
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
    final p = widget.palette;
    final results = _allResults();
    final basics = results.where((r) => !r.advanced).toList();
    final advanced = results.where((r) => r.advanced).toList();
    final hasValues = a != null && b != null;
 
    return CupertinoPageScaffold(
      backgroundColor: p.background,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Calculadora'),
            backgroundColor: p.background.withOpacity(0.9),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              controller: _controllerA,
                              label: 'NÚMERO A',
                              palette: p,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InputField(
                              controller: _controllerB,
                              label: 'NÚMERO B',
                              palette: p,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CupertinoSlidingSegmentedControl<int>(
                        groupValue: _segment,
                        backgroundColor: p.segmentedBg,
                        thumbColor: p.segmentedThumb,
                        children: {
                          0: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Básicas', style: TextStyle(color: p.textPrimary)),
                          ),
                          1: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Avanzadas', style: TextStyle(color: p.textPrimary)),
                          ),
                        },
                        onValueChanged: (v) {
                          HapticFeedback.selectionClick();
                          setState(() => _segment = v ?? 0);
                        },
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          ),
                        ),
                        child: !hasValues
                            ? Padding(
                                key: const ValueKey('placeholder'),
                                padding: const EdgeInsets.symmetric(vertical: 56),
                                child: Center(
                                  child: Text(
                                    'Ingresa ambos números\npara ver los resultados',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: p.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              )
                            : _ResultsGroup(
                                key: ValueKey(_segment),
                                header: _segment == 0 ? 'BÁSICAS' : 'AVANZADAS',
                                ops: _segment == 0 ? basics : advanced,
                                palette: p,
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
 
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final _Palette palette;
 
  const _InputField({
    required this.controller,
    required this.label,
    required this.palette,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        ),
        CupertinoTextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          textAlign: TextAlign.center,
          placeholder: '0',
          placeholderStyle: TextStyle(
            color: palette.textSecondary.withOpacity(0.5),
            fontSize: 22,
          ),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
    );
  }
}
 
/// Grupo de resultados estilo "lista agrupada" de iOS (Ajustes):
/// un encabezado y una sola tarjeta con separadores finos entre filas.
class _ResultsGroup extends StatelessWidget {
  final String header;
  final List<OpResult> ops;
  final _Palette palette;
 
  const _ResultsGroup({
    super.key,
    required this.header,
    required this.ops,
    required this.palette,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            header,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (int i = 0; i < ops.length; i++) ...[
                _ResultTile(op: ops[i], palette: palette),
                if (i != ops.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 58),
                    child: Container(height: 0.5, color: palette.separator),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
 
/// Una fila de resultado. Cuando el valor cambia, el número anima
/// suavemente de su valor anterior al nuevo en vez de saltar de golpe.
class _ResultTile extends StatefulWidget {
  final OpResult op;
  final _Palette palette;
  const _ResultTile({required this.op, required this.palette});
 
  @override
  State<_ResultTile> createState() => _ResultTileState();
}
 
class _ResultTileState extends State<_ResultTile> {
  double? _previousValue;
  bool _hasPrevious = false;
 
  @override
  void didUpdateWidget(covariant _ResultTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousValue = oldWidget.op.value;
    _hasPrevious = true;
  }
 
  String _format(double? value) {
    if (value == null || value.isNaN || value.isInfinite) return '—';
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toStringAsFixed(0);
    }
    String s = value.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }
 
  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final value = widget.op.value;
    final valid = value != null && !value.isNaN && !value.isInfinite;
    final prevValid =
        _hasPrevious && _previousValue != null && !_previousValue!.isNaN && !_previousValue!.isInfinite;
 
    final valueStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: p.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
 
    Widget valueWidget;
    if (valid && prevValid && _previousValue != value) {
      valueWidget = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: _previousValue, end: value),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => Text(_format(v), style: valueStyle),
      );
    } else {
      valueWidget = Text(_format(value), style: valueStyle);
    }
 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.op.icon, size: 15, color: p.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.op.name,
              style: TextStyle(
                fontSize: 15,
                color: p.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          valueWidget,
        ],
      ),
    );
  }
}
 
