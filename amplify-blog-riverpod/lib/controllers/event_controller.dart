// ignore_for_file: public_member_api_docs, sort_constructors_first

import "dart:async";

import "package:amplify_api/amplify_api.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:example_project/models/ModelProvider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class EventState {
  final List<Event?> events;
  final List<EventComment?> comments;
  final bool isLoading;
  final bool hasError;
  EventState({
    required this.events,
    required this.comments,
    required this.isLoading,
    required this.hasError,
  });

  EventState copyWith({
    List<Event?>? events,
    List<EventComment?>? comments,
    bool? isLoading,
    bool? hasError,
  }) {
    return EventState(
      events: events ?? this.events,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

final eventNotifierProvider = NotifierProvider<EventNotifier, EventState>(
  EventNotifier.new,
);

class EventNotifier extends Notifier<EventState> {
  @override
  EventState build() {
    debugPrint("TodoNotifier initialized");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllEvents();
    });

    return EventState(
      events: [],
      comments: [],
      isLoading: false,
      hasError: false,
    );
  }

  Future<void> addEvent(String name) async {
    final request = ModelMutations.create(Event(name: name));
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("create result: ${response.data?.id}");
      await getAllEvents();
    }
  }

  Future<void> addComment(String eventId, String content) async {
    final request = ModelMutations.create(
      EventComment(
        event: Event(id: eventId, name: ""),
        content: content,
      ),
    );
    final response = await Amplify.API.mutate(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
    } else {
      debugPrint("create result: ${response.data?.id}");
      await getAllComments(eventId);
    }
  }

  Future<void> getAllComments(String eventId) async {
    state = state.copyWith(isLoading: true);
    final request = ModelQueries.list(
      EventComment.classType,
      where: EventComment.EVENT.eq(eventId),
    );

    final response = await Amplify.API.query(request: request).response;

    if (response.hasErrors) {
      debugPrint(response.errors.toString());
      state = state.copyWith(isLoading: true);
    } else {
      if (response.data != null) {
        state = state.copyWith(
          comments: response.data!.items,
          isLoading: false,
        );
      }
    }
  }

  Future<void> getAllEvents() async {
    safePrint("called get events");
    state = state.copyWith(isLoading: true);
    final request = ModelQueries.list(
      Event.classType,
    );

    const customDocument = r""""
query listEvents($filter: ModelEventFilterInput, $limit: Int, $nextToken: String) {
  listEvents(filter: $filter, limit: $limit, nextToken: $nextToken) {
    items {
      id
      where
      description
      createdAt
      updatedAt
      name
      comments {
        items {
          content
          createdAt
          eventCommentsId
          id
          updatedAt
        }
      }
    }
    nextToken
  }
}
""";

    final customRequest = GraphQLRequest<PaginatedResult<Event>>(
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
      state = state.copyWith(isLoading: true);
    } else {
      if (response.data != null) {
        state = state.copyWith(
          events: response.data!.items,
          isLoading: false,
        );
      }
    }
  }
}
