import 'package:custom_events/src/event_entity.dart';
import 'package:custom_events/src/events_enum.dart';

void main() {
  final event = Event(
    name: Events.GET_MESSAGES,
    data: {
      'receiver_id': 'friend_id',
      'token': 'Bearer ***',
    },
  );

  switch (event.name) {
    case Events.REGISTER_USER:
      print(event.name);
      break;
    case Events.SEND_MESSAGE:
      print(event.name);

      break;
    case Events.GET_MESSAGES:
      print(event.name);

      break;
    case Events.GET_CHATS:
      print(event.name);

      break;
    case Events.ERROR:
      print(event.name);

      break;
    case Events.NONE:
      print(event.name);

      break;
  }
}
