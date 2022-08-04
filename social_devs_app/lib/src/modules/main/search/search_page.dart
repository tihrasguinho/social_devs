import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';

import 'search_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = Modular.get<SearchController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<UserModel>?>(
        future: controller.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Falhou!'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                title: Text(user.name),
                subtitle: Text('@${user.username}'),
                leading: CircleAvatar(
                  radius: 32.0,
                  backgroundImage: user.thumbnail.isEmpty ? null : NetworkImage(user.thumbnail),
                ),
                trailing: IconButton(
                  onPressed: () => controller.sendFriendRequest(user.id),
                  icon: const Icon(Icons.person_add_rounded),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
