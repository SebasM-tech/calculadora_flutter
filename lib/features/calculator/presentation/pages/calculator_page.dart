import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/operation_result.dart';
import '../../logic/calculator_controller.dart';
import '../../logic/calculator_state.dart';
import '../widgets/background_painters.dart';
import '../widgets/calculator_feedback.dart';
import '../widgets/calculator_panel.dart';
import '../widgets/number_input.dart';
import '../widgets/result_card.dart';
import '../widgets/section_header.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _controllerA = TextEditingController();
  final _controllerB = TextEditingController();
  final _calculator = CalculatorController();
  OperationCategory _category = OperationCategory.basic;

  @override
  void initState() {
    super.initState();
    _controllerA.addListener(_onInputChanged);
    _controllerB.addListener(_onInputChanged);
    _calculator.addListener(_refresh);
  }

  void _onInputChanged() {
    HapticFeedback.selectionClick();
    _calculator.calculate(_controllerA.text, _controllerB.text);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _clear() {
    _controllerA.clear();
    _controllerB.clear();
    _calculator.clear();
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    _calculator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _calculator.state;
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: SkyPainter())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 36),
                      const _Introduction(),
                      const SizedBox(height: 30),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final inputPanel = _buildInputPanel(state);
                          final resultsPanel = _buildResultsPanel(state);
                          if (constraints.maxWidth >=
                              AppConstants.desktopBreakpoint) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 350, child: inputPanel),
                                const SizedBox(width: 32),
                                Expanded(child: resultsPanel),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              inputPanel,
                              const SizedBox(height: 28),
                              resultsPanel,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      Container(height: 1, color: AppColors.line),
                      const SizedBox(height: 18),
                      const Text(
                        'ÓRBITA     /     La belleza de encontrar la respuesta.',
                        style: TextStyle(
                          color: AppColors.muted,
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

  Widget _buildInputPanel(CalculatorState state) => CalculatorPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(number: '01', title: 'Punto de partida'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: NumberInput(
                controller: _controllerA,
                label: 'NÚMERO A',
                accent: AppColors.mint,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: NumberInput(
                controller: _controllerB,
                label: 'NÚMERO B',
                accent: AppColors.violet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Admite negativos y decimales con punto o coma.',
          style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 22),
        _ParityCard(state: state),
        const SizedBox(height: 12),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 10),
          onPressed: _clear,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.arrow_counterclockwise, size: 14),
              SizedBox(width: 8),
              Text('Empezar de nuevo', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildResultsPanel(CalculatorState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionHeader(number: '02', title: 'Explora los resultados'),
      const SizedBox(height: 18),
      CupertinoSlidingSegmentedControl<OperationCategory>(
        groupValue: _category,
        backgroundColor: AppColors.panel,
        thumbColor: const Color(0xFF344665),
        children: const {
          OperationCategory.basic: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text('Básicas', style: TextStyle(fontSize: 13)),
          ),
          OperationCategory.advanced: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text('Avanzadas', style: TextStyle(fontSize: 13)),
          ),
        },
        onValueChanged: (value) {
          HapticFeedback.selectionClick();
          setState(() => _category = value ?? OperationCategory.basic);
        },
      ),
      const SizedBox(height: 18),
      AnimatedSwitcher(
        duration: Duration(
          milliseconds: MediaQuery.of(context).disableAnimations ? 0 : 220,
        ),
        child: _resultsContent(state),
      ),
      const SizedBox(height: 16),
      Text(
        state.hasValues
            ? '— indica un resultado no definido o fuera del rango numérico.'
            : 'Tu próxima idea empieza con A y B.',
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          height: 1.5,
        ),
      ),
    ],
  );

  Widget _resultsContent(CalculatorState state) {
    return switch (state.status) {
      CalculatorStatus.loading => const LoadingResults(
        key: ValueKey('loading'),
      ),
      CalculatorStatus.error => ErrorResults(
        key: const ValueKey('error'),
        message: state.errorMessage ?? 'Ocurrió un error inesperado.',
      ),
      CalculatorStatus.success => _ResultGrid(
        key: ValueKey(_category),
        results: _calculator.resultsFor(_category),
      ),
      CalculatorStatus.idle => const EmptyResults(key: ValueKey('placeholder')),
    };
  }
}

class _ParityCard extends StatelessWidget {
  final CalculatorState state;

  const _ParityCard({required this.state});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.mint.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.mint.withValues(alpha: .18)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              CupertinoIcons.circle_lefthalf_fill,
              size: 14,
              color: AppColors.mint,
            ),
            SizedBox(width: 8),
            Text(
              'PARIDAD',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 10,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          state.parity ?? 'Cada número tiene su propia naturaleza.',
          key: state.hasValues ? const ValueKey('parity') : null,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    ),
  );
}

class _ResultGrid extends StatelessWidget {
  final List<OperationResult> results;

  const _ResultGrid({super.key, required this.results});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= AppConstants.resultGridBreakpoint
          ? 2
          : 1;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final result in results)
            SizedBox(
              width: width,
              child: ResultCard(result: result),
            ),
        ],
      );
    },
  );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.mint.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          CupertinoIcons.circle_grid_hex,
          color: AppColors.mint,
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
          color: AppColors.muted,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    ],
  );
}

class _Introduction extends StatelessWidget {
  const _Introduction();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'OBSERVATORIO MATEMÁTICO',
        style: TextStyle(color: AppColors.mint, fontSize: 10, letterSpacing: 2),
      ),
      SizedBox(height: 10),
      Text(
        'Dos números.\nUn universo de posibilidades.',
        style: TextStyle(
          fontSize: 34,
          height: 1.12,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.2,
        ),
      ),
      SizedBox(height: 12),
      Text(
        'Explora sus conexiones. Los resultados cambian contigo.',
        style: TextStyle(color: AppColors.muted, height: 1.5),
      ),
    ],
  );
}
