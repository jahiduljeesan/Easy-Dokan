import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../settings/settings_provider.dart';
import 'auth_provider.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  String enteredPin = '';

  void _onDigitPress(String digit) {
    if (enteredPin.length < 4) {
      setState(() {
        enteredPin += digit;
      });
      if (enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePress() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    final settings = ref.read(settingsNotifierProvider);
    if (settings.pinCode == enteredPin) {
      ref.read(authStateProvider.notifier).state = true;
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
      setState(() {
        enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.lock, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Enter PIN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < enteredPin.length
                        ? primaryColor
                        : Colors.transparent,
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                );
              }),
            ),
            const Spacer(),
            _buildNumberPad(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var j = 1; j <= 3; j++) _buildKey((i * 3 + j).toString()),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80, height: 80), // Empty space
            _buildKey('0'),
            _buildKey('del', icon: Icons.backspace, onPressed: _onDeletePress),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String value, {IconData? icon, VoidCallback? onPressed}) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => _onDigitPress(value),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 32)
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
