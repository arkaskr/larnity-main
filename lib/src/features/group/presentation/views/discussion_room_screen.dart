import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/post_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/create_post.dart';

class DiscussionRoomScreen extends ConsumerStatefulWidget {
  const DiscussionRoomScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscussionRoomScreen> createState() =>
      _DiscussionRoomScreenState();
}

class _DiscussionRoomScreenState extends ConsumerState<DiscussionRoomScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch posts when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupState = ref.read(groupProvider);
      final channelId = groupState.group?.id;
      if (channelId != null) {
        ref.read(postProvider).fetchPosts(channelId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final postState = ref.watch(postProvider);
    final channelId = groupState.group?.id;

    if (channelId == null) {
      return const Center(child: Text('No group selected'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Column(
        children: [
          AppSizes.xs.ph,

          /// CREATE POST BUTTON
          AppButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.darkBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: CreatePost(channelId: channelId),
                  ),
                ),
              );
            },
            bgColor: AppColors.iconColor,
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.xs,
              horizontal: AppSizes.xs,
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryOrange,
                  ),
                ),
                AppSizes.xxxs.pw,
                Expanded(
                  child: Text(
                    AppStrings.postButtonText,
                    style: AppTextStyles.subtitle2(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          AppSizes.xs.ph,

          /// POSTS LIST
          Expanded(
            child: postState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : postState.posts.isEmpty
                ? Center(
                    child: Text(
                      'No posts yet. Be the first to post!',
                      style: AppTextStyles.subtitle2(color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(postProvider).fetchPosts(channelId);
                    },
                    child: ListView.builder(
                      itemCount: postState.posts.length,
                      itemBuilder: (context, index) {
                        final post = postState.posts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSizes.xs),
                          color: AppColors.iconColor,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.xs),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: AppTextStyles.headline3(
                                    color: AppColors.white,
                                  ),
                                ),
                                AppSizes.xxxs.ph,
                                if (post.content != null)
                                  Text(
                                    post.content!,
                                    style: AppTextStyles.bodyText2(
                                      color: Colors.grey,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                AppSizes.xxxs.ph,
                                Text(
                                  post.createdAt != null
                                      ? _formatDate(post.createdAt!)
                                      : '',
                                  style: AppTextStyles.caption(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
