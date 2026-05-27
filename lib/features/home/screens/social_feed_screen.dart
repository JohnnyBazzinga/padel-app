import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/models/social_post.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/social_feed_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/widgets.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final List<String> _cities = const ['Todas', 'Lisboa', 'Madrid', 'Sao Paulo', 'Barcelona', 'Dubai'];
  String _selectedCity = 'Todas';
  String _availabilityFilter = 'Todos';
  final _commentController = TextEditingController();
  String _activePostId = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SocialFeedProvider>().fetchFeed(refresh: true));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  List<Post> _applyFilters(List<Post> posts) {
    var list = posts;
    if (_selectedCity != 'Todas') {
      list = list.where((post) {
        final authorCity = post.author?.city?.toLowerCase();
        return authorCity == _selectedCity.toLowerCase();
      }).toList();
    }

    if (_availabilityFilter != 'Todos') {
      return list.where(_matchesAvailability).toList();
    }
    return list;
  }

  bool _matchesAvailability(Post post) {
    final normalizedStatus = canonicalAvailabilityStatus(post.author?.availabilityStatus);

    if (normalizedStatus == null) {
      if (_availabilityFilter == 'A Procurar Parceiro') {
        return (post.author?.reputation ?? 0) >= 70;
      }
      return false;
    }

    switch (_availabilityFilter) {
      case 'A Jogar':
        return normalizedStatus == 'a_jogar';
      case 'A Procurar Parceiro':
        return normalizedStatus == 'a_procurar_parceiro';
      case 'Offline':
        return normalizedStatus == 'offline';
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<SocialFeedProvider>();
    final currentUserId = context.watch<AuthProvider>().user?.id;
    final posts = _applyFilters(feed.posts);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<SocialFeedProvider>().fetchFeed(refresh: true),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Feed', style: AppTypography.h1),
                            AppSpacing.verticalXs,
                            Text(
                              'Partilhas, partidas e ligações do mundo do padel',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.near_me_rounded,
                        variant: AppIconButtonVariant.glass,
                        onPressed: () => context.push('/need-1'),
                      ),
                  ],
                  ),

                  AppSpacing.verticalLg,
                  Text('Estado', style: AppTypography.labelLarge),
                  AppSpacing.verticalMd,
                  _StoryLikeBar(
                    selected: _availabilityFilter,
                    onTap: (value) => setState(() => _availabilityFilter = value),
                    items: const ['Todos', 'A Jogar', 'A Procurar Parceiro', 'Offline'],
                  ),
                  AppSpacing.verticalLg,
                  Text('Descobrir', style: AppTypography.labelLarge),
                  AppSpacing.verticalSm,
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final city = _cities[index];
                        final isSelected = city == _selectedCity;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCity = city),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: AppDecorations.borderRadiusFull,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Text(
                              city,
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected ? AppColors.background : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: _cities.length,
                    ),
                  ),
                  AppSpacing.verticalXl,
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: -0.05, end: 0),
            if (feed.error != null)
              Padding(
                padding: AppSpacing.screenPadding,
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Erro ao carregar feed',
                  message: feed.error!,
                  actionLabel: 'Tentar novamente',
                  onAction: () => context.read<SocialFeedProvider>().fetchFeed(refresh: true),
                ),
              ),
            if (feed.isLoading && posts.isEmpty && feed.error == null)
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: const [
                    SkeletonCard(height: 230),
                    AppSpacing.verticalMd,
                    SkeletonCard(height: 230),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: posts.isEmpty
                    ? EmptyState(
                        icon: Icons.photo_library_outlined,
                        title: 'Ainda sem publicações',
                        message: 'A tua comunidade ainda não publicou nada em $_selectedCity.',
                        actionLabel: 'Publicar agora',
                        onAction: () => _showCreatePostSheet(context),
                      )
                    : Column(
                        children: posts
                                  .map((post) => _PostCard(
                                        post: post,
                                        onLike: () =>
                                            context.read<SocialFeedProvider>().toggleLike(post.id),
                                        onComment: () => _openComments(context, post),
                                        onOpenAuthor: () => _openAuthorProfile(context, post),
                                        onFollow:
                                            (post.author == null ||
                                                    post.author!.id.isEmpty ||
                                                    post.author!.id == currentUserId)
                                                ? null
                                                : () => _toggleFollow(context, post.author!.id),
                                      ))
                                .toList(),
                              ),
              ),
            if (feed.hasMore && !feed.isLoadingMore)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Center(
                  child: SecondaryButton(
                    label: 'Carregar mais',
                    onPressed: () => context.read<SocialFeedProvider>().fetchFeed(),
                    isExpanded: false,
                  ),
                ),
              ),
            if (feed.isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
          ],
        ),
      ),
    );
  }

  void _openAuthorProfile(BuildContext context, Post post) {
    final author = post.author;
    if (author == null || author.id.isEmpty) {
      context.push('/profile');
      return;
    }
    context.push('/profile/${author.id}', extra: author);
  }

  Future<void> _toggleFollow(BuildContext context, String authorId) async {
    final success = await context.read<SocialFeedProvider>().toggleFollow(authorId);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar seguimento agora.'),
        ),
      );
    }
  }

  void _openComments(BuildContext context, Post post) {
    _activePostId = post.id;
    _commentController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final provider = context.read<SocialFeedProvider>();
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Consumer<SocialFeedProvider>(
            builder: (context, provider, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Comentários', style: AppTypography.h3),
                  AppSpacing.verticalMd,
                  if (post.latestComments.isEmpty)
                    Text(
                      'Sem comentários ainda.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    )
                  else
                    ...post.latestComments
                        .map(
                          (comment) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CommentRow(comment: comment),
                          ),
                        )
                        .toList(),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Partilha uma resposta',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send_rounded),
                        onPressed: () async {
                          final ok = await provider.addComment(
                            _activePostId,
                            _commentController.text,
                          );
                          if (ok) {
                            _commentController.clear();
                            Navigator.pop(sheetContext);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    final captionController = TextEditingController();
    final imageControllers = List.generate(3, (_) => TextEditingController());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Consumer<SocialFeedProvider>(
            builder: (context, provider, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nova publicação', style: AppTypography.h3),
                  AppSpacing.verticalMd,
                  TextField(
                    controller: captionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Escreve uma legenda...',
                    ),
                  ),
                  AppSpacing.verticalLg,
                  Text('Imagens (opcional)', style: AppTypography.labelMedium),
                  AppSpacing.verticalSm,
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: imageControllers[index],
                        decoration: InputDecoration(
                          hintText: 'URL da imagem ${index + 1}',
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.verticalLg,
                  PrimaryButton(
                    label: 'Publicar',
                    onPressed: () async {
                      final ok = await provider.createPost(
                        content: captionController.text,
                        mediaUrls: imageControllers
                            .map((item) => item.text.trim())
                            .where((item) => item.isNotEmpty)
                            .toList(),
                      );
                      if (ok != null && context.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      captionController.dispose();
      for (final c in imageControllers) c.dispose();
    });
  }
}

class _StoryLikeBar extends StatelessWidget {
  final String selected;
  final List<String> items;
  final ValueChanged<String> onTap;

  const _StoryLikeBar({
    required this.selected,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isActive = item == selected;

          return GestureDetector(
            onTap: () => onTap(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isActive ? AppColors.secondary : AppColors.surface,
                borderRadius: AppDecorations.borderRadiusFull,
              ),
              child: Text(
                item,
                style: AppTypography.labelSmall.copyWith(
                  color: isActive ? AppColors.background : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onOpenAuthor;
  final VoidCallback? onFollow;

  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onOpenAuthor,
    this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final authorName = post.authorName;
    final createdLabel = _formatDate(post.createdAt);
    final availabilityLabel = availabilityStatusLabel(post.author?.availabilityStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: AppDecorations.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onOpenAuthor,
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl: post.author?.avatarUrl,
                    name: authorName,
                    size: 42,
                  ),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: AppTypography.labelMedium,
                        ),
                        AppSpacing.verticalXxs,
                        Row(
                          children: [
                            Icon(Icons.place_outlined, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              '${post.author?.city ?? 'Padel'} · ${post.author?.reputation ?? ''}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (availabilityLabel != null) ...[
                  AppSpacing.verticalXs,
                  Row(
                    children: [
                      Icon(
                        Icons.circle_rounded,
                        size: 10,
                        color: _availabilityStatusColor(post.author?.availabilityStatus),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        availabilityLabel,
                        style: AppTypography.caption.copyWith(
                          color: _availabilityStatusColor(post.author?.availabilityStatus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSm,
                ],
                  if (onFollow != null)
                    _FollowButton(
                      isFollowing: post.isFollowingAuthor,
                      onPressed: onFollow!,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    createdLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (post.content != null && post.content!.trim().isNotEmpty) ...[
              AppSpacing.verticalMd,
              Text(post.content!, style: AppTypography.bodyMedium),
            ],
            if (post.media.isNotEmpty) ...[
              AppSpacing.verticalMd,
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.media.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final media = post.media[index];
                    return ClipRRect(
                      borderRadius: AppDecorations.borderRadiusMd,
                      child: _PostImage(media: media),
                    );
                  },
                ),
              ),
            ],
            AppSpacing.verticalMd,
            Row(
              children: [
                IconButton(
                  onPressed: onLike,
                  icon: Icon(
                    post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                    color: post.isLikedByMe ? AppColors.error : AppColors.textMuted,
                  ),
                ),
                Text(
                  '${post.likesCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                AppSpacing.horizontalMd,
                IconButton(
                  onPressed: onComment,
                  icon: const Icon(Icons.mode_comment_outlined),
                ),
                Text(
                  '${post.commentsCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.ios_share_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            if (post.latestComments.isNotEmpty) ...[
              AppSpacing.verticalXs,
              Divider(color: AppColors.glassBorder),
              AppSpacing.verticalSm,
              ...post.latestComments
                  .take(2)
                  .map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _CommentRow(comment: comment),
                    ),
                  )
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }
}

Color _availabilityStatusColor(String? status) {
  final canonical = canonicalAvailabilityStatus(status);
  switch (canonical) {
    case 'a_jogar':
      return AppColors.success;
    case 'a_procurar_parceiro':
      return AppColors.warning;
    case 'offline':
      return AppColors.textMuted;
    case 'busy':
      return AppColors.error;
    default:
      return AppColors.primary;
  }
}

class _PostImage extends StatelessWidget {
  final PostMedia media;

  const _PostImage({required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.url == null || media.url!.isEmpty) {
      return Container(
        width: 260,
        height: 220,
        color: AppColors.surfaceBright,
        child: const Icon(Icons.image_not_supported_rounded),
      );
    }

    return Image.network(
      media.url!,
      width: 260,
      height: 220,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 260,
        height: 220,
        color: AppColors.surfaceBright,
        child: const Icon(Icons.broken_image_rounded),
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final PostComment comment;

  const _CommentRow({required this.comment});

  @override
  Widget build(BuildContext context) {
    final name = comment.author?.name ?? 'Jogador';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(imageUrl: comment.author?.avatarUrl, name: name, size: 28),
        AppSpacing.horizontalSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTypography.labelSmall),
              AppSpacing.verticalXxs,
              Text(
                comment.text ?? '',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onPressed;

  const _FollowButton({
    required this.isFollowing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: AppDecorations.borderRadiusFull,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isFollowing ? AppColors.surfaceBright : AppColors.primary.withOpacity(0.12),
          border: Border.all(
            color: isFollowing ? AppColors.glassBorder : AppColors.primary,
          ),
          borderRadius: AppDecorations.borderRadiusFull,
        ),
        child: Text(
          isFollowing ? 'Seguindo' : 'Seguir',
          style: AppTypography.labelSmall.copyWith(
            color: isFollowing ? AppColors.textMuted : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime dateTime) {
  return DateFormat('dd/MM HH:mm', 'pt_PT').format(dateTime);
}
