import 'dart:async';

import 'package:custom_environment/custom_environment.dart';
import 'package:postgres/postgres.dart';
import 'package:social_devs_api/entities/client_entity.dart';
import 'package:social_devs_api/entities/friend_request_entity.dart';
import 'package:social_devs_api/entities/message_entity.dart';
import 'package:social_devs_api/entities/user_entity.dart';
import 'package:social_devs_api/exceptions/server_exception.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServerRepository {
  static PostgreSQLConnection? _connection;

  static List<ClientEntity>? _clients;

  ServerRepository._();

  static ServerRepository get instance => ServerRepository._();

  static Future<void> init() async {
    final env = CustomEnvironment.instance;

    _clients ??= <ClientEntity>[];

    final uri = Uri.parse(env.get<String>('pg_uri'));

    _connection ??= PostgreSQLConnection(
      uri.host,
      uri.port,
      uri.pathSegments.first,
      username: uri.userInfo.split(':').first,
      password: uri.userInfo.split(':').last,
    );

    await _connection!.open();
  }

  // WebSocket

  void addClient(ClientEntity client) {
    if (!clientExists(client.id)) {
      _clients?.add(client);
    }
  }

  void removeClient(WebSocketChannel socket) {
    _clients?.removeWhere((e) => e.socket == socket);
  }

  bool clientExists(String id) => _clients?.any((e) => e.id == id) ?? false;

  ClientEntity? getClient(String id) {
    if (clientExists(id)) {
      return _clients?.firstWhere((e) => e.id == id);
    } else {
      return null;
    }
  }

  List<String> getClientList() => _clients?.map((e) => e.id).toList() ?? [];

  // Users

  Future<UserEntity> insertUser(Map<String, dynamic> values) async {
    try {
      final insert = await _connection!.mappedResultsQuery(
        'insert into tb_users (name, username, email, password) values (@name, @username, @email, @password) returning *',
        substitutionValues: values,
      );

      return UserEntity.fromMap(insert.first['tb_users']!);
    } on PostgreSQLException catch (e) {
      final email = e.message == r'duplicate key value violates unique constraint "email"';

      final username = e.message == r'duplicate key value violates unique constraint "username"';

      final status = email || username ? 409 : 400;

      throw ServerException(status, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<UserEntity?> selectUser(String email) async {
    try {
      final select = await _connection!.mappedResultsQuery(
        'select * from tb_users where email = @email',
        substitutionValues: {'email': email},
      );

      if (select.isEmpty) {
        return null;
      } else {
        return UserEntity.fromMap(select.first['tb_users']!);
      }
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<bool> userExists(String id) async {
    try {
      final select = await _connection!.mappedResultsQuery(
        'select name from tb_users where id = @id',
        substitutionValues: {
          'id': id,
        },
      );

      return select.isNotEmpty;
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<List<UserEntity>> selectUsers(Map<String, dynamic>? params) async {
    try {
      params?.removeWhere(
        (key, _) {
          return key != 'name' && key != 'username' && key != 'email' && key != 'id';
        },
      );

      final queries = <String>[];

      for (final key in params?.keys.toList() ?? []) {
        if (key == 'name' || key == 'username' || key == 'email') {
          queries.add('$key ilike @$key');
          params?.update(key, (value) => '$value%');
        } else {
          queries.add('$key = @$key');
        }
      }

      final select = await _connection!.mappedResultsQuery(
        params != null && queries.isNotEmpty
            ? 'select * from tb_users where ${queries.join(' and ')} order by created_at'
            : 'select * from tb_users order by created_at',
        substitutionValues: params,
      );

      return select.map((e) => UserEntity.fromMap(e['tb_users']!)).toList();
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<UserEntity> updateUser(String id, Map<String, dynamic> values) async {
    try {
      final toSet = values.keys.map((e) => '$e = @$e').toList();

      final update = await _connection!.mappedResultsQuery(
        'update tb_users set ${toSet.join(', ')} where id = @id returning *',
        substitutionValues: {
          ...values,
          'id': id,
        },
      );

      return UserEntity.fromMap(update.first['tb_users']!);
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  // Friends

  Future<FriendRequestEntity?> selectFriendRequestById(String requestId) async {
    try {
      final select = await _connection!.mappedResultsQuery(
        'select * from tb_friend_requests where id = @id',
        substitutionValues: {
          'id': requestId,
        },
      );

      if (select.isEmpty) {
        return null;
      } else {
        return FriendRequestEntity.fromMap(select.first['tb_friend_requests']!);
      }
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<bool> friendRequestExists(String userId, String friendId) async {
    try {
      final select = await _connection!.mappedResultsQuery(
        'select * from tb_friend_requests where user_id = @user_id and friend_id = @friend_id',
        substitutionValues: {
          'user_id': friendId,
          'friend_id': userId,
        },
      );

      return select.isNotEmpty;
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<void> insertFriendRequest(String userId, String friendId) async {
    try {
      await _connection!.mappedResultsQuery(
        'insert into tb_friend_requests (user_id, friend_id) values (@user_id, @friend_id)',
        substitutionValues: {
          'user_id': friendId,
          'friend_id': userId,
        },
      );

      return;
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> selectFriendRequets(String id) async {
    try {
      final select = await _connection!.mappedResultsQuery(
        r'''
select
tb_friend_requests.id as request_id,
tb_friend_requests.created_at as requested_at,
tb_users.*
from tb_friend_requests
join tb_users
on tb_friend_requests.friend_id = tb_users.id
where tb_friend_requests.user_id = @user_id;
''',
        substitutionValues: {
          'user_id': id,
        },
      );

      return select.map(
        (e) {
          return {
            'request_id': e['tb_friend_requests']!['request_id'],
            'requested_at': e['tb_friend_requests']!['requested_at'].toString(),
            'user': UserEntity.fromMap(e['tb_users']!).toPublicMap(),
          };
        },
      ).toList();
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<void> deleteFriendRequest(String requestId) async {
    try {
      await _connection!.mappedResultsQuery(
        'delete from tb_friend_requests where id = @id',
        substitutionValues: {
          'id': requestId,
        },
      );

      return;
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<void> insertFriend(String userId, String friendId) async {
    try {
      await _connection!.mappedResultsQuery(
        'insert into tb_friends (user_id, friend_id) values (@user_id, @friend_id)',
        substitutionValues: {
          'user_id': userId,
          'friend_id': friendId,
        },
      );

      await _connection!.mappedResultsQuery(
        'insert into tb_friends (user_id, friend_id) values (@user_id, @friend_id)',
        substitutionValues: {
          'user_id': friendId,
          'friend_id': userId,
        },
      );
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  Future<List<UserEntity>> selectFriends(String id) async {
    try {
      final select = await _connection!.mappedResultsQuery(
        r'''
select tb_users.*, tb_friends.id as friendship_id from tb_users
join tb_friends
on tb_users.id = tb_friends.friend_id
where user_id = @id;
''',
        substitutionValues: {
          'id': id,
        },
      );

      return select.map((e) => UserEntity.fromMap(e['tb_users']!)).toList();
    } on PostgreSQLException catch (e) {
      throw ServerException(400, e.message ?? '');
    } on Exception catch (e) {
      throw ServerException(500, e.toString());
    }
  }

  // Messages

  Future<void> insertMessage(Map<String, dynamic> values) async {
    await _connection!.mappedResultsQuery(
      'insert into tb_messages (message, type, sender_id, receiver_id) values (@message, @type, @sender_id, @receiver_id) returning *',
      substitutionValues: values,
    );
  }

  Future<List<MessageEntity>> selectMessages(String senderId, String receiverId) async {
    final select = await _connection!.mappedResultsQuery(
      'select * from tb_messages where (sender_id = @sender_id and receiver_id = @receiver_id) or (sender_id = @receiver_id and receiver_id = @sender_id) order by created_at desc',
      substitutionValues: {
        'sender_id': senderId,
        'receiver_id': receiverId,
      },
    );

    return select.map((e) => MessageEntity.fromMap(e['tb_messages']!)).toList();
  }

  Future<List<MessageEntity>> selectChats(String userId) async {
    final select = await _connection!.mappedResultsQuery(
      r'''
SELECT F.ID AS FRIENDSHIP_ID,
(
    SELECT ID FROM TB_MESSAGES 
    WHERE (F.USER_ID, F.FRIEND_ID) IN ((SENDER_ID, RECEIVER_ID), (RECEIVER_ID, SENDER_ID))
    ORDER BY CREATED_AT DESC
    LIMIT 1
),
(
    SELECT MESSAGE FROM TB_MESSAGES 
    WHERE (F.USER_ID, F.FRIEND_ID) IN ((SENDER_ID, RECEIVER_ID), (RECEIVER_ID, SENDER_ID))
    ORDER BY CREATED_AT DESC
    LIMIT 1
),
(
    SELECT TYPE FROM TB_MESSAGES 
    WHERE (F.USER_ID, F.FRIEND_ID) IN ((SENDER_ID, RECEIVER_ID), (RECEIVER_ID, SENDER_ID))
    ORDER BY CREATED_AT DESC
    LIMIT 1
),
(
    SELECT SENDER_ID FROM TB_MESSAGES 
    WHERE (F.USER_ID, F.FRIEND_ID) IN ((SENDER_ID, RECEIVER_ID), (RECEIVER_ID, SENDER_ID))
    ORDER BY CREATED_AT DESC
    LIMIT 1
),
(
    SELECT RECEIVER_ID FROM TB_MESSAGES 
    WHERE (F.USER_ID, F.FRIEND_ID) IN ((SENDER_ID, RECEIVER_ID), (RECEIVER_ID, SENDER_ID))
    ORDER BY CREATED_AT DESC
    LIMIT 1
),
(
    SELECT CREATED_AT FROM TB_MESSAGES 
    WHERE (F.USER_ID, F.FRIEND_ID) IN ((SENDER_ID, RECEIVER_ID), (RECEIVER_ID, SENDER_ID))
    ORDER BY CREATED_AT DESC
    LIMIT 1
),
(
    SELECT UPDATED_AT FROM TB_MESSAGES 
    WHERE (F.USER_ID, F.FRIEND_ID) IN ((SENDER_ID, RECEIVER_ID), (RECEIVER_ID, SENDER_ID))
    ORDER BY CREATED_AT DESC
    LIMIT 1
)
FROM TB_MESSAGES AS M
JOIN TB_FRIENDS AS F
ON (F.USER_ID, F.FRIEND_ID) IN ((M.SENDER_ID, M.RECEIVER_ID), (M.RECEIVER_ID, M.SENDER_ID))
WHERE F.USER_ID = @user_id
GROUP BY F.ID
ORDER BY CREATED_AT DESC;
''',
      substitutionValues: {
        'user_id': userId,
      },
    );

    return select.map((e) => MessageEntity.fromMap(e['']!)).toList();
  }
}
