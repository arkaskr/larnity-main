import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final groupDataSourceProvider = Provider<GroupDataSource>((ref) {
  return GroupDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class GroupDataSource {
  final SupabaseClient supabaseClient;

  GroupDataSource({required this.supabaseClient});

  Future<Either<Failure, GroupModel>> createGroup({
    required GroupModel group,
  }) async {
    try {
      final response = await supabaseClient
          .from('Group')
          .insert(group.toMap())
          .select()
          .single();

      Log.info("Create Group Response: ${response.toString()}");

      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, GroupModel>> getGroup({required String id}) async {
    try {
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('id', id)
          .single();

      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  // ✅ REPLACE COMPLETE METHOD (Line 62-84)
  Future<Either<Failure, List<GroupModel>>> getGroupsByUser({
    required String userId,
  }) async {
    try {
      // Get groups where user is creator OR member
      final createdGroups = await supabaseClient
          .from('Group')
          .select()
          .eq('userId', userId)
          .order('created_at', ascending: false);

      final memberGroups = await supabaseClient
          .from('Members')
          .select('''
          role,
          Group:groupId (*)
        ''')
          .eq('userId', userId)
          .eq('isActive', true);

      // Combine both lists
      List<GroupModel> allGroups = [];

      // Add created groups (user is owner/admin)
      for (var data in createdGroups) {
        final group = GroupModel.fromMap(data);
        allGroups.add(group.copyWith(userRole: 'ADMIN'));
      }

      // Add member groups
      for (var data in memberGroups) {
        final role = data['role'] as String?;
        final groupData = data['Group'] as Map<String, dynamic>;
        final group = GroupModel.fromMap(groupData);

        // Skip if already added as creator
        if (!allGroups.any((g) => g.id == group.id)) {
          allGroups.add(group.copyWith(userRole: role));
        }
      }

      return Right(allGroups);
    } on PostgrestException catch (e) {
      Log.error("Get Groups by User Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Groups by User Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<GroupModel>>> getPublicGroups() async {
    try {
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('privacy', 'PUBLIC')
          .order('created_at', ascending: false);

      Log.info("🔍 Raw Response: ${response.length} groups");
      Log.info(
        "🔍 First group: ${response.isNotEmpty ? response.first : 'EMPTY'}",
      );

      final groups = response.map((data) {
        try {
          return GroupModel.fromMap(data);
        } catch (e) {
          Log.error("❌ Error mapping group: $e");
          Log.error("❌ Data: $data");
          rethrow;
        }
      }).toList();

      Log.info("✅ Mapped ${groups.length} groups successfully");
      return Right(groups);
    } on PostgrestException catch (e) {
      Log.error("Get Public Groups Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Public Groups Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<GroupModel>>> getPendingGroups() async {
    try {
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('status', 'CREATED')
          .order('created_at', ascending: false);

      final groups = response.map((data) => GroupModel.fromMap(data)).toList();

      return Right(groups);
    } on PostgrestException catch (e) {
      Log.error("Get Pending Groups Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Pending Groups Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, GroupModel>> updateGroup({
    required GroupModel group,
  }) async {
    try {
      final updateData = group.toMap();
      updateData.remove('id');
      updateData.remove('created_at');

      Log.info("🔍 Updating group with ID: ${group.id}");
      Log.info("🔍 Update data: $updateData");

      // ✅ Pehle update karo WITHOUT select
      await supabaseClient
          .from('Group')
          .update(updateData)
          .eq('id', group.id ?? "");

      // ✅ Fir separately fetch karo
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('id', group.id ?? "")
          .single();

      Log.info("✅ Update Group Response: ${response.toString()}");
      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("❌ Update Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Update Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, GroupModel>> updateGroupStatus({
    required String id,
    required GroupStatus status,
    String? rejectionReason,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      };

      final response = await supabaseClient
          .from('Group')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      Log.info("Update Group Status Response: ${response.toString()}");

      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Group Status Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Group Status Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteGroup({required String id}) async {
    try {
      await supabaseClient.from('Group').delete().eq('id', id);

      Log.info("Delete Group Success for ID: $id");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, GroupModel?>> getGroupBySlug({
    required String slug,
  }) async {
    try {
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('slug', slug)
          .eq('active', true)
          .eq('isSuspended', false)
          .maybeSingle();

      if (response == null) {
        return const Right(null);
      }

      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Group by Slug Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Group by Slug Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  // Join group as member
  Future<Either<Failure, void>> joinGroup({
    required String userId,
    required String groupId,
  }) async {
    try {
      // Check if already a member
      final existingMember = await supabaseClient
          .from('Members')
          .select()
          .eq('userId', userId)
          .eq('groupId', groupId)
          .maybeSingle();

      if (existingMember != null) {
        return Left(Failure("Already a member of this group"));
      }

      // Add user as member (with subscription details if needed)
      await supabaseClient.from('Members').insert({
        'userId': userId,
        'groupId': groupId,
        'role': 'MEMBER',
        'isActive': true,
        'planType': 'LIFETIME', // Or get from payment
        'subscriptionStartDate': DateTime.now().toIso8601String(),
      });

      Log.info("✅ User $userId joined group $groupId");
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("❌ Join Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Join Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  // Check if user is already a member
  Future<Either<Failure, bool>> isMember({
    required String userId,
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Members')
          .select()
          .eq('userId', userId)
          .eq('groupId', groupId)
          .maybeSingle();

      return Right(response != null);
    } on PostgrestException catch (e) {
      Log.error("❌ Check Member Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Check Member Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<MemberModel>>> getGroupMembers({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Members')
          .select('*, Users(name, email, avatar)')
          .eq('groupId', groupId)
          .eq('isActive', true);

      final members = response
          .map((data) => MemberModel.fromMap(data))
          .toList();
      return Right(members);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
