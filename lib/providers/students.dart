import '../import.dart';

class Student {
  final int studentid;
  final String enroll;
  final String email;
  final String name;
  final int branchid;
  final int year;

  Student({
    @required this.studentid,
    @required this.enroll,
    @required this.email,
    @required this.name,
    @required this.branchid,
    @required this.year,
  });
}

class StudentData with ChangeNotifier {
  final connection;
  StudentData(this.connection);

  var _emailList = [];
  var _branchList = [];
  Student _data;

  List<String> get emailList {
    return [..._emailList];
  }

  List<dynamic> get branchList {
    return [..._branchList];
  }

  Student get data {
    return Student(
      branchid: _data.branchid,
      email: _data.email,
      enroll: _data.enroll,
      name: _data.name,
      studentid: _data.studentid,
      year: _data.year,
    );
  }

  Future<void> fetchBranches() async {
    try {
      final response = await connection.query('''
      select *
      from branch
      ''');
      if (response.isNotEmpty) {
        final loadedBranches = [];
        response.forEach((val) {
          loadedBranches.add([val[0], val[1]]);
        });
        _branchList = loadedBranches;
        notifyListeners();
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchEmails() async {
    try {
      final response = await connection.query('''
      select email 
      from student
      ''');
      if (response.isNotEmpty) {
        final loadedEmails = [];
        response.forEach((val) {
          loadedEmails.add(val[0]);
        });
        _emailList = loadedEmails;
        notifyListeners();
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> login({
    @required email,
    @required password,
  }) async {
    try {
      final response = await connection.query(
        '''
    select studentid, enroll, email, name, branchid, year
    from student
    where email = @email
    and password = crypt(@password, password)
    ''',
        substitutionValues: {
          'email': email,
          'password': password,
        },
      );
      if (response.isNotEmpty) {
        _data = Student(
          studentid: response[0][0],
          enroll: response[0][1],
          email: response[0][2],
          name: response[0][3],
          branchid: response[0][4],
          year: response[0][5],
        );
        notifyListeners();
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> register({
    @required enroll,
    @required email,
    @required name,
    @required password,
    @required branchid,
    @required year,
  }) async {
    try {
      final response = await connection.query(
        '''
    insert into student (enroll, email, password, name, branchid, year)
    values (@enroll, @email, crypt(@password, gen_salt('bf')), @name, @branchid, @year)
    returning *
    ''',
        substitutionValues: {
          'enroll': enroll,
          'email': email,
          'name': name,
          'password': password,
          'branchid': branchid,
          'year': year,
        },
      );
      if (response.isNotEmpty) {
        _data = Student(
          studentid: response[0][0],
          enroll: response[0][1],
          email: response[0][2],
          name: response[0][4],
          branchid: response[0][5],
          year: response[0][6],
        );
        notifyListeners();
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> edit({
    @required id,
    @required password,
  }) async {
    try {
      await connection.query(
        '''
      update student
      set password = crypt(@password, gen_salt('bf'))
      where id = @id
      ''',
        substitutionValues: {
          'id': id,
          'password': password,
        },
      );
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
