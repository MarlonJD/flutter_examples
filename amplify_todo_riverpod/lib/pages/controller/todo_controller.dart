// ignore_for_file: public_member_api_docs, sort_constructors_first
import "package:amplify_api/amplify_api.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:amplify_todo_riverpod/models/ModelProvider.dart";
import "package:amplify_todo_riverpod/pages/controller/snackbar_controller.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

enum Status { loading, success, fail }

class TodoState {
  final List<Todo?> allTodos;
  final Status? status;
  final String? error;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  TodoState({
    required this.allTodos,
    this.status,
    this.error,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  String toString() {
    return "TodoState(allTodos: $allTodos, status: $status, error: $error, nameController: $nameController, descriptionController: $descriptionController)";
  }

  TodoState copyWith({
    List<Todo?>? allTodos,
    Status? status,
    String? error,
    TextEditingController? nameController,
    TextEditingController? descriptionController,
  }) {
    return TodoState(
      allTodos: allTodos ?? this.allTodos,
      status: status ?? this.status,
      error: error ?? this.error,
      nameController: nameController ?? this.nameController,
      descriptionController:
          descriptionController ?? this.descriptionController,
    );
  }
}

final todoNotifierProvider =
    StateNotifierProvider<TodoNotifier, TodoState>((final ref) {
  return TodoNotifier(ref.watch(snackbarControllerProvider.notifier));
});

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(this._snackbarController)
      : super(
          TodoState(
            allTodos: [],
            nameController: TextEditingController(),
            descriptionController: TextEditingController(),
          ),
        ) {
    debugPrint("TodoNotifier initialized");
    getTodos();
  }

  final SnackbarController _snackbarController;

  Future<void> getTodos() async {
    debugPrint("getTodos called");
    state = state.copyWith(status: Status.loading);
    final todoRequest = ModelQueries.list(
      Todo.classType,
    );
    final todoResponse = await Amplify.API.query(request: todoRequest).response;

    if (todoResponse.hasErrors) {
      debugPrint(todoResponse.errors.toString());
      _snackbarController.setSnackbarMessage("Bir hata oluştu");
      state = state.copyWith(status: Status.fail);
    } else {
      if (todoResponse.data != null) {
        state = state.copyWith(
          allTodos: todoResponse.data!.items,
          status: Status.success,
        );
      }
    }
  }

  Future<void> removeTodo(String todoId) async {
    final todoRemoveRequest = ModelMutations.deleteById(Todo.classType, todoId);
    final todoRemoveResponse =
        await Amplify.API.mutate(request: todoRemoveRequest).response;

    if (todoRemoveResponse.hasErrors) {
      debugPrint(todoRemoveResponse.errors.toString());
      _snackbarController.setSnackbarMessage("Bir hata oluştu");
    } else {
      if (todoRemoveResponse.data != null) {
        _snackbarController
            .setSnackbarMessage("${todoRemoveResponse.data?.name} silindi!");
        await getTodos();
      }
    }
  }

  Future<void> updateTodo(Todo todo, {bool? reverse}) async {
    final todoUpdateRequest = ModelMutations.update(
      todo.copyWith(isCompleted: (reverse == true) ? false : true),
    );
    final todoUpdateResponse =
        await Amplify.API.mutate(request: todoUpdateRequest).response;

    if (todoUpdateResponse.hasErrors) {
      debugPrint(todoUpdateResponse.errors.toString());
      _snackbarController.setSnackbarMessage("Bir hata oluştu");
    } else {
      if (todoUpdateResponse.data != null) {
        _snackbarController
            .setSnackbarMessage("${todoUpdateResponse.data?.name} bitti!");

        await getTodos();
      }
    }
  }

  Future<void> createTodo() async {
    final todoRequest = ModelMutations.create(
      Todo(
        name: state.nameController.text.trim(),
        description: state.descriptionController.text.trim(),
        isCompleted: false,
      ),
    );

    final todoResponse =
        await Amplify.API.mutate(request: todoRequest).response;

    if (todoResponse.hasErrors) {
      debugPrint("Error: ${todoResponse.errors.toString()}");
      _snackbarController.setSnackbarMessage("Bir hata oluştu");
    } else {
      _snackbarController
          .setSnackbarMessage("${todoResponse.data?.name} oluşturuldu.");

      // Dispose TextEditingControllers
      state = state.copyWith(
        nameController: TextEditingController(),
        descriptionController: TextEditingController(),
      );
      await getTodos();
    }
  }
}
