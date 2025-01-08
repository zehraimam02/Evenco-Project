import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evenco_app/models/task_model.dart';

// Events
abstract class TasksEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TasksEvent {
  final String eventId;
  LoadTasks(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class AddTask extends TasksEvent {
  final TaskModel task;
  AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TasksEvent {
  final TaskModel task;
  UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TasksEvent {
  final String taskId;
  DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskCompletion extends TasksEvent {
  final String taskId;
  ToggleTaskCompletion(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// States
abstract class TasksState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskModel> tasks;
  TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TasksError extends TasksState {
  final String message;
  TasksError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TasksBloc() : super(TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('eventId', isEqualTo: event.eventId)
          .get();

      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      await _firestore.collection('tasks').add(event.task.toJson());
      add(LoadTasks(event.task.eventId));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(event.task.id)
          .update(event.task.toJson());
      add(LoadTasks(event.task.eventId));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      final currentState = state;
      if (currentState is TasksLoaded) {
        final taskToDelete = currentState.tasks
            .firstWhere((task) => task.id == event.taskId);
        await _firestore.collection('tasks').doc(event.taskId).delete();
        add(LoadTasks(taskToDelete.eventId));
      }
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
      ToggleTaskCompletion event, Emitter<TasksState> emit) async {
    try {
      final currentState = state;
      if (currentState is TasksLoaded) {
        final task = currentState.tasks.firstWhere((t) => t.id == event.taskId);
        final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
        add(UpdateTask(updatedTask));
      }
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
