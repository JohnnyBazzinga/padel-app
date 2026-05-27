import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/notifications_provider.dart';
import '../../../shared/widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NotificationsProvider>().fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.screenPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notificações', style: AppTypography.h1),
                  if (provider.notifications.isNotEmpty)
                    TextButton(
                      onPressed: () => provider.markAllAsRead(),
                      child: Text(
                        'Marcar todas',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.fetchNotifications(),
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: provider.isLoading && provider.notifications.isEmpty
                    ? ListView(
                        padding: AppSpacing.screenPadding,
                        children: const [
                          SkeletonCard(height: 76),
                          AppSpacing.verticalMd,
                          SkeletonCard(height: 76),
                        ],
                      )
                    : provider.notifications.isEmpty
                        ? ListView(
                            padding: AppSpacing.screenPadding,
                            children: const [
                              EmptyState(
                                icon: Icons.notifications_none_rounded,
                                title: 'Sem notificações',
                                message:
                                    'Ainda não recebeste notificações. Quando alguém interagir contigo, aparece aqui.',
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: provider.notifications.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final notification = provider.notifications[index];
                              return _NotificationItem(
                                notification: notification,
                                onRead: () => provider.markAsRead(notification.id),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: (index * 20).ms)
                                  .slideY(begin: 0.05, end: 0);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onRead;

  const _NotificationItem({
    required this.notification,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return Container(
      decoration: BoxDecoration(
        color: unread ? AppColors.primaryMuted : AppColors.surface,
        borderRadius: AppDecorations.borderRadiusMd,
        border: Border.all(
          color: unread ? AppColors.primary.withValues(alpha: 0.18) : AppColors.glassBorder,
          width: unread ? 1.2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onRead,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceBright,
          child: Icon(_icon(notification.type), color: AppColors.primary),
        ),
        title: Text(
          notification.title,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalXs,
            Text(
              notification.message,
              style: AppTypography.bodySmall.copyWith(
                color: unread ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
            AppSpacing.verticalSm,
            Text(
              _timeLabel(notification.createdAt),
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        trailing: unread
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  IconData _icon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('match')) return Icons.sports_tennis_rounded;
    if (lower.contains('chat')) return Icons.chat_bubble_rounded;
    if (lower.contains('friend')) return Icons.people_rounded;
    return Icons.notifications_rounded;
  }

  String _timeLabel(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 1) return '${diff.inDays} dias';
    if (diff.inHours >= 1) return '${diff.inHours} horas';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} minutos';
    return 'agora';
  }
}

