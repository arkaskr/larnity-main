import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/class_schedule_datasource.dart';
import 'package:larnity/src/features/group/data/models/class_schedule_model.dart';

final classScheduleProvider = ChangeNotifierProvider<ClassScheduleProvider>((
  ref,
) {
  return ClassScheduleProvider(ref.watch(classScheduleDataSourceProvider));
});

class ClassScheduleProvider extends ChangeNotifier {
  final ClassScheduleDataSource _dataSource;

  ClassScheduleProvider(this._dataSource);

  List<ClassScheduleModel> _classes = [];
  List<ClassScheduleModel> get classes => _classes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> createClass(ClassScheduleModel classSchedule) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _dataSource.createClass(
        classSchedule: classSchedule,
      );

      return result.fold(
        (failure) {
          Log.error("Create Class Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (createdClass) async {
          Log.info("Class created: ${createdClass.id}");
          await fetchClasses(classSchedule.groupId);
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

  Future<void> fetchClasses(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _dataSource.getClassesByGroup(groupId: groupId);

      result.fold(
        (failure) {
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (classes) {
          _classes = classes;
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

  Future<bool> deleteClass(String classId, String groupId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _dataSource.deleteClass(id: classId);

      return result.fold(
        (failure) {
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          await fetchClasses(groupId);
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
}
