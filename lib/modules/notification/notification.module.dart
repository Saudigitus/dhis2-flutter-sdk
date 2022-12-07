import 'package:d2_touch/modules/notification/queries/message_conversation.query.dart';
import 'package:sqflite/sqflite.dart';

import 'queries/message.query.dart';

class NotificationModule {
  static createTables({required Database database}) async {
    await MessageConversationQuery(database: database).createTable();
    await MessageQuery(database: database).createTable();
  }

  MessageConversationQuery get messageConversation =>
      MessageConversationQuery();

  MessageQuery get message => MessageQuery();
}
