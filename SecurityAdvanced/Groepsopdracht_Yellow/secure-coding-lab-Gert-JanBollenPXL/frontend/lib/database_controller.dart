import 'package:postgres/postgres.dart';

class DatabaseController {

  static final Finalizer<PostgreSQLConnection> _finalizer = Finalizer((conn) {conn.close();});
  static final DatabaseController _db = DatabaseController._connect();

  final PostgreSQLConnection _dbConnection;

  DatabaseController._fromConnection(this._dbConnection);

  factory DatabaseController._connect() {

    final conn =  PostgreSQLConnection('localhost', 5434, 'pxldb', username: 'secadv', password: 'ilovesecurity');
    final wrapper = DatabaseController._fromConnection(conn);
    _finalizer.attach(wrapper, conn, detach: wrapper);
    return wrapper;
  }

  factory DatabaseController() {
    return _db;
  }

  Future<void> open()
  async {
    await _dbConnection.open();
  }

  void close()
  {
    _dbConnection.close();
    _finalizer.detach(this);
  }

  Future<bool> authenticateUser(final String user, final String passw)
  async {
    final String query = "SELECT * FROM users WHERE user_name='$user' and password='$passw'";
    var check = await _dbConnection.query(query);
    return check.isNotEmpty;
  }
}