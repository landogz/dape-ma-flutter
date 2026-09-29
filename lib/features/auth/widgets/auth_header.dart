import 'package:flutter/material.dart';

import 'auth_scaffold.dart';

/// Legacy branding header — now matches [AuthBrandMark] (no stray tagline).
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthBrandMark(sealSize: 80);
  }
}
