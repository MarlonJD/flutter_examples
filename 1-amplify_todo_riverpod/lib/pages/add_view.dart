import "package:amplify_todo_riverpod/pages/controller/snackbar_controller.dart";
import "package:amplify_todo_riverpod/pages/controller/todo_controller.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          SliverAppBar.medium(
            title: const Text(
              "Add",
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 16,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Lütfen formu doldurun"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer(
                    builder: (_, WidgetRef ref, __) {
                      snackbarDisplayer(context, ref);
                      final todoState = ref.watch(todoNotifierProvider);
                      return TextFormField(
                        controller: todoState.nameController,
                        decoration: const InputDecoration(
                          hintText: "Görevi giriniz",
                          label: Text("Görev"),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer(
                    builder: (_, WidgetRef ref, __) {
                      final todoState = ref.watch(todoNotifierProvider);
                      return TextFormField(
                        controller: todoState.descriptionController,
                        decoration: const InputDecoration(
                          hintText: "Görev ayrıntısını giriniz",
                          label: Text("Görev ayrıntısı"),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer(
                    builder: (_, WidgetRef ref, __) {
                      final todoNotifier =
                          ref.read(todoNotifierProvider.notifier);
                      return FilledButton(
                        onPressed: () async {
                          await todoNotifier.createTodo();
                          context.pop();
                        },
                        child: const Text("Kaydet"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
