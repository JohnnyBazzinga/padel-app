import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/theme.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showBorder;
  final bool showGradient;
  final Color? borderColor;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.showBorder = false,
    this.showGradient = true,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: showGradient && imageUrl == null
              ? AppColors.primaryGradient
              : null,
          color: !showGradient && imageUrl == null
              ? AppColors.surfaceLight
              : null,
          border: showBorder
              ? Border.all(
                  color: borderColor ?? AppColors.background,
                  width: 2,
                )
              : null,
          boxShadow: showGradient && imageUrl == null
              ? AppDecorations.shadowGlow(AppColors.primary, intensity: 0.2)
              : null,
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(initials),
                  errorWidget: (context, url, error) => _buildPlaceholder(initials),
                )
              : _buildPlaceholder(initials),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: showGradient ? AppColors.background : AppColors.textPrimary,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}

class AvatarStack extends StatelessWidget {
  final List<AvatarData> avatars;
  final double size;
  final double overlap;
  final int maxDisplay;
  final int? totalCount;

  const AvatarStack({
    super.key,
    required this.avatars,
    this.size = 32,
    this.overlap = 0.3,
    this.maxDisplay = 3,
    this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final displayAvatars = avatars.take(maxDisplay).toList();
    final remaining = (totalCount ?? avatars.length) - maxDisplay;
    final overlapOffset = size * (1 - overlap);

    return SizedBox(
      width: overlapOffset * displayAvatars.length +
             (remaining > 0 ? overlapOffset : 0) +
             size * overlap,
      height: size,
      child: Stack(
        children: [
          ...List.generate(displayAvatars.length, (index) {
            return Positioned(
              left: index * overlapOffset,
              child: UserAvatar(
                imageUrl: displayAvatars[index].imageUrl,
                name: displayAvatars[index].name,
                size: size,
                showBorder: true,
                borderColor: AppColors.surface,
              ),
            );
          }),
          if (remaining > 0)
            Positioned(
              left: displayAvatars.length * overlapOffset,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: size * 0.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AvatarData {
  final String? imageUrl;
  final String? name;

  const AvatarData({
    this.imageUrl,
    this.name,
  });
}
