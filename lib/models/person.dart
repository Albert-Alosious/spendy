import 'package:hive/hive.dart';

class Person extends HiveObject {
  final String id;
  final String name;
  final String contact;
  final String? notes;

  Person({
    required this.id,
    required this.name,
    required this.contact,
    this.notes,
  });
}

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final int typeId = 3;

  @override
  Person read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final contact = reader.readString();
    final hasNotes = reader.readBool();
    final notes = hasNotes ? reader.readString() : null;
    return Person(id: id, name: name, contact: contact, notes: notes);
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.contact)
      ..writeBool(obj.notes != null);
    if (obj.notes != null) {
      writer.writeString(obj.notes!);
    }
  }
}
