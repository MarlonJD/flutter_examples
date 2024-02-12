// ignore_for_file: public_member_api_docs

import "package:example_project/controllers/blog_controller.dart";
import "package:example_project/models/Blog.dart";
import "package:example_project/models/ModelProvider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class BlogSettingsView extends ConsumerStatefulWidget {
  const BlogSettingsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BlogSettingsViewState();
}

class _BlogSettingsViewState extends ConsumerState<BlogSettingsView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameUpdateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blog Settings"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addBlogDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  "Blogs (${ref.watch(blogNotifierProvider).blogs.length})",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  "You can edit or delete blog names.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ref.watch(blogNotifierProvider).blogs.length,
                  itemBuilder: (context, index) {
                    final blog = ref.watch(blogNotifierProvider).blogs;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.secondary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        title: Text(
                          blog[index]!.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        onTap: () {
                          updateBlogDialog(context, blog, index);
                        },
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          onPressed: () {
                            ref.read(blogNotifierProvider.notifier).deleteBlog(
                                  blog[index]!.id,
                                );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> updateBlogDialog(
    BuildContext context,
    List<Blog?> blog,
    int index,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        _nameUpdateController.text = blog[index]!.name;
        return AlertDialog(
          title: const Text("Blog Edit"),
          content: TextFormField(
            controller: _nameUpdateController,
            decoration: const InputDecoration(
              hintText: "Blog Name",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter blog name";
              }
              return null;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(blogNotifierProvider.notifier).updateBlog(
                      Blog(
                        id: blog[index]!.id,
                        name: _nameUpdateController.text,
                      ),
                    );
                _nameUpdateController.clear();
                Navigator.pop(context);
              },
              child: const Text("blog update"),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> addBlogDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Blog Create"),
        content: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: "Blog Name",
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter blog name";
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(blogNotifierProvider.notifier).createBlog(
                    _nameController.text,
                  );
              _nameController.clear();
              Navigator.pop(context);
            },
            child: const Text("blog create"),
          ),
        ],
      ),
    );
  }
}
