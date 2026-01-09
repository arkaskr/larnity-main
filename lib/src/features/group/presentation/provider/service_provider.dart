import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/product_datasource.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';

final serviceProvider = ChangeNotifierProvider<ServiceProvider>((ref) {
  return ServiceProvider(ref.watch(productDataSourceProvider));
});

class ServiceProvider extends ChangeNotifier {
  final ProductDataSource _productDataSource;

  ServiceProvider(this._productDataSource);

  List<ProductModel> _services = [];
  List<ProductModel> get services => _services;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Create Service
  Future<bool> createService(ProductModel service) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _productDataSource.createProduct(product: service);

      return result.fold(
        (failure) {
          Log.error("Create Service Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (createdService) async {
          Log.info("Service created successfully: ${createdService.id}");
          await fetchServices(service.groupId);
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

  /// Fetch Services by Group (filter by type = SERVICE)
  Future<void> fetchServices(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _productDataSource.getProductsByGroup(
        groupId: groupId,
      );

      result.fold(
        (failure) {
          Log.error("Fetch Services Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (products) {
          // Filter only services
          _services = products
              .where((item) => item.type == ProductType.service)
              .toList();
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

  /// Update Service
  Future<bool> updateService(ProductModel service) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _productDataSource.updateProduct(product: service);

      return result.fold(
        (failure) {
          Log.error("Update Service Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (updatedService) async {
          Log.info("Service updated successfully: ${updatedService.id}");
          await fetchServices(service.groupId);
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

  /// Delete Service
  Future<bool> deleteService(String serviceId, String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _productDataSource.deleteProduct(id: serviceId);

      return result.fold(
        (failure) {
          Log.error("Delete Service Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          Log.info("Service deleted successfully");
          await fetchServices(groupId);
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
