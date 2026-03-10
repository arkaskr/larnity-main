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
import 'package:larnity/src/features/group/data/models/paymintro_creds_model.dart';
import 'package:larnity/src/core/ui/widgets/toast.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/features/group/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:share_plus/share_plus.dart' as share_plus;

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

  // Pick icon image
  Future<void> pickIcon() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );

      if (image != null) {
        state = state.copyWith(selectedIcon: image);
        Log.info("Icon selected: ${image.path}");
      }
    } catch (e) {
      Log.error("Error picking icon: $e");
      state = state.copyWith(error: "Failed to pick image");
    }
  }

  // Upload icon to Supabase Storage and update group
  Future<void> updateGroupIcon({
    required String groupId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    if (state.selectedIcon == null) {
      failureCallBack?.call("No icon selected");
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
      final fileName = 'icon_$timestamp.jpg';
      final filePath = 'groups/$groupId/$fileName';

      final file = File(state.selectedIcon!.path);
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
      Log.info("Icon uploaded: $publicUrl");

      // Update group with new icon URL
      final updatedGroup = state.group!.copyWith(icon: publicUrl);
      Log.info("🔍 Updated group icon: ${updatedGroup.icon}");

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
            clearIcon: true,
          );
          successCallBack?.call();
          Log.info("Group icon updated successfully");
        },
      );
    } catch (e) {
      Log.error("Error updating icon: $e");
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

    final result = response.fold(
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

    // ✅ Refresh groups list AFTER successful join so GroupNavBar shows updated list
    // This must complete BEFORE navigation pop
    if (result) {
      await getExploreGroups(userId: userId);
    }

    return result;
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

  void selectCategory({Category? category}) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }
  // group_provider.dart mein add karo (around line 200 ke baad)

  Future<void> updateGroupPrices({
    required GroupModel group,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(groupDataSourceProvider);

    state = state.copyWith(updateState: AsyncState.loading);

    final response = await dataSource.updateGroup(group: group);

    response.fold(
      (failure) {
        state = state.copyWith(
          updateState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (updatedGroup) {
        state = state.copyWith(
          updateState: AsyncState.success,
          group: updatedGroup,
        );
        successCallBack?.call();
        Log.info("Group prices updated successfully");
      },
    );
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

  // Create invitation
  Future<void> createInvitation({
    required String groupId,
    required String email,
    String? name,
    required String planType,
    int expirationHours = 48,
    bool sendEmail = true,
    void Function(String link)? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(updateState: AsyncState.loading);

    final response = await dataSource.createInvitation(
      groupId: groupId,
      email: email,
      name: name,
      planType: planType,
      expirationHours: expirationHours,
      sendEmail: sendEmail,
    );

    response.fold(
      (failure) {
        state = state.copyWith(
          updateState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (link) {
        state = state.copyWith(updateState: AsyncState.success);
        successCallBack?.call(link);
        Log.info("Invitation created successfully");
      },
    );
  }

  // Update Google Sheet settings
  Future<void> updateGoogleSheetSettings({
    required String groupId,
    String? googleSheetId,
    required bool enableSync,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(updateState: AsyncState.loading);

    final response = await dataSource.updateGoogleSheetSettings(
      groupId: groupId,
      googleSheetId: googleSheetId,
      enableSync: enableSync,
    );

    response.fold(
      (failure) {
        state = state.copyWith(
          updateState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (updatedGroup) {
        state = state.copyWith(
          updateState: AsyncState.success,
          group: updatedGroup,
        );
        successCallBack?.call();
        Log.info("Google Sheet settings updated successfully");
      },
    );
  }
  Future<bool> savePaymintroCreds(PaymintroCredsModel creds) async {
    state = state.copyWith(updateState: AsyncState.loading);
    try {
      final result = await ref.read(groupDataSourceProvider).savePaymintroCreds(creds);
      return result.fold(
        (l) {
          Log.error("Failed to save Paymintro creds: ${l.message}");
          AppToast.show("Failed to save credentials: ${l.message}",
              isError: true);
          return false;
        },
        (r) {
          Log.info("Paymintro credentials saved successfully");
          AppToast.show("Connected Paymintro successfully");
          return true;
        },
      );
    } catch (e) {
      Log.error("Exception saving Paymintro creds: $e");
      AppToast.show("Exception saving credentials: $e", isError: true);
      return false;
    } finally {
      state = state.copyWith(updateState: AsyncState.initial);
    }
  }

  // Export Group Members to CSV
  Future<void> exportGroupMembers({
    required String groupId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(updateState: AsyncState.loading);

    try {
      // 1. Fetch Members
      final response = await dataSource.getGroupMembers(groupId: groupId);

      await response.fold(
        (failure) async {
          state = state.copyWith(
            updateState: AsyncState.failure,
            error: failure.message,
          );
          failureCallBack?.call(failure.message);
        },
        (members) async {
          if (members.isEmpty) {
            failureCallBack?.call("No members found to export");
            state = state.copyWith(updateState: AsyncState.initial);
            return;
          }

          // 2. Generate CSV String
          final StringBuffer csvBuffer = StringBuffer();
          
          // Header
          csvBuffer.writeln("User ID,Name,Email,Role,Plan,Join Date,Status");

          for (final member in members) {
            final userId = member.userId;
            final name = member.name.replaceAll(',', ' '); // Escape commas
            final email = member.email ?? 'N/A';
            final role = member.role;
            final plan = member.planType ?? 'N/A';
            final joinDate = member.subscriptionStartDate != null 
                ? member.subscriptionStartDate!.toIso8601String().split('T').first 
                : 'N/A';
            final status = member.isActive ? 'Active' : 'Inactive';

            csvBuffer.writeln("$userId,$name,$email,$role,$plan,$joinDate,$status");
          }

          // 3. Save to Temp File
          final directory = await path_provider.getTemporaryDirectory();
          final file = File('${directory.path}/group_members_$groupId.csv');
          await file.writeAsString(csvBuffer.toString());

          // 4. Share File
          await share_plus.Share.shareXFiles(
            [share_plus.XFile(file.path)],
            text: 'Group Members Export',
          );

          state = state.copyWith(updateState: AsyncState.success);
          successCallBack?.call();
          Log.info("✅ Exported ${members.length} members");
        },
      );
    } catch (e) {
      Log.error("❌ Export Error: $e");
      state = state.copyWith(
        updateState: AsyncState.failure,
        error: e.toString(),
      );
      failureCallBack?.call(e.toString());
    } finally {
        state = state.copyWith(updateState: AsyncState.initial);
    }
  }

  Future<void> updateGroupTabSettings({
    required String groupId,
    required Map<String, bool> tabSettings,
    VoidCallback? successCallBack,
    Function(String)? failureCallBack,
  }) async {
    try {
      final currentGroup = state.group;
      if (currentGroup == null) {
        failureCallBack?.call("No group selected");
        return;
      }

      final updatedGroup = currentGroup.copyWith(tabSettings: tabSettings);

      // Optimistic update
      state = state.copyWith(group: updatedGroup);

      final result = await ref.read(groupDataSourceProvider).updateGroup(group: updatedGroup);

      result.fold(
        (failure) {
          Log.error("Failed to update tab settings: ${failure.message}");
          // Revert on failure
          state = state.copyWith(group: currentGroup);
          failureCallBack?.call(failure.message);
        },
        (updatedGroupFromDb) {
          Log.info("Tab settings updated successfully");
          state = state.copyWith(group: updatedGroupFromDb);
          successCallBack?.call();
        },
      );
    } catch (e) {
      Log.error("Error updating tab settings: $e");
      failureCallBack?.call(e.toString());
    }
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
  final XFile? selectedIcon;
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
    this.selectedIcon,
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
    XFile? selectedIcon,
    List<MemberModel>? groupMembers,
    bool clearThumbnail = false,
    bool clearIcon = false,
    bool clearMembers = false,
    bool clearCategory = false, // ✅ NEW FLAG to clear selectedCategory
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
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedThumbnail: clearThumbnail
          ? null
          : (selectedThumbnail ?? this.selectedThumbnail),
      selectedIcon: clearIcon ? null : (selectedIcon ?? this.selectedIcon),
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
