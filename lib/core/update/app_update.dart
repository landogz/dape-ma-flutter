import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/locale_scope.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_colors.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.available,
    required this.version,
    required this.build,
    required this.mandatory,
    required this.apkUrl,
    required this.message,
  });

  final bool available;
  final String version;
  final int build;
  final bool mandatory;
  final String apkUrl;
  final String message;

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      available: json['available'] == true,
      version: (json['version'] ?? '').toString(),
      build: json['build'] is int
          ? json['build'] as int
          : int.tryParse('${json['build'] ?? 0}') ?? 0,
      mandatory: json['mandatory'] == true,
      apkUrl: (json['apk_url'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  static bool isNewer({
    required String localVersion,
    required int localBuild,
    required String remoteVersion,
    required int remoteBuild,
  }) {
    if (remoteBuild > localBuild) {
      return true;
    }
    if (remoteBuild < localBuild) {
      return false;
    }
    return compareSemver(remoteVersion, localVersion) > 0;
  }

  static int compareSemver(String a, String b) {
    final pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < len; i++) {
      final av = i < pa.length ? pa[i] : 0;
      final bv = i < pb.length ? pb[i] : 0;
      if (av != bv) {
        return av.compareTo(bv);
      }
    }
    return 0;
  }
}

class AppUpdateChecker {
  AppUpdateChecker._();

  static bool _promptedThisLaunch = false;

  static Future<void> promptIfNeeded(BuildContext? context) async {
    if (kIsWeb || !Platform.isAndroid || _promptedThisLaunch) {
      return;
    }
    if (context == null || !context.mounted) {
      return;
    }

    try {
      final res = await ApiClient().get<Map<String, dynamic>>(
        Endpoints.appUpdate,
      );
      final root = res.data ?? <String, dynamic>{};
      final data = root['data'];
      if (data is! Map<String, dynamic>) {
        return;
      }

      final remote = AppUpdateInfo.fromJson(data);
      if (!remote.available || remote.apkUrl.isEmpty) {
        return;
      }

      final info = await PackageInfo.fromPlatform();
      final localBuild = int.tryParse(info.buildNumber) ?? 0;
      if (!AppUpdateInfo.isNewer(
        localVersion: info.version,
        localBuild: localBuild,
        remoteVersion: remote.version,
        remoteBuild: remote.build,
      )) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      _promptedThisLaunch = true;
      await _showDialog(context, remote);
    } catch (_) {}
  }

  static Future<void> _showDialog(
    BuildContext context,
    AppUpdateInfo remote,
  ) async {
    final l10n = context.l10n;

    await showDialog<void>(
      context: context,
      barrierDismissible: !remote.mandatory,
      builder: (ctx) {
        return Dialog(
          backgroundColor: ctx.cardBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: ctx.softBrandSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      size: 42,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.appUpdateTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ctx.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    remote.message.isNotEmpty
                        ? remote.message
                        : l10n.appUpdateBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ctx.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.versionLabel} ${remote.version} (${remote.build})',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ctx.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (!remote.mandatory)
                        SizedBox(
                          width: 140,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              foregroundColor: ctx.textSecondary,
                              side: BorderSide(color: ctx.borderSubtle),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(l10n.appUpdateLater),
                          ),
                        ),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          onPressed: () async {
                            final uri = Uri.tryParse(remote.apkUrl);
                            if (uri != null) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                            if (ctx.mounted && !remote.mandatory) {
                              Navigator.of(ctx).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.appUpdateNow),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
