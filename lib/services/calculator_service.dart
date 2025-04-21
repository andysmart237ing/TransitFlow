import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

/// Service pour ouvrir le CalculatorDialog et mettre à jour un controller
class CalculatorService {
  /// Ouvre la calculatrice et, si l’utilisateur valide, écrit le résultat
  /// dans [controller].
  static Future<void> attachCalculator({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => CalculatorDialog(), // Votre dialog existant
    );
    if (result != null) {
      controller.text = result;
    }
  }

  /// Retourne un IconButton déjà câblé pour appeler [attachCalculator].
  static Widget calculatorSuffixIcon({
    required BuildContext context,
    required TextEditingController controller,
  }) {
    return IconButton(
      icon: Icon(Icons.calculate),
      onPressed: () => attachCalculator(
        context: context,
        controller: controller,
      ),
    );
  }
}

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({super.key});

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String _expression = '';

  void _appendValue(String value) {
    setState(() {
      _expression += value;
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
    });
  }

  void _evaluate() {
    try {
      ExpressionParser p = GrammarParser();
      Expression exp = p.parse(_expression.trim());
      double eval = exp.evaluate(EvaluationType.REAL, ContextModel());
      Navigator.of(context).pop(eval.toString());
    } catch (e) {
      Navigator.of(context).pop('Erreur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Calculatrice'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_expression, style: TextStyle(fontSize: 24)),
          SizedBox(height: 5),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var btn in [
                '7',
                '8',
                '9',
                '4',
                '5',
                '6',
                '1',
                '2',
                '3',
                '0',
                '.',
                ' / ',
                ' + ',
                ' - ',
                ' * ',
                '='
              ])
                ElevatedButton(
                  onPressed: () {
                    if (btn == '=') {
                      _evaluate();
                    } else {
                      _appendValue(btn);
                    }
                  },
                  child: Text(btn),
                ),
              ElevatedButton(onPressed: _clear, child: Text('C')),
            ],
          ),
        ],
      ),
    );
  }
}
