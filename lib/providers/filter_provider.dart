import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

enum FilterType { all, pending, inProgress, completed }

final filterTypeProvider = StateProvider<FilterType>((ref) => FilterType.all);

final categoryFilterProvider = StateProvider<TaskCategory?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');
