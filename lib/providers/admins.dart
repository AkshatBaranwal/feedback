import '../import.dart';

class Admin {
  final int adminid;
  final String email;

  Admin({
    @required this.adminid,
    @required this.email,
  });
}

class AdminData with ChangeNotifier {
  var _emailList = [];
  Admin _data;

  List<String> get emailList {
    return [..._emailList];
  }

  Admin get data {
    return _data == null
        ? null
        : Admin(
            adminid: _data.adminid,
            email: _data.email,
          );
  }

  void _updatePrefs(emailId, password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userType", "admin");
    prefs.setString("emailId", emailId);
    prefs.setString("password", password);
  }

  Future<void> fetchEmails() async {
    if (connection.isClosed) await initConnection();
    try {
      final response = await connection.query('''
      select email 
      from admin
      ''');
      final loadedEmails = [];
      if (response.isNotEmpty) {
        response.forEach((element) {
          loadedEmails.add(element[0]);
        });
      }
      _emailList = loadedEmails;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> login({
    @required email,
    @required password,
  }) async {
    if (connection.isClosed) await initConnection();
    try {
      final response = await connection.query(
        '''
    select adminid, email, password
    from admin
    where email = @email
    and password = crypt(@password, password)
    ''',
        substitutionValues: {
          'email': email,
          'password': password,
        },
      );
      if (response.isNotEmpty) {
        Admin temp;
        temp = Admin(
          adminid: response[0][0],
          email: response[0][1],
        );
        _updatePrefs(response[0][1], response[0][2]);
        _data = temp;
      }
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> autoLogin({
    @required email,
    @required password,
  }) async {
    if (connection.isClosed) await initConnection();
    try {
      final response = await connection.query(
        '''
    select adminid, email
    from admin
    where email = @email
    and password = @password
    ''',
        substitutionValues: {
          'email': email,
          'password': password,
        },
      );
      if (response.isNotEmpty) {
        Admin temp;
        temp = Admin(
          adminid: response[0][0],
          email: response[0][1],
        );
        _data = temp;
      }
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> register({
    @required email,
    @required password,
  }) async {
    if (connection.isClosed) await initConnection();
    try {
      final response = await connection.query(
        '''
    insert into admin (email, password)
    values (@email, crypt(@password, gen_salt('bf')))
    returning *
    ''',
        substitutionValues: {
          'email': email,
          'password': password,
        },
      );
      if (response.isNotEmpty) {
        Admin temp;
        temp = Admin(
          adminid: response[0][0],
          email: response[0][1],
        );
        _emailList.add(temp.email);
        _updatePrefs(response[0][1], response[0][2]);
        _data = temp;
      }
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> delete() async {
    if (connection.isClosed) await initConnection();
    try {
      await connection.query(
        '''
      delete
      from admin
      where adminid = @adminid
      ''',
        substitutionValues: {
          'adminid': _data.adminid,
        },
      );
      _emailList.remove(_data.email);
      _data = null;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updatePassword(password) async {
    if (connection.isClosed) await initConnection();
    try {
      final response = await connection.query(
        '''
      update admin
      set password = crypt(@password, gen_salt('bf'))
      where adminid = @adminid
      returning *
      ''',
        substitutionValues: {
          'adminid': _data.adminid,
          'password': password,
        },
      );
      if (response.isNotEmpty) _updatePrefs(response[0][1], response[0][2]);
    } catch (error) {
      throw (error);
    }
  }

  void logout() {
    _data = null;
  }
}
