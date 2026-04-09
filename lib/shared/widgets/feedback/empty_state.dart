import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.verticalXl,
            Text(
              title,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSm,
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null || secondaryActionLabel != null) ...[
              AppSpacing.verticalXl,
              if (actionLabel != null)
                PrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  isExpanded: false,
                ),
              if (secondaryActionLabel != null) ...[
                AppSpacing.verticalMd,
                SecondaryButton(
                  label: secondaryActionLabel!,
                  onPressed: onSecondaryAction,
                  isExpanded: false,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Algo correu mal',
    this.message = 'Não foi possível carregar os dados. Tenta novamente.',
    this.actionLabel = 'Tentar novamente',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onRetry,
    );
  }
}

class NoConnectionState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'Sem ligação',
      message: 'Verifica a tua ligação à internet e tenta novamente.',
      actionLabel: 'Tentar novamente',
      onAction: onRetry,
    );
  }
}
