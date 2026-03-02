import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('social_sage.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const boolType = 'INTEGER NOT NULL';
    const intType = 'INTEGER';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType NOT NULL,
        email $textType,
        password_hash $textType,
        security_method $textType,
        biometric_enabled $boolType,
        created_at $textType NOT NULL,
        last_sync $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE platform_accounts (
        id $idType,
        user_id $textType NOT NULL,
        platform_name $textType NOT NULL,
        platform_user_id $textType,
        access_token $textType,
        refresh_token $textType,
        is_enabled $boolType,
        created_at $textType NOT NULL,
        expires_at $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id $idType,
        user_id $textType NOT NULL,
        title $textType,
        description $textType,
        hashtags $textType,
        media_ids $textType,
        selected_platforms $textType,
        created_at $textType NOT NULL,
        updated_at $textType,
        is_draft $boolType
      )
    ''');

    await db.execute('''
      CREATE TABLE published_posts (
        id $idType,
        post_id $textType NOT NULL,
        account_id $textType NOT NULL,
        platform_name $textType NOT NULL,
        platform_post_id $textType,
        posted_at $textType NOT NULL,
        status $textType NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE scheduled_posts (
        id $idType,
        post_id $textType NOT NULL,
        title $textType,
        description $textType,
        platforms $textType,
        scheduled_time $textType NOT NULL,
        is_posted $boolType,
        created_at $textType NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE media (
        id $idType,
        user_id $textType NOT NULL,
        file_path $textType NOT NULL,
        media_type $textType NOT NULL,
        file_size $intType,
        duration_ms $intType,
        created_at $textType NOT NULL,
        tags $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE analytics (
        id $idType,
        published_post_id $textType NOT NULL,
        account_id $textType NOT NULL,
        views $intType,
        likes $intType,
        comments $intType,
        shares $intType,
        updated_at $textType NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id $idType,
        published_post_id $textType NOT NULL,
        account_id $textType NOT NULL,
        platform_name $textType NOT NULL,
        commenter_name $textType NOT NULL,
        comment_text $textType NOT NULL,
        created_at $textType NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id $idType,
        user_id $textType NOT NULL,
        type $textType NOT NULL,
        message $textType NOT NULL,
        is_read $boolType,
        created_at $textType NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE security_logs (
        id $idType,
        user_id $textType NOT NULL,
        action $textType NOT NULL,
        timestamp $textType NOT NULL,
        details $textType
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
