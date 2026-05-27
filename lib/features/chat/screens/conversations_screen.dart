import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/theme.dart';
import '../../../shared/providers/chat_provider.dart';
import '../../../shared/widgets/widgets.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('pt', timeago.PtBrMessages());
    context.read<ChatProvider>().fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: AppSpacing.screenPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        variant: AppIconButtonVariant.ghost,
                        onPressed: () => Navigator.pop(context),
                      ),
                      AppSpacing.horizontalMd,
                      Text('Mensagens', style: AppTypography.h1),
                    ],
                  ),
                  AppIconButton(
                    icon: Icons.edit_square,
                    variant: AppIconButtonVariant.glass,
                    onPressed: () {
                      // TODO: New conversation
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.verticalLg,

            // Search
            Padding(
              padding: AppSpacing.screenPadding,
              child: SearchField(
                hint: 'Pesquisar conversas...',
                onChanged: (value) {
                  // TODO: Filter conversations
                },
              ),
            ),
            AppSpacing.verticalLg,

            // Conversations List
            Expanded(
              child: provider.isLoading
                  ? _buildLoadingState()
                  : provider.conversations.isEmpty
                      ? _buildEmptyState()
                      : _buildConversationsList(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: List.generate(
        5,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonListItem(showSubtitle: true),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Sem conversas',
      message: 'Ainda não tens conversas. Começa a conversar com outros jogadores!',
      actionLabel: 'Encontrar Jogadores',
      onAction: () => context.push('/friends'),
    );
  }

  Widget _buildConversationsList(ChatProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.fetchConversations(),
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: provider.conversations.length,
        itemBuilder: (context, index) {
          final conv = provider.conversations[index];
          return _ConversationTile(
            name: conv.otherUserName,
            avatarUrl: conv.otherUserAvatar,
            lastMessage: conv.lastMessage?['content'] ?? '',
            time: conv.lastMessageAt != null
                ? timeago.format(conv.lastMessageAt!, locale: 'pt')
                : '',
            unreadCount: conv.unreadCount ?? 0,
            isOnline: false, // TODO: Get online status
            onTap: () => context.push('/chat/${conv.id}'),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (index * 30).ms)
              .slideX(begin: 0.05, end: 0);
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.name,
    this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: hasUnread ? AppColors.primarySubtle : AppColors.surface,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(
          color: hasUnread ? AppColors.primary.withValues(alpha: 0.3) : AppColors.glassBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDecorations.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    UserAvatar(
                      imageUrl: avatarUrl,
                      name: name,
                      size: 52,
                    ),
                    if (isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                AppSpacing.horizontalMd,

                // Name & Last Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        lastMessage,
                        style: AppTypography.bodySmall.copyWith(
                          color: hasUnread
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpacing.horizontalMd,

                // Time & Unread Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: AppTypography.caption.copyWith(
                        color: hasUnread ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                    if (hasUnread) ...[
                      AppSpacing.verticalSm,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppDecorations.borderRadiusFull,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
