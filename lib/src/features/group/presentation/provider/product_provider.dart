import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/product_datasource.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';

final productProvider = ChangeNotifierProvider<ProductProvider>((ref) {
  return ProductProvider(ref.watch(productDataSourceProvider));
});

class ProductProvider extends ChangeNotifier {
  final ProductDataSource _productDataSource;

  ProductProvider(this._productDataSource);

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Create Product
  Future<bool> createProduct(ProductModel product) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _productDataSource.createProduct(product: product);

      return result.fold(
        (failure) {
          Log.error("Create Product Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (createdProduct) async {
          Log.info("Product created successfully: ${createdProduct.id}");
          await fetchProducts(product.groupId);
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

  /// Fetch Products by Group
  Future<void> fetchProducts(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _productDataSource.getProductsByGroup(
        groupId: groupId,
      );

      result.fold(
        (failure) {
          Log.error("Fetch Products Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (products) {
          _products = products;
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

  /// Update Product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _productDataSource.updateProduct(product: product);

      return result.fold(
        (failure) {
          Log.error("Update Product Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (updatedProduct) async {
          Log.info("Product updated successfully: ${updatedProduct.id}");
          await fetchProducts(product.groupId);
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

  /// Delete Product
  Future<bool> deleteProduct(String productId, String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _productDataSource.deleteProduct(id: productId);

      return result.fold(
        (failure) {
          Log.error("Delete Product Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          Log.info("Product deleted successfully");
          await fetchProducts(groupId);
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
