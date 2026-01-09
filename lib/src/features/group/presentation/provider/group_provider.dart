import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/explore/domain/category.dart';
import 'package:larnity/src/features/group/data/datasource/group_datasource.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/features/group/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final groupProvider = NotifierProvider.autoDispose<GroupNotifier, GroupState>(
  GroupNotifier.new,
);

class GroupNotifier extends AutoDisposeNotifier<GroupState> {
  TextEditingController groupNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  GroupState build() {
    groupNameController = TextEditingController();

    ref.listen(authProvider, (_, next) {
      final userId = next.user?.id;
      if (userId != null && userId.isNotEmpty) {
        getExploreGroups(userId: userId);
      }
    });

    Future.microtask(() async {
      final userId = ref.watch(authProvider).user?.id ?? "";
      if (userId.isNotEmpty) {
        await getExploreGroups(userId: userId);
      }
    });

    groupNameController.addListener(() {
      state = state.copyWith(groupName: groupNameController.text);
    });

    ref.onDispose(() {
      groupNameController.dispose();
    });

    return GroupState(fetchState: AsyncState.initial);
  }

  // ✅ NEW METHOD: Check if current user is a member of the selected group
  Future<void> checkMembershipStatus() async {
    final userId = ref.read(authProvider).user?.id;
    final groupId = state.group?.id;

    if (userId == null || groupId == null) {
      state = state.copyWith(isCurrentUserMember: false);
      return;
    }

    final dataSource = ref.read(groupDataSourceProvider);
    final result = await dataSource.isMember(userId: userId, groupId: groupId);

    result.fold(
      (failure) {
        Log.error("❌ Error checking membership: ${failure.message}");
        state = state.copyWith(isCurrentUserMember: false);
      },
      (isMember) {
        Log.info("✅ Membership status: $isMember");
        state = state.copyWith(isCurrentUserMember: isMember);
      },
    );
  }

  // Pick thumbnail image
  Future<void> pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        state = state.copyWith(selectedThumbnail: image);
        Log.info("Thumbnail selected: ${image.path}");
      }
    } catch (e) {
      Log.error("Error picking thumbnail: $e");
      state = state.copyWith(error: "Failed to pick image");
    }
  }

  // Upload thumbnail to Supabase Storage and update group
  Future<void> updateGroupThumbnail({
    required String groupId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    if (state.selectedThumbnail == null) {
      failureCallBack?.call("No thumbnail selected");
      return;
    }

    if (state.group == null) {
      failureCallBack?.call("No group selected");
      return;
    }

    final dataSource = ref.read(groupDataSourceProvider);
    final supabase = ref.read(supabaseClientProvider);

    state = state.copyWith(updateState: AsyncState.loading);

    try {
      // Upload to Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'thumbnail_$timestamp.jpg';
      final filePath = 'groups/$groupId/$fileName';

      final file = File(state.selectedThumbnail!.path);
      final bytes = await file.readAsBytes();

      await supabase.storage
          .from('images')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = supabase.storage.from('images').getPublicUrl(filePath);
      Log.info("Thumbnail uploaded: $publicUrl");

      // Update group with new thumbnail URL
      final updatedGroup = state.group!.copyWith(thumbnail: publicUrl);
      Log.info("🔍 Updated group thumbnail: ${updatedGroup.thumbnail}");
      Log.info("🔍 Updated group toMap: ${updatedGroup.toMap()}");

      final response = await dataSource.updateGroup(group: updatedGroup);

      response.fold(
        (failure) {
          state = state.copyWith(
            updateState: AsyncState.failure,
            error: failure.message,
          );
          failureCallBack?.call(failure.message);
        },
        (group) {
          state = state.copyWith(
            updateState: AsyncState.success,
            group: group,
            clearThumbnail: true,
          );
          successCallBack?.call();
          Log.info("Group thumbnail updated successfully");
        },
      );
    } catch (e) {
      Log.error("Error updating thumbnail: $e");
      state = state.copyWith(
        updateState: AsyncState.failure,
        error: e.toString(),
      );
      failureCallBack?.call(e.toString());
    }
  }

  // Join group
  Future<bool> joinGroup({required String groupId}) async {
    final dataSource = ref.read(groupDataSourceProvider);
    final userId = ref.read(authProvider).user?.id;

    if (userId == null || userId.isEmpty) {
      Log.error("❌ User not authenticated");
      return false;
    }

    state = state.copyWith(updateState: AsyncState.loading);

    // First check if already member
    final checkResult = await dataSource.isMember(
      userId: userId,
      groupId: groupId,
    );

    final alreadyMember = checkResult.fold(
      (failure) => false,
      (isMember) => isMember,
    );

    if (alreadyMember) {
      state = state.copyWith(
        updateState: AsyncState.failure,
        error: "Already a member",
      );
      return false;
    }

    // Join group
    final response = await dataSource.joinGroup(
      userId: userId,
      groupId: groupId,
    );

    return response.fold(
      (failure) {
        state = state.copyWith(
          updateState: AsyncState.failure,
          error: failure.message,
        );
        Log.error("❌ Join group failed: ${failure.message}");
        return false;
      },
      (_) {
        state = state.copyWith(
          updateState: AsyncState.success,
          isCurrentUserMember: true, // ✅ Update membership status
        );
        Log.info("✅ Successfully joined group $groupId");
        return true;
      },
    );
  }

  Future<void> createGroup({
    required GroupModel group,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(groupDataSourceProvider);
    final userId = ref.read(authProvider).user?.id;

    if (userId == null || userId.isEmpty) {
      final error = "User not authenticated";
      state = state.copyWith(createState: AsyncState.failure, error: error);
      failureCallBack?.call(error);
      return;
    }

    state = state.copyWith(createState: AsyncState.loading);
    final response = await dataSource.createGroup(group: group);

    response.fold(
      (failure) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (createdGroup) async {
        state = state.copyWith(
          selectedCategory: null,
          createState: AsyncState.success,
          group: createdGroup,
        );
        await getGroupsByUser(userId: userId);
        successCallBack?.call();
      },
    );
  }

  Future<void> fetchGroupById(String groupId) async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);

    final response = await dataSource.getGroup(id: groupId);

    response.fold(
      (failure) {
        state = state.copyWith(
          fetchState: AsyncState.failure,
          error: failure.message,
        );
      },
      (group) {
        state = state.copyWith(fetchState: AsyncState.success, group: group);
      },
    );
  }

  Future<void> getGroupsByUser({required String userId}) async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final response = await dataSource.getGroupsByUser(userId: userId);

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (groups) => state = state.copyWith(
        fetchState: AsyncState.success,
        groups: groups,
      ),
    );
  }

  Future<void> getPublicGroups() async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final response = await dataSource.getPublicGroups();

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (groups) => state = state.copyWith(
        fetchState: AsyncState.success,
        groups: groups,
      ),
    );
  }

  Future<void> getExploreGroups({required String userId}) async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);

    final publicRes = await dataSource.getPublicGroups();
    final userRes = await dataSource.getGroupsByUser(userId: userId);

    publicRes.fold(
      (failure) {
        state = state.copyWith(
          fetchState: AsyncState.failure,
          error: failure.message,
        );
      },
      (publicGroups) {
        userRes.fold(
          (failure) {
            state = state.copyWith(
              fetchState: AsyncState.failure,
              error: failure.message,
            );
          },
          (userGroups) {
            final Map<String, GroupModel> unique = {};
            for (final g in publicGroups) {
              if (g.id != null) unique[g.id!] = g;
            }
            for (final g in userGroups) {
              if (g.id != null) unique[g.id!] = g;
            }
            state = state.copyWith(
              fetchState: AsyncState.success,
              groups: unique.values.toList(),
            );
          },
        );
      },
    );
  }

  Future<void> updateGroupStatus({
    required String id,
    required GroupStatus status,
    String? rejectionReason,
  }) async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final response = await dataSource.updateGroupStatus(
      id: id,
      status: status,
      rejectionReason: rejectionReason,
    );

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (group) {
        final updatedGroups = state.groups?.map((g) {
          return g.id == group.id ? group : g;
        }).toList();

        state = state.copyWith(
          fetchState: AsyncState.success,
          group: group,
          groups: updatedGroups,
        );
      },
    );
  }

  Future<void> fetchGroupMembers(String groupId) async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);

    final response = await dataSource.getGroupMembers(groupId: groupId);

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (members) => state = state.copyWith(
        fetchState: AsyncState.success,
        groupMembers: members,
      ),
    );
  }

  Future<void> getGroupBySlug({required String slug}) async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final response = await dataSource.getGroupBySlug(slug: slug);

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (group) =>
          state = state.copyWith(fetchState: AsyncState.success, group: group),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = GroupState(fetchState: AsyncState.initial);
  }

  void setSelectedGroup(GroupModel? group) {
    if (group != null) {
      state = state.copyWith(group: group);
      Log.info("Selected group: ${group.name} (${group.id})");
      // ✅ Check membership when group is selected
      checkMembershipStatus();
    } else {
      state = state.copyWith(group: null);
      Log.info("Cleared selected group");
    }
  }

  void selectCategory({required Category category}) {
    state = state.copyWith(selectedCategory: category);
  }

  void refreshGroupsForCurrentUser() {
    final userId = ref.read(authProvider).user?.id;
    if (userId != null && userId.isNotEmpty) {
      getGroupsByUser(userId: userId);
    }
  }

  void setSelectedTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }
}

class GroupState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final AsyncState? updateState;
  final String? error;
  final String? groupName;
  final GroupModel? group;
  final List<GroupModel>? groups;
  final Category? selectedCategory;
  final int selectedTabIndex;
  final XFile? selectedThumbnail;
  final List<MemberModel>? groupMembers;
  final String? currentUserRole;
  final bool isCurrentUserMember; // ✅ NEW FIELD

  GroupState({
    this.fetchState,
    this.createState,
    this.updateState,
    this.error,
    this.groupName,
    this.group,
    this.groups,
    this.selectedCategory,
    this.selectedTabIndex = 0,
    this.selectedThumbnail,
    this.groupMembers,
    this.currentUserRole,
    this.isCurrentUserMember = false, // ✅ DEFAULT TO FALSE
  });

  GroupState copyWith({
    AsyncState? fetchState,
    AsyncState? createState,
    AsyncState? updateState,
    String? error,
    String? groupName,
    GroupModel? group,
    List<GroupModel>? groups,
    Category? selectedCategory,
    int? selectedTabIndex,
    XFile? selectedThumbnail,
    List<MemberModel>? groupMembers,
    bool clearThumbnail = false,
    bool clearMembers = false,
    String? currentUserRole,
    bool? isCurrentUserMember, // ✅ NEW PARAMETER
  }) {
    return GroupState(
      fetchState: fetchState ?? this.fetchState,
      createState: createState ?? this.createState,
      updateState: updateState ?? this.updateState,
      error: error ?? this.error,
      groupName: groupName ?? this.groupName,
      group: group ?? this.group,
      groups: groups ?? this.groups,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedThumbnail: clearThumbnail
          ? null
          : (selectedThumbnail ?? this.selectedThumbnail),
      groupMembers: clearMembers ? null : (groupMembers ?? this.groupMembers),
      currentUserRole: currentUserRole ?? this.currentUserRole,
      isCurrentUserMember:
          isCurrentUserMember ?? this.isCurrentUserMember, // ✅ NEW
    );
  }

  bool get isLoading => fetchState == AsyncState.loading;
  bool get isSuccess => fetchState == AsyncState.success;
  bool get isFailure => fetchState == AsyncState.failure;

  List<GroupModel> get publicGroups =>
      groups?.where((group) => group.isPublic && group.isApproved).toList() ??
      [];

  List<GroupModel> get pendingGroups =>
      groups?.where((group) => group.isPending).toList() ?? [];
}
