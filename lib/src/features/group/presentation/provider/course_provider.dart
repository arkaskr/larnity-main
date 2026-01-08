import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/course_datasource.dart';
import 'package:larnity/src/features/group/data/models/course_model.dart';

final courseProvider =
    NotifierProvider.autoDispose<CourseNotifier, CourseState>(
      CourseNotifier.new,
    );

class CourseNotifier extends AutoDisposeNotifier<CourseState> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  CourseState build() {
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();

    ref.onDispose(() {
      nameController.dispose();
      descriptionController.dispose();
      priceController.dispose();
    });

    return CourseState(fetchState: AsyncState.initial);
  }

  Future<void> createCourse({
    required CourseModel course,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(courseDataSourceProvider);
    final supabase = ref.read(supabaseClientProvider);

    state = state.copyWith(createState: AsyncState.loading);

    String? thumbnailUrl;

    // Agar image selected hai toh pehle upload karo
    if (state.thumbnailImage != null) {
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'course-thumbnails/$fileName';

        await supabase.storage
            .from('images')
            .upload(path, state.thumbnailImage!);

        thumbnailUrl = supabase.storage.from('images').getPublicUrl(path);
      } catch (e) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: 'Image upload failed',
        );
        failureCallBack?.call('Image upload failed');
        return;
      }
    }

    // Ab course create karo with thumbnail URL
    final updatedCourse = course.copyWith(thumbnail: thumbnailUrl);
    final response = await dataSource.createCourse(course: updatedCourse);

    response.fold(
      (failure) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (createdCourse) {
        final updatedCourses = <CourseModel>[
          ...state.courses ?? [],
          createdCourse,
        ];
        state = state.copyWith(
          createState: AsyncState.success,
          course: createdCourse,
          courses: updatedCourses,
          thumbnailImage: null, // Clear image after success
        );

        // Clear form
        nameController.clear();
        descriptionController.clear();
        priceController.clear();

        successCallBack?.call();
      },
    );
  }

  Future<void> getCoursesByGroup({required String groupId}) async {
    final dataSource = ref.read(courseDataSourceProvider);

    state = state.copyWith(fetchState: AsyncState.loading);
    final response = await dataSource.getCoursesByGroup(groupId: groupId);

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (courses) => state = state.copyWith(
        fetchState: AsyncState.success,
        courses: courses,
      ),
    );
  }

  Future<void> fetchCourseById(String courseId) async {
    final dataSource = ref.read(courseDataSourceProvider);

    state = state.copyWith(fetchState: AsyncState.loading);
    final response = await dataSource.getCourse(id: courseId);

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (course) => state = state.copyWith(
        fetchState: AsyncState.success,
        course: course,
      ),
    );
  }

  void setPrivacy(CoursePrivacy privacy) {
    state = state.copyWith(selectedPrivacy: privacy);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    state = CourseState(fetchState: AsyncState.initial);
  }

  Future<void> pickThumbnail() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
    );

    if (image != null) {
      final file = File(image.path);
      final size = await file.length();

      if (size > 5 * 1024 * 1024) {
        // 5MB se bada hai - error dikha do
        return;
      }

      state = state.copyWith(thumbnailImage: file);
    }
  }

  void removeThumbnail() {
    state = state.copyWith(thumbnailImage: null);
  }
}

class CourseState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final String? error;
  final CourseModel? course;
  final List<CourseModel>? courses;
  final CoursePrivacy? selectedPrivacy;
  final File? thumbnailImage;

  CourseState({
    this.fetchState,
    this.createState,
    this.error,
    this.course,
    this.courses,
    this.selectedPrivacy,
    this.thumbnailImage,
  });

  CourseState copyWith({
    File? thumbnailImage,
    AsyncState? fetchState,
    AsyncState? createState,
    String? error,
    CourseModel? course,
    List<CourseModel>? courses,
    CoursePrivacy? selectedPrivacy,
  }) {
    return CourseState(
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
      fetchState: fetchState ?? this.fetchState,
      createState: createState ?? this.createState,
      error: error ?? this.error,
      course: course ?? this.course,
      courses: courses ?? this.courses,
      selectedPrivacy: selectedPrivacy ?? this.selectedPrivacy,
    );
  }

  bool get isLoading => fetchState == AsyncState.loading;
  bool get isCreating => createState == AsyncState.loading;
  bool get isSuccess => fetchState == AsyncState.success;
  bool get isFailure => fetchState == AsyncState.failure;

  List<CourseModel> get publicCourses =>
      courses?.where((c) => c.isPublic).toList() ?? [];

  List<CourseModel> get paidCourses =>
      courses?.where((c) => c.isPaid).toList() ?? [];
}
