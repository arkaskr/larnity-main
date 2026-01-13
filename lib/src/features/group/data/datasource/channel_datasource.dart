import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChannelDataSource {
  final supabase;
  ChannelDataSource(this.supabase);

  Future<String?> getGeneralChannelId(String groupId) async {
    try {
      // Try to fetch existing 'general' channel
      final response = await supabase
          .from('Channel')
          .select('id')
          .eq('groupId', groupId)
          .eq('name', 'general')
          .single();
      return response['id'];
    } catch (e) {
      // Channel doesn't exist, create it
      try {
        final insertResponse = await supabase
            .from('Channel')
            .insert({
              'groupId': groupId,
              'name': 'general',
              'created_at': DateTime.now().toIso8601String(),
            })
            .select('id')
            .single();
        
        Log.info("✅ Created general channel for group $groupId");
        return insertResponse['id'];
      } on PostgrestException catch (e) {
        // Handle unique constraint conflict - channel was created by another request
        if (e.code == '23505' || e.message.contains('unique') || e.message.contains('duplicate')) {
          Log.info("⚠️ Channel creation conflict, fetching existing channel");
          // Retry fetch in case another request created it
          try {
            final retryResponse = await supabase
                .from('Channel')
                .select('id')
                .eq('groupId', groupId)
                .eq('name', 'general')
                .single();
            return retryResponse['id'];
          } catch (retryError) {
            Log.error("❌ Failed to fetch channel after conflict: $retryError");
            return null;
          }
        } else {
          Log.error("❌ Failed to create general channel: ${e.message}");
          return null;
        }
      } catch (e) {
        Log.error("❌ Unexpected error creating general channel: $e");
        return null;
      }
    }
  }
}

final channelDataSourceProvider = Provider((ref) {
  return ChannelDataSource(ref.read(supabaseClientProvider));
});
