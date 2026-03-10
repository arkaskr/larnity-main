import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChannelDataSource {
  final supabase;
  ChannelDataSource(this.supabase);

  Future<String?> getGeneralChannelId(String groupId) async {
    try {
      // ✅ CRITICAL FIX: Use maybeSingle() + limit(1) to handle multiple channels
      final response = await supabase
          .from('Channel')
          .select('id')
          .eq('groupId', groupId)
          .eq('name', 'general')
          .limit(1) // ← ADDED: Only fetch first match
          .maybeSingle(); // ← CHANGED: No exception if not found

      // ✅ If channel exists, return it
      if (response != null) {
        Log.info(
          "✅ Found existing general channel: ${response['id']} for group $groupId",
        );
        return response['id'];
      }

      // ✅ Channel doesn't exist, create it ONCE
      Log.info("📝 Creating general channel for group $groupId");
      final insertResponse = await supabase
          .from('Channel')
          .insert({
            'groupId': groupId,
            'name': 'general',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      Log.info("✅ Created general channel: ${insertResponse['id']}");
      return insertResponse['id'];
    } on PostgrestException catch (e) {
      // ✅ Handle race condition (duplicate key)
      if (e.code == '23505') {
        Log.info("⚠️ Duplicate channel detected, fetching existing");
        final retryResponse = await supabase
            .from('Channel')
            .select('id')
            .eq('groupId', groupId)
            .eq('name', 'general')
            .limit(1) // ← ADDED: Safety limit
            .maybeSingle();
        return retryResponse?['id'];
      }
      Log.error("❌ Failed to get/create channel: ${e.message}");
      return null;
    } catch (e) {
      Log.error("❌ Unexpected error in getGeneralChannelId: $e");
      return null;
    }
  }
}

final channelDataSourceProvider = Provider((ref) {
  return ChannelDataSource(ref.read(supabaseClientProvider));
});
