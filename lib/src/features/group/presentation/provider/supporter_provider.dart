import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/supporter_datasource.dart';
import 'package:larnity/src/features/group/data/models/supporter_model.dart';

final supporterProvider = ChangeNotifierProvider<SupporterProvider>((ref) {
  return SupporterProvider(ref.watch(supporterDataSourceProvider));
});

class SupporterProvider extends ChangeNotifier {
  final SupporterDataSource _supporterDataSource;

  SupporterProvider(this._supporterDataSource);

  List<SupporterModel> _supporters = [];
  List<SupporterModel> get supporters => _supporters;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Create Supporter
  Future<bool> createSupporter(SupporterModel supporter) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _supporterDataSource.createSupporter(
        supporter: supporter,
      );

      return result.fold(
        (failure) {
          Log.error("Create Supporter Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (createdSupporter) async {
          Log.info("Supporter created successfully: ${createdSupporter.id}");
          await fetchSupporters(supporter.groupId);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Fetch Supporters by Group
  Future<void> fetchSupporters(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _supporterDataSource.getSupportersByGroup(
        groupId: groupId,
      );

      result.fold(
        (failure) {
          Log.error("Fetch Supporters Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (supporters) {
          _supporters = supporters;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Update Supporter
  Future<bool> updateSupporter(SupporterModel supporter) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _supporterDataSource.updateSupporter(
        supporter: supporter,
      );

      return result.fold(
        (failure) {
          Log.error("Update Supporter Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (updatedSupporter) async {
          Log.info("Supporter updated successfully: ${updatedSupporter.id}");
          await fetchSupporters(supporter.groupId);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete Supporter
  Future<bool> deleteSupporter(String supporterId, String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _supporterDataSource.deleteSupporter(
        id: supporterId,
      );

      return result.fold(
        (failure) {
          Log.error("Delete Supporter Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          Log.info("Supporter deleted successfully");
          await fetchSupporters(groupId);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
