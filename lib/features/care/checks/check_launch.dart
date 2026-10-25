import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/models/care_check_result.dart';
import 'care_check_service.dart';
import 'check_flow_screen.dart';
import 'check_result_screen.dart';

Future<void> openCareCheck(BuildContext context, String checkType) async {
  CareCheckResult? latest;
  final token = await AuthService.getToken();
  if (token != null && token.isNotEmpty) {
    try {
      latest = await CareCheckService.fetchLatest(checkType);
    } catch (_) {
      latest = null;
    }
  }
  if (!context.mounted) return;

  if (latest != null) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CheckResultScreen(result: latest!)),
    );
    return;
  }

  final result = await Navigator.of(context).push<CareCheckResult>(
    MaterialPageRoute(
      builder: (_) => CheckFlowScreen(checkType: checkType),
    ),
  );
  if (result != null && context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CheckResultScreen(result: result)),
    );
  }
}
