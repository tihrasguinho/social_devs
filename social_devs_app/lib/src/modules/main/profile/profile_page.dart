import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_devs_app/src/core/models/request_model.dart';
import 'package:social_devs_app/src/core/models/user_model.dart';

import 'profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final controller = Modular.get<ProfileController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.getFriends();
      await controller.getFriendRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<Box>(
            valueListenable: Hive.box('app').listenable(),
            builder: (context, box, child) {
              final user = UserModel.fromJson(box.get('user'));

              return Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    height: 24.0,
                  ),
                  InkWell(
                    onTap: () => controller.changePhoto().then((value) => setState(() {})),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: user.thumbnail.isEmpty ? null : NetworkImage(user.thumbnail),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24.0),
          ValueListenableBuilder<List<RequestModel>>(
            valueListenable: controller.requests,
            builder: (context, list, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  list.isEmpty
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'Solicitações de amizade',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                  ...list.map(
                    (e) {
                      return ListTile(
                        onTap: () {
                          if (kDebugMode) print('listTile');
                        },
                        title: Text(e.user.name),
                        subtitle: Text('@${e.user.username}'),
                        leading: CircleAvatar(
                          backgroundImage:
                              e.user.thumbnail.isEmpty ? null : NetworkImage(e.user.thumbnail),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            if (kDebugMode) print('iconButton');

                            await controller.acceptFriend(e.requestId);
                          },
                          icon: const Icon(Icons.thumb_up),
                        ),
                      );
                    },
                  ).toList(),
                ],
              );
            },
          ),
          ValueListenableBuilder<Box<UserModel>>(
            valueListenable: controller.friends.listenable(),
            builder: (context, list, value) {
              return Column(
                children: [
                  list.isEmpty
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Text(
                                'Amigos',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                ),
                                child: Text(
                                  'Todos',
                                  style: Theme.of(context).textTheme.button!.copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ...list.values.take(5).map((e) {
                    return ListTile(
                      onTap: () {
                        if (kIsWeb) {
                          Modular.to.navigate('/chat/${e.id}');
                        } else {
                          Modular.to.pushNamed('/chat/${e.id}');
                        }
                      },
                      title: Text(e.name),
                      subtitle: Text('@${e.username}'),
                      leading: CircleAvatar(
                        backgroundImage: e.thumbnail.isEmpty ? null : NetworkImage(e.thumbnail),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
