import "package:amplify_api/amplify_api.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:demo_amplify/models/ModelProvider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo?> _allTodos = [];

  Future<void> getTodos() async {
    final todoRequest = ModelQueries.list(
      Todo.classType,
    );
    final todoResponse = await Amplify.API.query(request: todoRequest).response;

    if (todoResponse.hasErrors) {
      debugPrint(todoResponse.errors.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bir hata oluştur"),
        ),
      );
    } else {
      if (todoResponse.data != null) {
        setState(() {
          _allTodos = todoResponse.data!.items;
        });
      }
    }
  }

  Future<void> removeTodo(String todoId) async {
    final todoRemoveRequest = ModelMutations.deleteById(Todo.classType, todoId);
    final todoRemoveResponse =
        await Amplify.API.mutate(request: todoRemoveRequest).response;

    if (todoRemoveResponse.hasErrors) {
      debugPrint(todoRemoveResponse.errors.toString());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bir hata oluştur"),
        ),
      );
    } else {
      if (todoRemoveResponse.data != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${todoRemoveResponse.data?.name} silindi!"),
          ),
        );

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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bir hata oluştur"),
        ),
      );
    } else {
      if (todoUpdateResponse.data != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${todoUpdateResponse.data?.name} bitti!"),
          ),
        );

        await getTodos();
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getTodos();
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
                if (_allTodos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Hiç göreviniz yok"),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _allTodos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            _allTodos[index]!.name,
                            style: TextStyle(
                              decoration: _allTodos[index]!.isCompleted ?? true
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(_allTodos[index]!.description!),
                          trailing: SizedBox(
                            width: (_allTodos[index]!.isCompleted ?? true)
                                ? 96
                                : 48,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    (_allTodos[index]!.isCompleted ?? true)
                                        ? Icons.cancel
                                        : Icons.check,
                                  ),
                                  onPressed: () {
                                    if (_allTodos[index]!.isCompleted ?? true) {
                                      updateTodo(
                                        _allTodos[index]!,
                                        reverse: true,
                                      );
                                    } else {
                                      updateTodo(_allTodos[index]!);
                                    }
                                  },
                                ),
                                if (_allTodos[index]!.isCompleted ?? true)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      removeTodo(_allTodos[index]!.id);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Todo?>("allTodos", _allTodos));
  }
}
