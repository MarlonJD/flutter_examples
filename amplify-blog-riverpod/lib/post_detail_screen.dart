// ignore_for_file: public_member_api_docs

import "package:example_project/controllers/blog_controller.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, this.postId});

  final String? postId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostScreenState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty("postId", postId));
  }
}

class _PostScreenState extends ConsumerState<PostDetailScreen> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blogNotifierProvider.notifier).getSelectedPost(
            widget.postId ?? "",
          );
      ref.read(blogNotifierProvider.notifier).getSelectedPostTags(
            ref.read(blogNotifierProvider).selectedPost.value,
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
              Consumer(
                builder: (_, WidgetRef ref, __) {
                  final blogState = ref.watch(
                    blogNotifierProvider,
                  );
                  return Text(
                    blogState.selectedPost.value?.title ?? "",
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                },
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(blogNotifierProvider.notifier).createTag(
                        "denemeTag",
                      );
                },
                child: const Text("add tag"),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(blogNotifierProvider.notifier).addPostTag(
                        // ref.read(blogNotifierProvider).selectedPost.value,
                        ref.read(blogNotifierProvider).tags[0],
                      );
                },
                child: const Text("add first tag"),
              ),
              Text(
                "Tags",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Consumer(
                builder: (_, WidgetRef ref, __) {
                  final blogState = ref.watch(blogNotifierProvider);
                  return Column(
                    children: [
                      for (final postTagItem in blogState.selectedPostTags)
                        ActionChip(
                          onPressed: () {},
                          label: Text(postTagItem!.tag.name),
                        ),
                    ],
                  );
                },
              ),
              Text(
                "Comments",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(
                height: 8,
              ),
              Consumer(
                builder: (_, WidgetRef ref, __) {
                  final blogState = ref.watch(blogNotifierProvider);

                  if (blogState.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if ((blogState.selectedPost.value?.comments ?? [])
                      .isEmpty) {
                    return const Center(
                      child: Text("No comments"),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: blogState.selectedPost.value?.comments!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            blogState
                                .selectedPost.value!.comments![index].content,
                          ),
                          subtitle: Text(
                            blogState.selectedPost.value!.comments![index].id,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  context.push(
                    "/post/${widget.postId}/comments",
                  );
                },
                child: const Text("View comments"),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
