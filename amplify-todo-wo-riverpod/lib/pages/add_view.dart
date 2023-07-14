import "package:amplify_api/amplify_api.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:demo_amplify/models/ModelProvider.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> createTodo() async {
    final todoRequest = ModelMutations.create(
      Todo(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isCompleted: false,
      ),
    );

    final todoResponse =
        await Amplify.API.mutate(request: todoRequest).response;

    if (todoResponse.hasErrors) {
      debugPrint("Error: ${todoResponse.errors.toString()}");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bir hata oluştu"),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${todoResponse.data?.name} oluşturuldu."),
        ),
      );

      context.pop();
    }
  }

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
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Görevi giriniz",
                      label: Text("Görev"),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Görev ayrıntısını giriniz",
                      label: Text("Görev ayrıntısı"),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton(
                    onPressed: createTodo,
                    child: const Text("Kaydet"),
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
