// ignore_for_file: public_member_api_docs

import "package:example_project/controllers/blog_controller.dart";
import "package:example_project/controllers/comment_controller.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

class CommentScreen extends ConsumerStatefulWidget {
  const CommentScreen({super.key, this.postId});

  final String? postId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostScreenState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty("postId", postId));
  }
}

class _PostScreenState extends ConsumerState<CommentScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blogNotifierProvider.notifier).getSelectedPost(
            widget.postId ?? "",
          );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Text(
                "Comments",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(
                height: 8,
              ),
              Consumer(
                builder: (_, WidgetRef ref, __) {
                  // final comments = ref.watch(
                  //   commentNotifierProvider.select((value) => value.comments),
                  // );

                  final commentState = ref.watch(commentNotifierProvider);

                  if (commentState.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (commentState.comments.isEmpty) {
                    return const Center(
                      child: Text("No comments"),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commentState.comments.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            // Are you sure dialog
                            showDialog<void>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Are you sure?"),
                                  content: const Text(
                                    "Do you want to delete this comment?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                              commentNotifierProvider.notifier,
                                            )
                                            .deleteComment(
                                              context,
                                              commentState.comments[index],
                                            );
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          title:
                              Text(commentState.comments[index]?.content ?? ""),
                          subtitle: Text(
                            DateFormat(
                              "dd MMMM yyyy HH:mm",
                              "tr_TR",
                            ).format(
                              commentState.comments[index]?.createdAt
                                      .getDateTimeInUtc()
                                      .toLocal() ??
                                  DateTime.now(),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              // Add new comment
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer(
                  builder: (_, WidgetRef ref, __) {
                    final commentState = ref.watch(
                      commentNotifierProvider,
                    );
                    return TextField(
                      controller: commentState.textController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Comment",
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
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(commentNotifierProvider.notifier).createComment();
                  },
                  child: const Text("Add comment"),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
