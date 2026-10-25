import 'package:flutter/material.dart';

import 'check_flow_screen.dart';

class StressCheckScreen extends StatelessWidget {
  const StressCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CheckFlowScreen(checkType: 'stress');
  }
}

class AnxietyCheckScreen extends StatelessWidget {
  const AnxietyCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CheckFlowScreen(checkType: 'anxiety');
  }
}

class SleepQualityScreen extends StatelessWidget {
  const SleepQualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CheckFlowScreen(checkType: 'sleep');
  }
}
