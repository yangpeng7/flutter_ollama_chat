import 'package:path/path.dart';
import 'package:ping/model/message.dart';
import 'package:ping/model/message_type.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Future<Database> createDatabase() async {
    final database = openDatabase(join(await getDatabasesPath(), 'ping.db'),
        onCreate: ((db, version) async {
      await createMessagesTable(db, 'messages');
    }), version: 1);
    return database;
  }

  Future<void> createMessagesTable(Database db, String tableName) async {
    await db.execute('''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY,
      type INTEGER NOT NULL,
      sender TEXT NOT NULL,
      receiver TEXT NOT NULL,
      message TEXT,
      img TEXT,
      audio TEXT,
      video TEXT
    )
  ''');
  }

  Future<void> insertMessage(Message message) async {
    final Database db = await createDatabase();
    await db.insert('messages', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Message>> getMessages(int limit, int offset) async {
    final Database db = await createDatabase();
    final List<Map<String, dynamic>> maps = await db.query('messages',
        orderBy: 'id DESC', limit: limit, offset: offset);
    return List.generate(maps.length, (i) {
      return Message(
        type: MessageType.fromCode(maps[i]['type']),
        message: maps[i]['message'],
        sender: maps[i]['sender'],
        receiver: maps[i]['receiver'],
        img: maps[i]['img'],
        audio: maps[i]['audio'],
        video: maps[i]['video'],
        // time: maps[i]['time'],
      );
    });
  }
}
