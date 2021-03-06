import '../import.dart';

class UpdateAccount extends StatefulWidget {
  static const routeName = '/update-account';
  @override
  _UpdateAccountState createState() => _UpdateAccountState();
}

class _UpdateAccountState extends State<UpdateAccount> {
  final _form = GlobalKey<FormState>();
  bool _isInit = true, _isLoading = false, _updatePassword;
  List<bool> _hidePassword = [true, true];
  List<String> _password = ['', ''];
  StudentData _student;
  FacultyData _faculty;
  AdminData _admin;
  User _user;

  Future<void> _safeForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) return;
    _form.currentState.save();
    try {
      if (_user == User.student) await _student.updatePassword(_password[0]);
      if (_user == User.faculty) await _faculty.updatePassword(_password[0]);
      if (_user == User.admin) await _admin.updatePassword(_password[0]);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password updated'),
        duration: Duration(seconds: 2),
      ));
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Connection Error'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Widget _changePassword() {
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 15,
          ),
          TextFormField(
            obscureText: _hidePassword[0],
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'Enter new password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: _hidePassword[0]
                    ? Icon(Icons.visibility_off_outlined)
                    : Icon(Icons.visibility_outlined),
                onPressed: () {
                  setState(() {
                    _hidePassword[0] = !_hidePassword[0];
                  });
                },
              ),
            ),
            onChanged: (password) {
              setState(() {
                _password[0] = password;
              });
            },
            textInputAction: TextInputAction.next,
            validator: (password) {
              if (password.isEmpty) return 'Enter a password';
              return null;
            },
            onSaved: (password) {
              _password[0] = password;
            },
          ),
          SizedBox(
            height: 15,
          ),
          TextFormField(
            obscureText: _hidePassword[1],
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: _hidePassword[1]
                    ? Icon(Icons.visibility_off_outlined)
                    : Icon(Icons.visibility_outlined),
                onPressed: () {
                  setState(() {
                    _hidePassword[1] = !_hidePassword[1];
                  });
                },
              ),
            ),
            onChanged: (password) {
              setState(() {
                _password[1] = password;
              });
            },
            textInputAction: TextInputAction.done,
            validator: (password) {
              if (password != _password[0]) return 'Passwords do not match';
              return null;
            },
            onSaved: (password) {
              _password[1] = password;
            },
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: () {
              _safeForm();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetch() async {
    if (_updatePassword) return;
    if (_user == User.faculty)
      await Future.wait([
        Provider.of<FacultyData>(context, listen: false).fetchEmails(),
        Provider.of<FacultyData>(context, listen: false).fetchCourses(),
      ]);
    else if (_user == User.student)
      await Future.wait([
        Provider.of<StudentData>(context, listen: false).fetchEmails(),
        Provider.of<StudentData>(context, listen: false).fetchBranches(),
        Provider.of<StudentData>(context, listen: false).fetchEnrolls(),
      ]);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      var _args =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      setState(() {
        _user = _args['user'];
        _updatePassword = _args['password'];
      });
      _fetch().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _student = Provider.of<StudentData>(context);
    _faculty = Provider.of<FacultyData>(context);
    _admin = Provider.of<AdminData>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_updatePassword ? 'Change password' : 'Update Details'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _updatePassword
              ? _changePassword()
              : _user == User.faculty
                  ? FacultyForm()
                  : StudentForm(),
    );
  }
}
