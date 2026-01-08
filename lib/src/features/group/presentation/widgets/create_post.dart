import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_slash_editor.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';
import 'package:larnity/src/features/group/presentation/provider/post_provider.dart';

class CreatePost extends ConsumerStatefulWidget {
  final String channelId;

  const CreatePost({Key? key, required this.channelId}) : super(key: key);

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final TextEditingController _titleController = TextEditingController();
  String _editorJsonContent = ""; // ✅ JSON format
  String _editorHtmlContent = ""; // ✅ Plain text
  int _currentLength = 0;

  static const int maxChars = 10000;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleCreatePost() async {
    final currentUser = ref.read(supabaseClientProvider).auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post')),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    if (_editorHtmlContent.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please add some content')));
      return;
    }

    final post = PostModel(
      title: _titleController.text.trim(),
      content: _editorHtmlContent, // Plain text for preview
      htmlContent: _editorHtmlContent, // Plain text (backward compatibility)
      jsonContent: _editorJsonContent, // Quill Delta JSON for editing later
      authorId: currentUser.id,
      channelId: widget.channelId,
    );

    final success = await ref.read(postProvider).createPost(post);

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${ref.read(postProvider).errorMessage}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryOrange,
                ),
              ),
              AppSizes.xs.pw,
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppStrings.postingIn,
                      style: AppTextStyles.subtitle2(color: AppColors.white),
                    ),
                    TextSpan(
                      text: "General",
                      style: AppTextStyles.subtitle1(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSizes.lg.ph,

          /// TITLE
          TextField(
            controller: _titleController,
            style: AppTextStyles.subtitle1(color: AppColors.white),
            decoration: InputDecoration(
              hintText: AppStrings.postTitle,
              hintStyle: AppTextStyles.subtitle2(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),

          AppSizes.sm.ph,

          /// BODY EDITOR
          Expanded(
            child: AppDropdownSlashEditor(
              onTextLengthChanged: (len) {
                setState(() {
                  _currentLength = len;
                });
              },
              // ✅ CORRECT: Two parameters - json and html (plain text)
              onContentChanged: (json, html) {
                setState(() {
                  _editorJsonContent = json; // Delta JSON
                  _editorHtmlContent = html; // Plain text
                });
              },
            ),
          ),

          /// CHARACTER COUNTER
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.xxxs),
            child: Text(
              "$_currentLength/$maxChars",
              style: AppTextStyles.caption(color: Colors.grey),
            ),
          ),

          AppSizes.sm.ph,
          const Divider(color: Colors.grey),

          /// FOOTER
          Row(
            children: [
              Text(
                AppStrings.shareWithGroup,
                style: AppTextStyles.subtitle2(color: Colors.grey),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  AppStrings.close,
                  style: AppTextStyles.subtitle2(color: Colors.grey),
                ),
              ),
              AppSizes.xs.pw,
              AppButton(
                onPressed: isLoading ? null : _handleCreatePost,
                isExpanded: false,
                bgColor: AppColors.white,
                label: isLoading ? "Posting..." : AppStrings.post,
                suffix: HugeIcon(
                  icon: HugeIconsStrokeRounded.plane,
                  color: AppColors.black,
                ),
                labelStyle: AppTextStyles.button(color: AppColors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
