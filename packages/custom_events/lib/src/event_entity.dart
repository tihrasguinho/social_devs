import 'dart:convert';

import 'package:custom_events/src/data_typedef.dart';
import 'package:custom_events/src/events_enum.dart';

class Event {
  final Events name;
  final Data data;

  Event({
    required this.name,
    required this.data,
  });

  Event copyWith({
    Events? name,
    Data? data,
  }) {
    return Event(
      name: name ?? this.name,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'event': name.name,
      'data': data,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      name: Events.values.firstWhere(
        (e) => e.name == map['event'],
        orElse: () => Events.NONE,
      ),
      data: map['data'] ?? {},
    );
  }

  String toJson() => json.encode(toMap());

  factory Event.fromJson(String source) =>
      Event.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Event(event: $name, data: $data)';

  @override
  bool operator ==(covariant Event other) {
    if (identical(this, other)) return true;

    return other.name == name && other.data == data;
  }

  @override
  int get hashCode => name.hashCode ^ data.hashCode;
}
