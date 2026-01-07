import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/provider/chat_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';

class ChattingScreen extends ConsumerStatefulWidget {
  const ChattingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends ConsumerState<ChattingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final groupId = ref.read(groupProvider).group?.id;
      if (groupId != null) {
        ref.read(chatProvider.notifier).subscribeToMessages(groupId: groupId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    ref.read(chatProvider.notifier).unsubscribe();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final chatState = ref.watch(chatProvider);
    final authState = ref.watch(authProvider);
    final selectedGroup = groupState.group;
    final currentUserId = authState.user?.id;

    if (selectedGroup == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.messages, style: AppTextStyles.button()),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: AppColors.creamWhite.withValues(alpha: 0.3),
              ),
              AppSizes.xs.ph,
              Text(AppStrings.noChatSelected, style: AppTextStyles.headline3()),
              AppSizes.xs.ph,
              Text(
                AppStrings.noChatSelectedDesc,
                style: AppTextStyles.caption2(
                  color: AppColors.creamWhite.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryOrange,
              child: selectedGroup.icon != null
                  ? ClipOval(
                      child: Image.network(
                        selectedGroup.icon!,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.group, color: AppColors.white),
                      ),
                    )
                  : Icon(Icons.group, color: AppColors.white),
            ),
            AppSizes.xs.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedGroup.name,
                    style: AppTextStyles.bodyText1(color: AppColors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${chatState.members.length} members",
                    style: AppTextStyles.caption2(
                      color: AppColors.creamWhite.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        backgroundColor: AppColors.darkBg,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.lg.ph,
              Text(
                AppStrings.groupMembers,
                style: AppTextStyles.headline4(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              Text(
                AppStrings.selectMemberToChat,
                style: AppTextStyles.caption2(color: AppColors.skyBlue),
              ),
              AppSizes.xs.ph,
              Divider(color: AppColors.skyBlue.withValues(alpha: 0.5)),
              AppSizes.xs.ph,
              Expanded(
                child: chatState.members.isEmpty
                    ? Center(
                        child: Text(
                          "No members found",
                          style: AppTextStyles.caption2(
                            color: AppColors.creamWhite,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: chatState.members.length,
                        itemBuilder: (context, index) {
                          final member = chatState.members[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryOrange,
                              child: Text(
                                member.name[0].toUpperCase(),
                                style: AppTextStyles.bodyText1(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              member.name,
                              style: AppTextStyles.bodyText2(
                                color: AppColors.white,
                              ),
                            ),
                            subtitle: Text(
                              member.isOnline ? "Online" : "Offline",
                              style: AppTextStyles.caption2(
                                color: member.isOnline
                                    ? AppColors.green
                                    : AppColors.creamWhite.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                            ),
                            trailing: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: member.isOnline
                                    ? AppColors.green
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: chatState.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.1),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 60,
                            color: AppColors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        AppSizes.lg.ph,
                        Text(
                          "No messages yet",
                          style: AppTextStyles.headline3(
                            color: AppColors.white,
                          ),
                        ),
                        AppSizes.xs.ph,
                        Text(
                          "Start the conversation by sending your first\nmessage!",
                          style: AppTextStyles.caption2(
                            color: AppColors.creamWhite.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(AppSizes.xs),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      final isMe =
                          message.senderId != null &&
                          message.senderId == currentUserId;
                      final showAvatar =
                          index == 0 ||
                          chatState.messages[index - 1].senderId !=
                              message.senderId;

                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSizes.xs),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              if (showAvatar)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primaryOrange,
                                  child: Text(
                                    (message.senderName.isNotEmpty
                                            ? message.senderName[0]
                                            : '?')
                                        .toUpperCase(),
                                    style: AppTextStyles.caption2(
                                      color: AppColors.white,
                                    ),
                                  ),
                                )
                              else
                                SizedBox(width: 32),
                              AppSizes.xxxs.pw,
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (showAvatar && !isMe)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 4,
                                        left: AppSizes.xxxs,
                                      ),
                                      child: Text(
                                        message.senderName,
                                        style: AppTextStyles.caption2(
                                          color: AppColors.creamWhite
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSizes.xs,
                                      vertical: AppSizes.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? AppColors.primaryOrange
                                          : AppColors.darkBgContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.content,
                                          style: AppTextStyles.bodyText2(
                                            color: AppColors.white,
                                          ),
                                        ),
                                        AppSizes.xxxs.ph,
                                        Text(
                                          _formatTime(message.createdAt),
                                          style: AppTextStyles.caption2(
                                            color: isMe
                                                ? AppColors.white.withValues(
                                                    alpha: 0.7,
                                                  )
                                                : AppColors.creamWhite
                                                      .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: AppColors.darkBg,
              border: Border(
                top: BorderSide(
                  color: AppColors.borderBrown.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkBgContainer,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.borderBrown.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: AppTextStyles.bodyText2(color: AppColors.white),
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: AppTextStyles.bodyText2(
                          color: AppColors.creamWhite.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSizes.xs,
                          vertical: AppSizes.xxs,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                ),
                AppSizes.xs.pw,
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send_rounded, color: AppColors.black),
                    onPressed: () async {
                      final content = _messageController.text.trim();
                      if (content.isEmpty) return;

                      final success = await ref
                          .read(chatProvider.notifier)
                          .sendMessage(
                            groupId: selectedGroup.id!,
                            content: content,
                          );

                      if (success) {
                        _messageController.clear();
                        Future.delayed(Duration(milliseconds: 100), () {
                          _scrollToBottom();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }
}
