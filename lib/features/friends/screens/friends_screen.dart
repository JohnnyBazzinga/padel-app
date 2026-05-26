import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/friends_provider.dart';
import '../../../shared/widgets/widgets.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final provider = context.read<FriendsProvider>();
    provider.fetchFriends();
    provider.fetchPendingRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Amigos',
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            const Tab(text: 'Amigos'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pedidos'),
                  if (provider.pendingCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: AppDecorations.borderRadiusFull,
                      ),
                      child: Text(
                        '${provider.pendingCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.friends.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: AppColors.textMuted),
                          SizedBox(height: 16),
                          Text('Sem amigos ainda',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.friends.length,
                      itemBuilder: (context, index) {
                        final friend = provider.friends[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            backgroundImage: friend.avatarUrl != null
                                ? NetworkImage(friend.avatarUrl!)
                                : null,
                            child: friend.avatarUrl == null
                                ? Text(
                                    friend.name.isNotEmpty
                                        ? friend.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : null,
                          ),
                          title: Text(friend.name),
                          subtitle: Text(
                            '${friend.city} \u00b7 ${friend.skillLevel}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIconButton(
                                icon: Icons.chat_bubble_outline,
                                variant: AppIconButtonVariant.ghost,
                                onPressed: () {
                                  context.push('/chat');
                                },
                              ),
                              const SizedBox(width: 4),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Remover amigo'),
                                  ),
                                ],
                                onSelected: (value) async {
                                  if (value == 'remove') {
                                    await provider.removeFriend(friend.friendId);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          provider.pendingRequests.isEmpty
              ? const Center(
                  child: Text(
                    'Sem pedidos pendentes',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  itemCount: provider.pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = provider.pendingRequests[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        backgroundImage: request.avatarUrl != null
                            ? NetworkImage(request.avatarUrl!)
                            : null,
                        child: request.avatarUrl == null
                            ? Text(
                                request.name.isNotEmpty
                                    ? request.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              )
                            : null,
                      ),
                      title: Text(request.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GhostButton(
                            label: 'Recusar',
                            icon: Icons.close,
                            color: AppColors.error,
                            onPressed: () => provider.rejectRequest(request.id),
                            isExpanded: false,
                            height: 36,
                          ),
                          const SizedBox(width: 8),
                          SecondaryButton(
                            label: 'Aceitar',
                            icon: Icons.check,
                            onPressed: () => provider.acceptRequest(request.id),
                            isExpanded: false,
                            height: 36,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
