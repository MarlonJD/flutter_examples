// ignore_for_file: public_member_api_docs, sort_constructors_first
import "dart:async";

import "package:amplify_api/amplify_api.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:example_project/controllers/blog_controller.dart";
import "package:example_project/models/ModelProvider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

class CommentState {
  final bool loading;
  final TextEditingController textController;
  final List<Comment?> comments;

  CommentState({
    required this.loading,
    required this.textController,
    required this.comments,
  });

  CommentState copyWith({
    bool? loading,
    TextEditingController? textController,
    List<Comment?>? comments,
  }) {
    return CommentState(
      loading: loading ?? this.loading,
      textController: textController ?? this.textController,
      comments: comments ?? this.comments,
    );
  }
}

final commentNotifierProvider =
    AutoDisposeNotifierProvider<CommentNotifier, CommentState>(
  CommentNotifier.new,
);

class CommentNotifier extends AutoDisposeNotifier<CommentState> {
  @override
  CommentState build() {
    _blogState = ref.watch(blogNotifierProvider);

    ref.onDispose(() {
      debugPrint("Comment Notifier disposed");
    });

    debugPrint("Comment Notifier created");

    return CommentState(
      loading: false,
      textController: TextEditingController(),
      comments: [],
    );
  }

  late BlogState _blogState;

  Future<void> getComments(String? postId) async {
    state = state.copyWith(loading: true);

    final request = ModelQueries.list(
      Comment.classType,
      where: QueryPredicateGroup(
        QueryPredicateGroupType.and,
        [
          Comment.POST.eq(postId),
        ],
      ),
    );

    const customDocument =
        r"""query listComments($filter: ModelCommentFilterInput, $limit: Int, $nextToken: String) {
  commentsByDate(filter: $filter, limit: $limit, nextToken: $nextToken, sortDirection: DESC, type: "Comment") {
    items {
      id
      createdAt
      updatedAt
      post {
        id
        title
        createdAt
        updatedAt
      }
      postCommentsId
      content
    }
    nextToken
  }
}""";

    final customRequest = GraphQLRequest<PaginatedResult<Comment>>(
      document: customDocument,
      apiName: request.apiName,
      authorizationMode: request.authorizationMode,
      variables: request.variables,
      headers: request.headers,
      decodePath: "commentsByDate",
      modelType: request.modelType,
    );

    final response = await Amplify.API.query(request: customRequest).response;

    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("Get Comment result: ${response.data?.items.length}");
      state = state.copyWith(comments: response.data!.items, loading: false);
    }
  }

  Future<void> deleteComment(
    BuildContext context,
    Comment? comment,
  ) async {
    final request = ModelMutations.delete(comment!);

    final response = await Amplify.API.mutate(request: request).response;

    if (response.hasErrors) {
      debugPrint(response.errors.map((e) => e).toList().toString());
    } else {
      if (response.data != null) {
        debugPrint("Comment deleted: ${response.data?.id}");

        // Call all comments for update
        unawaited(getComments(_blogState.selectedPost.value?.id));

        // call from custom documented comments
        unawaited(
          ref
              .read(blogNotifierProvider.notifier)
              .getSelectedPost(_blogState.selectedPost.value?.id),
        );

        // ignore: use_build_context_synchronously
        context.pop();
      }
    }
  }

  Future<void> createComment() async {
    if (state.textController.text.isEmpty) {
      return;
    }

    final request = ModelMutations.create(
      Comment(
        type: "Comment",
        content: state.textController.text.trim(),
        post: _blogState.selectedPost.value,
        createdAt: TemporalDateTime.now(),
      ),
    );

    final response = await Amplify.API.mutate(request: request).response;

    if (response.hasErrors) {
      debugPrint(response.errors.map((e) => e).toList().toString());
    } else {
      if (response.data != null) {
        debugPrint("Comment created: ${response.data?.id}");

        // Call all comments for update
        await getComments(_blogState.selectedPost.value?.id);

        // call from custom documented comments
        await ref
            .read(blogNotifierProvider.notifier)
            .getSelectedPost(_blogState.selectedPost.value?.id);
      }
    }
  }
}
