import 'package:flutter/material.dart';

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({super.key});

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String _output = "0";
  String _history = "";
  double num1 = 0;
  double num2 = 0;
  String operand = "";
  bool _resetOutput = false;

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _history = "";
        num1 = 0;
        num2 = 0;
        operand = "";
      } else if (buttonText == "⌫") {
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = "0";
        }
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        if (operand.isNotEmpty && !_resetOutput) {
          // chain operations
          buttonPressed("=");
        }
        num1 = double.parse(_output);
        operand = buttonText;
        _history = "${_formatNumber(num1)} $operand";
        _resetOutput = true;
      } else if (buttonText == ".") {
        if (_resetOutput) {
          _output = "0.";
          _resetOutput = false;
        } else if (!_output.contains(".")) {
          _output = _output + buttonText;
        }
      } else if (buttonText == "=") {
        if (operand.isEmpty) return;
        num2 = double.parse(_output);
        _history = "${_formatNumber(num1)} $operand ${_formatNumber(num2)} =";
        
        switch (operand) {
          case "+":
            _output = (num1 + num2).toString();
            break;
          case "-":
            _output = (num1 - num2).toString();
            break;
          case "×":
            _output = (num1 * num2).toString();
            break;
          case "÷":
            if (num2 == 0) {
              _output = "Error";
            } else {
              _output = (num1 / num2).toString();
            }
            break;
        }
        
        if (_output != "Error") {
          num1 = double.parse(_output);
          _output = _formatNumber(num1);
        }
        operand = "";
        _resetOutput = true;
      } else {
        // Numbers
        if (_output == "0" || _resetOutput) {
          _output = buttonText;
          _resetOutput = false;
        } else {
          _output = _output + buttonText;
        }
      }
    });
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  Widget buildButton(String buttonText, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () => buttonPressed(buttonText),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final operatorColor = theme.colorScheme.primaryContainer;
    final operatorTextColor = theme.colorScheme.onPrimaryContainer;
    final actionColor = theme.colorScheme.errorContainer;
    final actionTextColor = theme.colorScheme.onErrorContainer;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calculator', style: theme.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _history,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _output,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("C", color: actionColor, textColor: actionTextColor),
                        buildButton("⌫", color: actionColor, textColor: actionTextColor),
                        buildButton("%", color: operatorColor, textColor: operatorTextColor),
                        buildButton("÷", color: operatorColor, textColor: operatorTextColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("7"),
                        buildButton("8"),
                        buildButton("9"),
                        buildButton("×", color: operatorColor, textColor: operatorTextColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("4"),
                        buildButton("5"),
                        buildButton("6"),
                        buildButton("-", color: operatorColor, textColor: operatorTextColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("1"),
                        buildButton("2"),
                        buildButton("3"),
                        buildButton("+", color: operatorColor, textColor: operatorTextColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("0"),
                        buildButton("."),
                        buildButton("=", color: theme.colorScheme.primary, textColor: theme.colorScheme.onPrimary),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
