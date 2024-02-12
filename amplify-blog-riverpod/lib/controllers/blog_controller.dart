// ignore_for_file: public_member_api_docs, sort_constructors_first

import "dart:async";

import "package:amplify_api/amplify_api.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:example_project/controllers/comment_controller.dart";
import "package:example_project/models/ModelProvider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class Nullable<T> {
  const Nullable.value(this.value);
  final T? value;
}

class BlogState {
  final List<Blog?> blogs;
  final List<Post?> posts;
  final List<Tag?> tags;
  final List<PostTags?> selectedTagTags;
  final List<PostTags?> selectedPostTags;
  final Nullable<Post?> selectedPost;
  final bool isLoading;
  final bool hasError;
  BlogState({
    required this.blogs,
    required this.posts,
    required this.tags,
    required this.selectedTagTags,
    required this.selectedPostTags,
    required this.selectedPost,
    required this.isLoading,
    required this.hasError,
  });

  BlogState copyWith({
    List<Blog?>? blogs,
    List<Post?>? posts,
    List<Tag?>? tags,
    List<PostTags?>? selectedTagTags,
    List<PostTags?>? selectedPostTags,
    Nullable<Post?>? selectedPost,
    bool? isLoading,
    bool? hasError,
  }) {
    return BlogState(
      blogs: blogs ?? this.blogs,
      posts: posts ?? this.posts,
      tags: tags ?? this.tags,
      selectedTagTags: selectedTagTags ?? this.selectedTagTags,
      selectedPostTags: selectedPostTags ?? this.selectedPostTags,
      selectedPost: selectedPost ?? this.selectedPost,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

final blogNotifierProvider = NotifierProvider<BlogNotifier, BlogState>(
  BlogNotifier.new,
);

class BlogNotifier extends Notifier<BlogState> {
  @override
  BlogState build() {
    debugPrint("TodoNotifier initialized");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getBlogs();
      getAllTags();
    });

    return BlogState(
      blogs: [],
      posts: [],
      tags: [],
      selectedPostTags: [],
      selectedTagTags: [],
      isLoading: false,
      hasError: false,
      selectedPost: const Nullable.value(null),
    );
  }

  Future<void> getBlogs() async {
    safePrint("called get blogs");
    state = state.copyWith(isLoading: true);
    final request = ModelQueries.list(
      Blog.classType,
      // where: Blog.NAME.beginsWith("v"),
    );

    final response = await Amplify.API.query(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
      state = state.copyWith(isLoading: true);
    } else {
      if (response.data != null) {
        state = state.copyWith(
          blogs: response.data!.items,
          isLoading: false,
        );
      }
    }
  }

  Future<void> createBlog(String? name) async {
    final request = ModelMutations.create(Blog(name: name!));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("create result: ${response.data?.id}");
      await getBlogs();
    }
  }

  Future<void> deleteBlog(String? id) async {
    if (id == null) {
      return;
    }

    final request =
        ModelMutations.deleteById(Blog.classType, BlogModelIdentifier(id: id));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("delete result: ${response.data?.id}");
      await getBlogs();
    }
  }

  Future<void> updateBlog(Blog blog) async {
    final request = ModelMutations.update(blog);
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("update result: ${response.data?.id}");
      await getBlogs();
    }
  }

  Future<void> createPost(String? name, Blog? selectedBlog) async {
    final request =
        ModelMutations.create(Post(title: name!, blog: selectedBlog));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("create result: ${response.data?.id}");
      await getBlogs();
    }
  }

  Future<void> getPosts(Blog? selectedBlog) async {
    state = state.copyWith(isLoading: true);

    final request = ModelQueries.list(
      Post.classType,
      where: QueryPredicateGroup(
        QueryPredicateGroupType.and,
        [
          Post.BLOG.eq(selectedBlog?.id),
        ],
      ),
    );
    final response = await Amplify.API.query(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("Get Post result: ${response.data?.items.length}");
      state = state.copyWith(posts: response.data!.items, isLoading: false);
    }
  }

  Future<void> getSelectedPost(String? postId) async {
    state = state.copyWith(
      isLoading: true,
      selectedPost: const Nullable.value(null),
    );

    final request = ModelQueries.list(
      Post.classType,
      where: Post.ID.eq(postId),
    );

    // Custom Document
    const customDocument =
        r"""query listPosts($filter: ModelPostFilterInput, $limit: Int, $nextToken: String) {
  listPosts(filter: $filter, limit: $limit, nextToken: $nextToken) {
    items {
      id
      title
      createdAt
      updatedAt
      blog {
        id
        name
        createdAt
        updatedAt
      }
      blogPostsId
      comments {
        items {
          content
          createdAt
          updatedAt
          id
        }
      }
    }
    nextToken
  }
}""";

    final customRequest = GraphQLRequest<PaginatedResult<Post>>(
      document: customDocument,
      apiName: request.apiName,
      authorizationMode: request.authorizationMode,
      variables: request.variables,
      headers: request.headers,
      decodePath: request.decodePath,
      modelType: request.modelType,
    );
    
    

    final response = await Amplify.API.query(request: customRequest).response;

    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("Get selected Post result: ${response.data?.items.length}");
      state = state.copyWith(
        selectedPost: Nullable.value(response.data!.items.first),
        isLoading: false,
      );

      unawaited(
        ref.read(commentNotifierProvider.notifier).getComments(postId),
      );
    }
  }

  Future<void> createTag(String? name) async {
    final request = ModelMutations.create(
      Tag(
        name: name!,
      ),
    );
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("create result: ${response.data?.id}");
      final newResponse = await Amplify.API
          .mutate(
            request: ModelMutations.create(
              PostTags(
                post: state.selectedPost.value!,
                tag: response.data!,
              ),
            ),
          )
          .response;
      if (newResponse.hasErrors) {
        debugPrint(newResponse.errors.toString());
      } else {
        debugPrint("create result: ${newResponse.data?.id}");
        await getSelectedPostTags(state.selectedPost.value);
        await getBlogs();
      }
    }
  }

  Future<void> addPostTag(Tag? selectedTag) async {
    final request = ModelMutations.create(
      PostTags(
        post: state.selectedPost.value!,
        tag: selectedTag!,
      ),
    );

    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("create result: ${response.data?.id}");
      await getBlogs();
      await getSelectedPostTags(state.selectedPost.value);
    }
  }

  Future<void> deleteTag(String? id) async {
    if (id == null) {
      return;
    }

    final request =
        ModelMutations.deleteById(Tag.classType, TagModelIdentifier(id: id));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("delete result: ${response.data?.id}");
      await getBlogs();
    }
  }

  Future<void> getAllTags() async {
    state = state.copyWith(isLoading: true);
    final request = ModelQueries.list(Tag.classType);
    final response = await Amplify.API.query(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("Get Tags result: ${response.data?.items.length}");

      state = state.copyWith(tags: response.data!.items, isLoading: false);
    }
  }

  Future<void> getSelectedTagTags(String? tagId) async {
    state = state.copyWith(isLoading: true);
    final request = ModelQueries.list(
      PostTags.classType,
      where: PostTags.TAG.eq(tagId),
    );
    final response = await Amplify.API.query(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("Get Tags result: ${response.data?.items.length}");
      state = state.copyWith(
        selectedTagTags: response.data!.items,
        isLoading: false,
      );
    }
  }

  Future<void> getSelectedPostTags(Post? selectedPost) async {
    state = state.copyWith(isLoading: true, selectedPostTags: []);

    final request = ModelQueries.list(
      PostTags.classType,
      where: QueryPredicateGroup(
        QueryPredicateGroupType.and,
        [
          PostTags.POST.eq(selectedPost?.id),
        ],
      ),
    );
    final response = await Amplify.API.query(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("Get Tags result: ${response.data?.items.length}");
      state = state.copyWith(
        selectedPostTags: response.data!.items,
        isLoading: false,
      );
    }
  }
}
