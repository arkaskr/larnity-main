import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/datasource/job_datasource.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';

final jobProvider = ChangeNotifierProvider<JobProvider>((ref) {
  return JobProvider(ref.watch(jobDataSourceProvider));
});

class JobProvider extends ChangeNotifier {
  final JobDataSource _jobDataSource;

  JobProvider(this._jobDataSource);

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Create Job
  Future<bool> createJob(JobModel job) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _jobDataSource.createJob(job: job);

      return result.fold(
        (failure) {
          Log.error("Create Job Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (createdJob) async {
          Log.info("Job created successfully: ${createdJob.id}");
          await fetchJobs(job.groupId);
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

  /// Fetch Jobs by Group
  Future<void> fetchJobs(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _jobDataSource.getJobsByGroup(groupId: groupId);

      result.fold(
        (failure) {
          Log.error("Fetch Jobs Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (jobs) {
          _jobs = jobs;
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

  /// Update Job
  Future<bool> updateJob(JobModel job) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _jobDataSource.updateJob(job: job);

      return result.fold(
        (failure) {
          Log.error("Update Job Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (updatedJob) async {
          Log.info("Job updated successfully: ${updatedJob.id}");
          await fetchJobs(job.groupId);
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

  /// Delete Job
  Future<bool> deleteJob(String jobId, String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _jobDataSource.deleteJob(id: jobId);

      return result.fold(
        (failure) {
          Log.error("Delete Job Failed: ${failure.message}");
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (_) async {
          Log.info("Job deleted successfully");
          await fetchJobs(groupId);
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
