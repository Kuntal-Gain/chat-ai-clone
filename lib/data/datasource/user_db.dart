import 'package:chat_app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDb {
  final db = Supabase.instance.client.from('Users');

  /* CRUD OPR */
  // create
  Future createUser(UserModel user) async {
    await db.insert(user.toMap());
  }

  // read
  final stream = Supabase.instance.client.from('Users').stream(
    primaryKey: ['id'],
  ).map((data) => data.map((userMp) => UserModel.fromMap(userMp)).toList());
}
