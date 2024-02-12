// ignore_for_file: public_member_api_docs

import "package:example_project/controllers/event_controller.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/date_symbol_data_local.dart";

class EventHomeScreen extends ConsumerStatefulWidget {
  const EventHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<EventHomeScreen> {
  String? _value;
  @override
  void initState() {
    initializeDateFormatting("tr_TR", null);
    initializeDateFormatting("en_US", null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Home"),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              ElevatedButton(
                onPressed: () {
                  ref.read(eventNotifierProvider.notifier).getAllEvents();
                },
                child: const Text("Get All Events"),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Consumer(
                  builder: (_, WidgetRef ref, __) {
                    final events = ref.watch(
                      eventNotifierProvider.select((value) => value.events),
                    );
                    print(events[0]!.comments);
                    return Row(
                      children: [
                        for (final event in events)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: ChoiceChip(
                              label: Text(event!.name),
                              selected: _value == event.id,
                              onSelected: (bool selected) {
                                setState(() {
                                  _value = selected ? event.id : null;
                                });
                                ref
                                    .read(eventNotifierProvider.notifier)
                                    .getAllComments(_value!);
                              },
                            ),
                          ),
                        const SizedBox(
                          width: 4,
                        ),
                        ActionChip(
                          label: const Icon(
                            Icons.tune_rounded,
                            size: 20,
                          ),
                          onPressed: () {
                            context.push("/blog-settings");
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(eventNotifierProvider.notifier).addEvent(
                        "bursa event",
                      );
                },
                child: const Text("create event"),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(eventNotifierProvider.notifier).addComment(
                        _value!,
                        "izmir comment",
                      );
                },
                child: const Text("create comment"),
              ),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text(
                    "Selected Event Comments",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Consumer(
                    builder: (_, WidgetRef ref, __) {
                      final comments = ref.watch(
                        eventNotifierProvider.select((value) => value.comments),
                      );

                      if (comments.isEmpty) {
                        return const Center(
                          child: Text("No Event"),
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                print(comments[index]);
                              },
                              title: Text(comments[index]!.content),
                              subtitle: Text(comments[index]!.id),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
