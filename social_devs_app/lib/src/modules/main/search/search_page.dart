import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'search_bloc.dart';
import 'search_controller.dart';
import 'search_events.dart';
import 'search_states.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final bloc = Modular.get<SearchBloc>();
  final controller = Modular.get<SearchController>();

  @override
  void initState() {
    super.initState();
    bloc.add(GetUsersEvent(''));
  }

  @override
  void dispose() {
    controller.debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.searching,
      builder: (context, searching, value) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: searching ? Colors.white : null,
            title: searching
                ? TextField(
                    controller: controller.input,
                    onChanged: controller.searchByUsername,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Procurar por nome de usuário',
                    ),
                  )
                : const Text('Procurar'),
            actions: [
              AnimatedBuilder(
                animation: controller.input,
                builder: (context, child) {
                  return IconButton(
                    onPressed: () {
                      if (searching) {
                        if (controller.input.text.isNotEmpty) {
                          bloc.add(ClearUsersEvent());
                          controller.input.clear();
                        } else {
                          controller.input.clear();
                          controller.setSearching(false);
                        }
                      } else {
                        controller.input.clear();
                        controller.setSearching(true);
                      }
                    },
                    icon: Icon(
                      controller.input.text.isEmpty ? Icons.search_rounded : Icons.clear_rounded,
                      color: searching ? Colors.black : null,
                    ),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<SearchBloc, SearchStates>(
            bloc: bloc,
            builder: (context, state) {
              if (state is LoadingUsersState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LoadedUsersState || state is InitialUsersState) {
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16.0),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];

                    return ListTile(
                      title: Text(user.name),
                      subtitle: Text('@${user.username}'),
                      leading: CircleAvatar(
                        radius: 32.0,
                        backgroundImage:
                            user.thumbnail.isEmpty ? null : NetworkImage(user.thumbnail),
                      ),
                      trailing: IconButton(
                        onPressed: () => controller.sendFriendRequest(user.id),
                        icon: const Icon(Icons.person_add_rounded),
                      ),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        );
      },
    );
  }
}
