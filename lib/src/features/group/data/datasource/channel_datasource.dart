import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';

class ChannelDataSource {
  final supabase;
  ChannelDataSource(this.supabase);

  Future<String?> getGeneralChannelId(String groupId) async {
    try {
      final response = await supabase
          .from('Channel')
          .select('id')
          .eq('groupId', groupId)
          .eq('name', 'general')
          .single();
      return response['id'];
    } catch (e) {
      return null;
    }
  }
}

final channelDataSourceProvider = Provider((ref) {
  return ChannelDataSource(ref.read(supabaseClientProvider));
});
