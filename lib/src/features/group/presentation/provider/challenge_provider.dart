import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/group_datasource.dart';
import 'package:larnity/src/features/group/data/models/challenge_model.dart';
import 'package:larnity/src/core/ui/widgets/toast.dart';

final challengeProvider = ChangeNotifierProvider((ref) {
  return ChallengeProvider(ref.read(groupDataSourceProvider));
});

class ChallengeProvider extends ChangeNotifier {
  final GroupDataSource _dataSource;

  ChallengeProvider(this._dataSource);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ChallengeModel> _challenges = [];
  List<ChallengeModel> get challenges => _challenges;

  Future<void> fetchChallenges(String groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _dataSource.getChallengesByGroupId(groupId: groupId);
      result.fold(
        (l) {
          Log.error("Failed to fetch challenges: ${l.message}");
          AppToast.show("Failed to fetch challenges: ${l.message}",
              isError: true);
        },
        (r) {
          _challenges = r;
        },
      );
    } catch (e) {
      Log.error("Exception fetching challenges: $e");
      AppToast.show("Exception fetching challenges: $e", isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createChallenge(
      ChallengeModel challenge, File? thumbnailFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? thumbnailPath;
      if (thumbnailFile != null) {
        final uploadRes =
            await _dataSource.uploadChallengeThumbnail(thumbnailFile);
        
        bool uploadFailed = false;
        uploadRes.fold(
          (l) {
            Log.error("Failed to upload thumbnail: ${l.message}");
            AppToast.show("Failed to upload thumbnail: ${l.message}", isError: true);
            uploadFailed = true;
          },
          (r) => thumbnailPath = r,
        );
        
        if (uploadFailed) {
            _isLoading = false;
            notifyListeners();
            return false;
        }
      }

      final challengeToCreate = challenge.copyWith(thumbnail: thumbnailPath);

      final result =
          await _dataSource.createChallenge(challenge: challengeToCreate);

      return result.fold(
        (l) {
          Log.error("Failed to create challenge: ${l.message}");
          AppToast.show("Failed to create challenge: ${l.message}", isError: true);
          return false;
        },
        (r) {
          Log.info("Challenge created successfully");
          AppToast.show("Challenge created successfully");
          // Refresh list
          fetchChallenges(challenge.groupId);
          return true;
        },
      );
    } catch (e) {
      Log.error("Exception creating challenge: $e");
      AppToast.show("Exception creating challenge: $e", isError: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
