import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/resource_datasource.dart';
import 'package:larnity/src/features/group/data/models/resource_model.dart';

final resourceProvider = ChangeNotifierProvider<ResourceProvider>((ref) {
  return ResourceProvider(ref.watch(resourceDataSourceProvider));
});

class ResourceProvider extends ChangeNotifier {
  final ResourceDataSource _resourceDataSource;

  ResourceProvider(this._resourceDataSource);

  List<ResourceModel> _resources = [];
  List<ResourceModel> get resources => _resources;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Create Resource
  Future<bool> createResource(ResourceModel resource) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _resourceDataSource.createResource(
        resource: resource,
      );

      return result.fold(
        (failure) {
          Log.error("Create Resource Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (createdResource) async {
          Log.info("Resource created successfully: ${createdResource.id}");
          await fetchResources(resource.groupId);
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

  /// Fetch Resources by Group
  Future<void> fetchResources(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _resourceDataSource.getResourcesByGroup(
        groupId: groupId,
      );

      result.fold(
        (failure) {
          Log.error("Fetch Resources Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (resources) {
          _resources = resources;
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

  /// Update Resource
  Future<bool> updateResource(ResourceModel resource) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _resourceDataSource.updateResource(
        resource: resource,
      );

      return result.fold(
        (failure) {
          Log.error("Update Resource Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (updatedResource) async {
          Log.info("Resource updated successfully: ${updatedResource.id}");
          await fetchResources(resource.groupId);
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

  /// Delete Resource
  Future<bool> deleteResource(String resourceId, String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _resourceDataSource.deleteResource(id: resourceId);

      return result.fold(
        (failure) {
          Log.error("Delete Resource Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          Log.info("Resource deleted successfully");
          await fetchResources(groupId);
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
