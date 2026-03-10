import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/data/models/group_tab.dart';
import 'package:larnity/src/features/group/data/models/message_model.dart';
import 'dart:io';
import 'package:larnity/src/features/group/data/models/challenge_model.dart';
import 'package:larnity/src/features/group/data/models/paymintro_creds_model.dart';
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

      final createdGroup = GroupModel.fromMap(response);

      // Automatically add the creator as ADMIN to Members table
      if (createdGroup.id != null && group.userId != null) {
        try {
          final groupId = createdGroup.id!;
          final userId = group.userId!;

          // Check if member already exists (in case of retry or duplicate)
          final existingMember = await supabaseClient
              .from('Members')
              .select()
              .eq('userId', userId)
              .eq('groupId', groupId)
              .maybeSingle();

          if (existingMember == null) {
            await supabaseClient.from('Members').insert({
              'userId': userId,
              'groupId': groupId,
              'role': 'ADMIN',
              'isActive': true,
              'planType': 'LIFETIME',
              'subscriptionStartDate': DateTime.now().toIso8601String(),
            });
            Log.info(
              "✅ Added group creator $userId as ADMIN to group $groupId",
            );
          } else {
            // Ensure existing member is active and has ADMIN role
            final isActive = existingMember['isActive'] as bool? ?? false;
            final role = existingMember['role'] as String? ?? 'MEMBER';

            if (!isActive || role != 'ADMIN') {
              await supabaseClient
                  .from('Members')
                  .update({'isActive': true, 'role': 'ADMIN'})
                  .eq('userId', userId)
                  .eq('groupId', groupId);
              Log.info(
                "✅ Updated creator $userId to ADMIN and active in group $groupId",
              );
            } else {
              Log.info(
                "ℹ️ Creator $userId already exists as active ADMIN in group $groupId",
              );
            }
          }
        } on PostgrestException catch (e) {
          // Log detailed error for debugging
          Log.error("⚠️ Failed to add creator as member: ${e.message}");
          Log.error("⚠️ Error code: ${e.code}, Details: ${e.details}");
          // Don't fail group creation, but log the issue
        } catch (e) {
          Log.error(
            "⚠️ Unexpected error adding creator as member: ${e.toString()}",
          );
        }
      }

      return Right(createdGroup);
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
          .select('*, GroupTabSettings(*)')
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
          .select('*, GroupTabSettings(*)')
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
      // ✅ Check authentication first
      final currentUser = supabaseClient.auth.currentUser;
      Log.info("🔍 Current authenticated user: ${currentUser?.id}");
      Log.info("🔍 Group userId: ${group.userId}");
      
      if (currentUser == null) {
        Log.error("❌ No authenticated user found!");
        return Left(Failure("User not authenticated"));
      }

      final updateData = group.toMap();
      updateData.remove('id');
      updateData.remove('created_at');
      updateData.remove('tabSettings'); // Remove tabSettings as it's in a separate table

      Log.info("🔍 Updating group with ID: ${group.id}");
      Log.info("🔍 Update data: $updateData");

      // ✅ First, do the update
      final response = await supabaseClient
          .from('Group')
          .update(updateData)
          .eq('id', group.id!)
          .select()
          .single();

      // Update tab settings if present
      if (group.tabSettings != null) {
        for (final entry in group.tabSettings!.entries) {
          final tab = GroupTab.fromKey(entry.key);
          if (tab != null) {
            await supabaseClient.from('GroupTabSettings').upsert(
              {
                'groupId': group.id,
                'tabId': tab.id,
                'isVisible': entry.value,
                'updated_at': DateTime.now().toIso8601String(),
              },
              onConflict: 'groupId, tabId',
            );
          }
        }
      }

      Log.info("✅ Update completed, now fetching updated data...");

      // ✅ Then fetch the updated group
      final updatedGroupResponse = await supabaseClient
          .from('Group')
          .select('*, GroupTabSettings(*)')
          .eq('id', group.id ?? "")
          .single();

      Log.info("✅ Fetched Group Response: ${updatedGroupResponse.toString()}");
      return Right(GroupModel.fromMap(updatedGroupResponse));
    } on PostgrestException catch (e) {
      Log.error("❌ Update Group Error: ${e.message}");
      Log.error("❌ Error details: ${e.details}");
      Log.error("❌ Error hint: ${e.hint}");
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
      // Fetch members with User details from profiles
      final response = await supabaseClient
          .from('Members')
          .select('*, profiles(*)')
          .eq('groupId', groupId)
          .eq('isActive', true);

      final members = (response as List)
          .map((data) => MemberModel.fromMap(data))
          .toList();

      Log.info("✅ Fetched ${members.length} members for group $groupId");
      return Right(members);
    } on PostgrestException catch (e) {
      Log.error("❌ Get Group Members Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Get Group Members Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  // Create group invitation
  Future<Either<Failure, String>> createInvitation({
    required String groupId,
    required String email,
    String? name,
    required String planType,
    int expirationHours = 48,
    bool sendEmail = true,
  }) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return Left(Failure("User not authenticated"));
      }

      // Generate unique token
      final token = '${DateTime.now().millisecondsSinceEpoch}-${email.hashCode}';
      final expiresAt = DateTime.now().add(Duration(hours: expirationHours));

      // 1. Save to Database
      await supabaseClient.from('GroupInvitation').insert({
        'email': email,
        'name': name,
        'token': token,
        'planType': planType,
        'status': 'PENDING',
        'groupId': groupId,
        'inviterId': currentUser.id,
        'expiresAt': expiresAt.toIso8601String(),
      });

      Log.info("✅ Invitation created in DB for $email");

      // 2. Fetch Group Details for Email
      final groupResponse = await supabaseClient
          .from('Group')
          .select('name')
          .eq('id', groupId)
          .single();
      
      final groupName = groupResponse['name'] as String;

      // 3. Send Email via Edge Function
      // TODO: Replace with your actual deep link or web link
      final inviteLink = "https://larnity.com/invite?token=$token"; 
      
      if (sendEmail) {
        try {
          await supabaseClient.functions.invoke(
            'send-group-invitation',
            body: {
              'email': email,
              'groupName': groupName,
              'inviterName': currentUser.userMetadata?['name'] ?? 'A member',
              'inviteLink': inviteLink,
            },
          );
          Log.info("✅ Invitation email sent to $email");
        } catch (e) {
          Log.error("⚠️ Failed to send invitation email: $e");
          // We don't fail the whole operation if email fails, as DB record is created
        }
      }

      return Right(inviteLink);
    } on PostgrestException catch (e) {
      Log.error("❌ Create Invitation Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Create Invitation Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  // Update Google Sheet settings
  Future<Either<Failure, GroupModel>> updateGoogleSheetSettings({
    required String groupId,
    String? googleSheetId,
    required bool enableSync,
  }) async {
    try {
      final updateData = {
        'googleSheetId': googleSheetId,
        'enableGoogleSheetSync': enableSync,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabaseClient
          .from('Group')
          .update(updateData)
          .eq('id', groupId);

      Log.info("✅ Google Sheet settings updated");

      // Fetch updated group
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('id', groupId)
          .single();

      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("❌ Update Google Sheet Settings Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Update Google Sheet Settings Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
  Future<Either<Failure, void>> createChallenge({
    required ChallengeModel challenge,
  }) async {
    try {
      await supabaseClient.from('Challenges').insert(challenge.toMap());
      Log.info("✅ Challenge created: ${challenge.title}");
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("❌ Create Challenge Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Create Challenge Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, String>> uploadChallengeThumbnail(File file) async {
    try {
      final fileName =
          'image-${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      await supabaseClient.storage.from('images').upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return Right(fileName);
    } on StorageException catch (e) {
      Log.error("❌ Upload Thumbnail Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Upload Thumbnail Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<ChallengeModel>>> getChallengesByGroupId({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Challenges')
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final challenges = (response as List)
          .map((e) => ChallengeModel.fromMap(e))
          .toList();

      Log.info("✅ Fetched ${challenges.length} challenges for group $groupId");
      return Right(challenges);
    } on PostgrestException catch (e) {
      Log.error("❌ Get Challenges Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Get Challenges Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> savePaymintroCreds(
      PaymintroCredsModel creds) async {
    try {
      await supabaseClient.from('AdminPaymintroCreds').insert(creds.toMap());
      Log.info("✅ Paymintro Credentials saved successfully");
      return const Right(true);
    } on PostgrestException catch (e) {
      Log.error("❌ Save Paymintro Creds Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("❌ Save Paymintro Creds Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}

