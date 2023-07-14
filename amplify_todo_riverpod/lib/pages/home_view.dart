import "package:amplify_todo_riverpod/pages/controller/snackbar_controller.dart";
import "package:amplify_todo_riverpod/pages/controller/todo_controller.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer(
                    builder: (context, WidgetRef ref, _) {
                      snackbarDisplayer(context, ref);
                      final todoState = ref.watch(todoNotifierProvider);
                      final todoNotifier =
                          ref.read(todoNotifierProvider.notifier);
                      if (todoState.allTodos.isEmpty &&
                          todoState.status != Status.loading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Hiç göreviniz yok"),
                        );
                      } else if (todoState.status == Status.loading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (todoState.status == Status.fail) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child:
                              Text("Bir hatadan dolayı görevler getirilemedi."),
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: todoState.allTodos.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(
                                  todoState.allTodos[index]!.name,
                                  style: TextStyle(
                                    decoration: todoState
                                                .allTodos[index]!.isCompleted ??
                                            true
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  todoState.allTodos[index]!.description!,
                                ),
                                trailing: SizedBox(
                                  width:
                                      (todoState.allTodos[index]!.isCompleted ??
                                              true)
                                          ? 96
                                          : 48,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          (todoState.allTodos[index]!
                                                      .isCompleted ??
                                                  true)
                                              ? Icons.cancel
                                              : Icons.check,
                                        ),
                                        onPressed: () {
                                          if (todoState.allTodos[index]!
                                                  .isCompleted ??
                                              true) {
                                            todoNotifier.updateTodo(
                                              todoState.allTodos[index]!,
                                              reverse: true,
                                            );
                                          } else {
                                            todoNotifier.updateTodo(
                                              todoState.allTodos[index]!,
                                            );
                                          }
                                        },
                                      ),
                                      if (todoState
                                              .allTodos[index]!.isCompleted ??
                                          true)
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            todoNotifier.removeTodo(
                                              todoState.allTodos[index]!.id,
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go("/add");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
