//import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:internet_file/internet_file.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'image_banner.dart';
import 'text_section.dart';
import 'YouTubeVideoPage.dart';
import 'pdfwiever.dart';
import 'Lecture.dart';
import 'circle.dart';
import 'dart:async';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:image_picker/image_picker.dart';
import 'circle_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart'; // Ensure this file exists
import 'package:country_code_picker/country_code_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'recipe_card.dart';
import 'package:html/parser.dart' as parser;


final FirebaseAuth _auth = FirebaseAuth.instance;
class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeNotifier() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode; // ✅ Correct getter name

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'light';
    _themeMode = themeString == 'light' ? ThemeMode.light : ThemeMode.dark;
    notifyListeners(); // ✅ Notify listeners after loading theme
  }

  void toggleTheme() async { // ✅ Use toggleTheme() instead of toggleMode()
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: "dev project",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await SharedPreferences.getInstance(); // Initialize SharedPreferences
  MobileAds.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLoginStatus()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class UserProvider extends ChangeNotifier {
  String? _username;
  String? _userrole;
  String? _userphone;
  String? _userid;

  String? get username => _username;
  String? get userrole => _userrole;
  String? get userphone => _userphone;
  String? get userid => _userid;

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('loadUser:');
    print(prefs.getInt('role'));
    _username = prefs.getString('username') ?? 'Guest';
    _userrole = (prefs.getInt('role') == 1 || prefs.getInt('role') == 3) ? 'Admin' : 'Guest';
    _userphone = prefs.getString('phone') ?? 'Guest';
    _userid = prefs.getString('user_id') ?? 'Guest';
    notifyListeners(); // Notify widgets to update
  }
  void setUserRole(String? role) {
    _userrole = role;
    notifyListeners(); // UI ni yangilash
  }
  void setUsername(String newUsername, String newUserrole, String newUserphone, String newUserid) {
    _username = newUsername;
    _userrole = newUserrole;
    _userphone = newUserphone;
    _userid = newUserid;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('username', newUsername);
      prefs.setString('role', newUserrole);
      prefs.setString('phone', newUserphone);
      prefs.setString('user_id', newUserid);
    });
    notifyListeners();
  }
}

class AuthProvider with ChangeNotifier {
  String _username = "";
  String _password = "";
  String _email = "";
  int _score = 0;
  String _summscore = "";
  int _countscore = 0;
  bool _isLoggedIn = false;

  String get username => _username;
  String get password => _password;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;
  List<int> _quizResults = [];
  List<int> get quizResults => _quizResults;

  int get score => _score;

  void setscore(int score) {
    _score = score;
    notifyListeners();
    print(score);
  }

  set score(int _score) {}

  void summsetscore(String summscore) {
    _summscore = summscore;
    notifyListeners();
    print(summscore);
  }

  set summscore(int _summscore) {}

  int get countscore => _countscore;
  void countsetscore(int countscore) {
    _countscore = countscore;
    notifyListeners();
    print(countscore);
  }

  set countscore(int _countscore) {}

  void addQuizResult(int result) {
    _quizResults.add(result);
    notifyListeners();
  }

  Future<void> login(String username) async {
    // Perform your login logic here

    // If login is successful, set the username and login status
    _username = username;
    _email = email;
    _password = password;
    _isLoggedIn = true;

    // Store the user login details in shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('password', password);
    prefs.setString('email', email);
    prefs.setInt('score', score);
    prefs.setBool('isLoggedIn', true);
    print(password);

    notifyListeners();
  }

  bool isTeacher() {
    return _username == 'Teacher' && _password == '12345';
  }

  void setLoggedInEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void fetchScore(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshScore();
  }

  Future<void> refreshScore() async {
    try {
      // Make an API call to fetch the user's score
      final response = await http.post(
        Uri.parse('https://hbnnarzullayev.pythonanywhere.com/users_scores'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nms': _username, 'app': 2}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final score = data['last_score'];
        final summscore = data["summ_score"];
        final countscore = data['count_score'];
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('score', score);

        // Update the score in the AuthProvider
        setscore(score);
        summsetscore(summscore);
        countsetscore(countscore);
        notifyListeners();
        // Show a success message (optional)
        print('Score updated successfully');
      } else {
        // Handle the case where fetching score failed
        print('Failed to fetch score. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any other errors that may occur
      print('Error: $error');
    }
  }

  Future<void> logout() async {
    // Perform your logout logic here

    // Clear user login details from shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('username');
    prefs.remove('isLoggedIn');

    // Reset the username and login status
    _username = "";
    _password = '';
    _isLoggedIn = false;

    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');
    _password = prefs.getString('password') ?? "";
    final storedEmail = prefs.getString('email');
    final storedIsLoggedIn = prefs.getBool('isLoggedIn');

    if (storedUsername != null &&
        storedIsLoggedIn != null &&
        storedIsLoggedIn) {
      _username = storedUsername;
      _isLoggedIn = true;
    } else {
      _username = "";
      _isLoggedIn = false;
    }

    if (storedEmail != null && storedIsLoggedIn != null && storedIsLoggedIn) {
      _email = storedEmail;
      _isLoggedIn = true;
    } else {
      _email = "";
      _isLoggedIn = false;
    }

    notifyListeners();
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  // Define other light theme properties
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.indigo,
  // Define other dark theme properties
);
Future<void> _requestPermissions() async {
  // Request permission to access external storage
  var status = await Permission.storage.request();

  if (status.isGranted) {
    print("Storage permission granted");
  } else {
    print("Storage permission denied");
    // You can show a dialog explaining why the permission is needed.
  }
}

class ThemeModel with ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeModel() {
    _initTheme();
  }

  ThemeMode get mode => _mode;

  Future<void> _initTheme() async {
    await _loadThemeMode();
    notifyListeners();
  }

  void toggleMode() async {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeMode();
    notifyListeners();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = (prefs.getString('themeMode') ?? 'light') == 'light'
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _mode == ThemeMode.light ? 'light' : 'dark');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static bool isAdmin = false;
  static String userId = '';
  static String username = '';
  static String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return ChangeNotifierProvider<ThemeModel>(
          create: (_) => ThemeModel(),
          child: Consumer<ThemeModel>(
            builder: (_, model, __) {
              return MaterialApp(
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: model.mode,
                home: FutureBuilder<bool>(
                  future: checkLoginStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Scaffold(
                        body: Center(child: Text('Error loading app')),
                      );
                    } else if (snapshot.hasData && snapshot.data == true) {
                      return const MyHomePage();
                    } else {
                      return SignInPage();
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = '';
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as ${user.displayName}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });
    String formatPhoneNumber(String phoneNumber) {
      phoneNumber = phoneNumber.trim(); // Remove extra spaces

      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+$phoneNumber'; // Add '+' if missing
      }

      return phoneNumber;
    }

    String formattedPhone = formatPhoneNumber(_phoneController.text);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Auto-sign-in successful!')),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP sent!')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as ${user.phoneNumber}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ThemeModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Login/Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: Text('Send OTP'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signInWithOTP,
              child: Text('Sign In with OTP'),
            ),
            SizedBox(height: 32),
            Text('OR'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text('Sign In with Google'),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black38),
              child: ListTile(
                leading: Icon(
                  Icons.home,
                  color: model.mode == ThemeMode.light
                      ? Colors.white
                      : Colors.lightBlueAccent,
                ),
                title: Text(
                  "Bosh sahifa",
                  style: TextStyle(
                    color: model.mode == ThemeMode.light
                        ? Colors.white
                        : Colors.lightBlueAccent,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                },
              ),
            ),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  Future<void> _signInUser() async {
    final String phoneNumber = _phoneController.text;
    final String password = _passwordController.text;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(phoneNumber).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['password'] == password) {
          await FirebaseAuth.instance.signInAnonymously();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userData['user_id']);
          await prefs.setString('username', userData['username']);
          await prefs.setString('phone', userData['phone']);
          await prefs.setInt('role', userData['role']); // ✅ Save role

          // ✅ Fetch role again from prefs
          int role = prefs.getInt('role') ?? 0;
          String userRole = (role == 1 || role == 3) ? 'Admin' : 'Guest';

          // ✅ Update UserProvider
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUserRole(userRole);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully signed in!')));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incorrect password')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not found')));
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    _saveUserToBackend(userCredential.user);
  }

  Future<void> _saveUserToBackend(User? user) async {
    if (user == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.uid);
    await prefs.setString('username', user.displayName ?? '');
    await prefs.setString('phone', user.phoneNumber ?? '');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  Future<void> _forgotPassword() async {
    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter your phone number')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Phone number automatically verified!")),
          );
        },

        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          // ✅ Pass `verificationId` to OtpVerificationPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                phoneNumber: phoneNumber,
                verificationId: verificationId, // ✅ Fix: Passing verificationId
              ),
            ),
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          print("Code auto retrieval timeout");
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kirish')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone Number')),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Parol',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () { setState(() { _obscurePassword = !_obscurePassword; }); },
                ),
              ),
              obscureText: _obscurePassword,
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _signInUser, child: Text('Kirish')),
            TextButton(onPressed: _forgotPassword, child: Text('Parolni unutdingizmi?')),
            ElevatedButton(onPressed: _signInWithGoogle, child: Text('Google hisobi orqali kirish')),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Bosh sahifa"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text("Ro'yxatdan o'tish"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  OtpVerificationPage({required this.phoneNumber, required this.verificationId});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isVerifying = false;

  Future<void> _verifyOtpAndResetPassword() async {
    String newPassword = _newPasswordController.text.trim();

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a new password')),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // ✅ 1. Update password in Firebase Authentication
        await user.updatePassword(newPassword);

        // ✅ 2. Update password in Firestore (if you store it there)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.phoneNumber)
            .update({'password': newPassword});

        // ✅ 3. Save new password locally in SharedPreferences (optional)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('password', newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset successful! Please sign in.')),
        );

        // ✅ 4. Log user out after password reset
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found! Please sign in again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter OTP'),
            ),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'Enter New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isVerifying
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _verifyOtpAndResetPassword,
              child: Text('Verify & Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String verificationId = '';
  String countryCode = '+998';
  bool otpSent = false;
  bool otpVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _sendOTP() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '$countryCode${_phoneController.text}',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          otpSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {},
    );
  }

  Future<void> _verifyOTP() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: _otpController.text,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    setState(() => otpVerified = true);
  }

  Future<void> _registerUser() async {
    final String username = _usernameController.text;
    final String phoneNumber = '$countryCode${_phoneController.text}';
    final String password = _passwordController.text;
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? '';

    // Save to Firestore
    await FirebaseFirestore.instance.collection('users').doc(phoneNumber).set({
      'user_id': userId,
      'username': username,
      'phone': phoneNumber,
      'password': password, // Note: Hash passwords before storing in production
    });

    // Save to Flask backend
    final response = await http.post(
      Uri.parse('https://hbnnarzullayev.pythonanywhere.com/fire_register_app'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'username': username,
        'phone': phoneNumber,
        'email': 'Email_fire',
        'pwd': password,
        'pwdc': password,
        'app_id': '4'
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Muvaffaqqiyatli ro'yxatdan o'tish!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login yoki parol xato'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _usernameController, decoration: InputDecoration(labelText: 'Username')),
                CountryCodePicker(
                  initialSelection: 'UZ',
                  onChanged: (code) {
                    setState(() => countryCode = code.dialCode!);
                  },
                ),
                TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone Number')),
                ElevatedButton(onPressed: _sendOTP, child: Text('Send OTP')),
                if (otpSent) TextField(controller: _otpController, decoration: InputDecoration(labelText: 'Enter OTP')),
                if (otpSent) ElevatedButton(onPressed: _verifyOTP, child: Text('Verify OTP')),
                if (otpVerified) TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password', suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () { setState(() { _obscurePassword = !_obscurePassword; }); })), obscureText: _obscurePassword),
                if (otpVerified) TextField(controller: _confirmPasswordController, decoration: InputDecoration(labelText: 'Confirm Password', suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off), onPressed: () { setState(() { _obscureConfirmPassword = !_obscureConfirmPassword; }); })), obscureText: _obscureConfirmPassword),
                if (otpVerified) ElevatedButton(onPressed: _registerUser, child: Text('Register')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Check if the user is logged in by looking for a saved token or session key.
  return prefs.containsKey('userToken');
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double containerWidthFraction = 0.45;
  final double containerHeightFraction = 0.15;
  List<Map<String, dynamic>> foodGroups = [];
  bool isLoading = true;
  bool isAdmin = false;
  bool isAdmins = false;
  bool isConnected = true;

  final List<String> imagePaths = [
    "assets/images/Home.png",
    "assets/images/manti.jpg",
  ];

  int currentIndex = 0;
  List<Map<String, String>> imageData = [];

  Future<void> fetchImageData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://hbnnarzullayev.pythonanywhere.com/get_food_groups_admin'));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Extract the "food_groups_list" from the response
        List<dynamic> foodGroups = jsonResponse['food_groups_list'] ?? [];

        setState(() {
          // Ensure each item is mapped safely
          imageData = foodGroups.map((data) {
            if (data is Map<String, dynamic>) {
              return {
                'image': data['image']?.toString() ?? '',
                'group_name': data['group_name']?.toString() ?? '',
              };
            }
            return {'image': '', 'group_name': ''};
          }).toList();

          print(imageData);
        });
      } else {
        throw Exception('Failed to load image data');
      }
    } catch (e) {
      print('Error fetching image data: $e');
    }
  }

  int currentIndex_gr = 0;

  List<Map<String, String>> suggestedVideos = [];

  void loadVideos() async {
    suggestedVideos = await fetchSuggestedVideos();
    setState(() {}); // Refresh UI after fetching data
  }

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _fetchData();
    fetchImageData();
    loadVideos();
  }

  Future<List<Map<String, String>>> fetchSuggestedVideos() async {
    final response = await http.get(Uri.parse('https://hbnnarzullayev.pythonanywhere.com/suggested_videos'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((video) => {
        'title': video['title'].toString(),  // Convert to String
        'videoId': video['videoId'].toString(),
        'thumbnail': video['thumbnail'].toString(),
      }).toList();
    } else {
      throw Exception('Failed to load suggested videos');
    }
  }

  Future<void> _fetchData() async {
    fetchSuggestedVideos();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.username;

    if (username != null && username.isNotEmpty) {
      await fetchFoodGroups_admin();
    } else {
      await fetchFoodGroups_admin();
    }
  }

  Future<void> fetchFoodGroups_admin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dynamic username = userProvider.username;
    final dynamic userrole = userProvider.userrole;
    final url =
        'https://hbnnarzullayev.pythonanywhere.com/get_food_groups_admin?username=$username&app_id=4';
    print(url);

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> foodGroupsList = data['food_groups_list'] ?? [];

        // Ensure Provider is accessed correctly
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final dynamic isAdminValue = userProvider.userrole;
        print('isAdminValue:');
        print(isAdminValue);
        setState(() {
          foodGroups = foodGroupsList.map((group) {
            return {
              'text': group['name'] ?? 'Unknown',
              'groupName': group['group_name'] ?? 'Unknown',
              'image': group['image'] ?? '',
            };
          }).toList();

          // Ensure proper boolean conversion
          isAdmin = isAdminValue is bool ? isAdminValue : (isAdminValue.toString().toLowerCase() == 'admin');
          print('isAdmin:');
          print(isAdmin);

          // isAdmins = isAdminValues == 'Admin'; // Corrected role-check logic

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load food groups');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching food groups: $e');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Provider ichidagi ma’lumotlarni yangilaymiz
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUserRole(null); // Yoki 'Mehmon' deb qo‘yish mumkin

    _MyAppState.isAdmin = false;
    _MyAppState.userId = '';
    _MyAppState.username = 'Mehmon';
    _MyAppState.phoneNumber = '+12345678';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('hbnnarzullayev.pythonanywhere.com');
      setState(() => isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty);
    } on SocketException catch (_) {
      setState(() => isConnected = false);
    }
  }

  // Widget _buildFoodGroupsList() {
  //   print('userrole');
  //   print(Provider.of<UserProvider>(context).userrole);
  //   print('_userid:');
  //   print(Provider.of<UserProvider>(context)._userid);
  //   if (isLoading) {
  //     return const Center(child: CircularProgressIndicator());
  //   }
  //
  //   if (!isConnected) {
  //     return const Center(
  //       child: Text(
  //         'Internetga ulaning',
  //         style: TextStyle(color: Colors.white, fontSize: 16),
  //       ),
  //     );
  //   }
  //
  //   if (foodGroups.isEmpty) {
  //     return const Center(
  //       child: Text(
  //         "Ma'lumot mavjud emas,\n Internetga ulaning",
  //         style: TextStyle(color: Colors.white, fontSize: 16),
  //         textAlign: TextAlign.center,
  //       ),
  //     );
  //   }
  //
  //   return ListView.builder(
  //     scrollDirection: Axis.horizontal,
  //     itemCount: foodGroups.length,
  //     itemBuilder: (context, index) {
  //       final group = foodGroups[index];
  //       return Padding(
  //         padding: const EdgeInsets.only(left: 8.0),
  //         child: CustomContainer(
  //           text: group['text'],
  //           targetPage: YouTubeVideoListScreen(groupName: group['groupName']),
  //           imageNetwork:'https://hbnappdatas.pythonanywhere.com/static/Image/${group['image']}',
  //           widthFraction: containerWidthFraction,
  //           heightFraction: containerHeightFraction,
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildActionButton(String title, String imagePath, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 5, 0, 0),
      height: MediaQuery.of(context).size.height * containerHeightFraction * 1.2,
      width: MediaQuery.of(context).size.width * containerWidthFraction,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.fill),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: TextSectiontwo(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('T A O M L A R'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Profilepage())),
          ),
        ],
      ),
      drawer: _buildDrawer(authProvider, themeProvider),
      bottomNavigationBar: BannerAdWidget(),
      body:
          Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  scrollDirection: Axis.horizontal,
                  height: MediaQuery.of(context).size.height * 0.2,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index; // Update the index
                    });
                  },
                ),
                items: imagePaths.map((imagePath) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.9,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Smooth Page Indicator (Dots)
              AnimatedSmoothIndicator(
                activeIndex: currentIndex,
                count: imagePaths.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.teal,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 5,
                ),
              ),
              const SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Guruhlar",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                Container(
                  child: IconButton(
                    icon: const Icon(Icons.refresh_outlined),
                    onPressed: () {
                      fetchFoodGroups_admin(); // Ensure `username` is defined
                    },
                  ),
                ),
                if (isAdmin) Container(
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddVideoGroupPage())),
                  ),
                ),
              ],
            ),
              CarouselSlider(
                options: CarouselOptions(
                  scrollDirection: Axis.horizontal,
                  height: MediaQuery.of(context).size.height * 0.1,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  enlargeCenterPage: true,
                  viewportFraction: 0.4,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex_gr = index;
                    });
                  },
                ),
                items: imageData.isNotEmpty
                    ? imageData.map((data) {
                  final imageUrl = data['image'] ?? ''; // Handle potential null value
                  final groupName = data['group_name'] ?? 'Default Group'; // Handle null safely

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YouTubeVideoListScreen(
                            groupName: groupName, // Corrected group name handling
                          ),
                        ),
                      );
                      print("Tapped on $groupName");
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          imageUrl.isNotEmpty
                              ? Image.network(
                            'https://hbnappdatas.pythonanywhere.com/static/Image/$imageUrl',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.7,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          )
                              : Container(color: Colors.grey), // Placeholder for missing image
                          Container(color: Colors.black.withOpacity(0.3)),
                          Positioned(
                            bottom: 15,
                            child: Text(
                              groupName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList()
                    : [Container()], // Placeholder for empty data
              ),
              const SizedBox(height: 10),
              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageData.length, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentIndex_gr == index ? 16 : 8,
                    decoration: BoxDecoration(
                      color: currentIndex_gr == index
                          ? Colors.teal
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextButton(child: Text("Tavsiya etilgan videolar",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoListScreen())),
                      ),
                      IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoListScreen())),)
                    ],
                  ),
                  const SizedBox(height: 10),

                  /// **📌 List of Suggested Videos**
                  Expanded(
                    child: ListView.builder(
                      itemCount: suggestedVideos.length,
                      itemBuilder: (context, index) {
                        final video = suggestedVideos[index];
                        print(video);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YouTubeScreen(
                                  videoUrl: video['videoId']!,
                                  name: video['title']!,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                /// **📌 Video Thumbnail**
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    video['thumbnail']!,
                                    width: 120,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                /// **📌 Video Title**
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      video['title']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                /// **📌 Play Icon**
                                const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.redAccent,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
            ],
    ),
    );
  }

  Widget _buildDrawer(AuthProvider authProvider, ThemeNotifier themeProvider) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dynamic userId = userProvider.userrole;
    print(userId);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              opacity: 0.2,
              image: AssetImage('assets/images/back.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator(); // Yoki bosh UI
                  }

                  final prefs = snapshot.data!;
                  print('prefs::::::');
                  print(prefs);
                  final String username = prefs.getString('username') ?? 'MEHMON';
                  final String phone = prefs.getString('phone') ?? 'MEHMON';
                  final String userId = prefs.getString('user_id') ?? '';
                  final int isAdmin = prefs.getInt('role') ?? 0;

                  return UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: Colors.black38),
                    accountName: Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: Text(
                      phone,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: userId.isNotEmpty
                          ? NetworkImage(
                        'https://hbnnarzullayev.pythonanywhere.com/static/Image/$username.jpg',
                      )
                          : AssetImage('assets/images/default.jpg') as ImageProvider,
                      onBackgroundImageError: (_, __) => AssetImage('assets/images/default.png'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified_user),
                title: const Text('Profil', style: TextStyle(color: Colors.blue)),
                onTap: () {
                  // Replace this with your actual user ID check
                  final bool isLoggedIn = userId != null && userId.isNotEmpty;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => isLoggedIn ? Profilepage() : SignInPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified_user),
                title: const Text('Chiqish', style: TextStyle(color: Colors.blue)),
                onTap: _logout,
              ),
              ListTile(
                leading: Icon(
                  themeProvider.themeMode == ThemeMode.light
                      ? Icons.nights_stay_outlined
                      : Icons.wb_sunny_outlined,
                ),
                title: Text(
                  themeProvider.themeMode == ThemeMode.light ? "Tungi rejim" : "Kunduzgi rejim",
                  style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.light ? Colors.blueAccent : Colors.white,
                  ),
                ),
                onTap: () => themeProvider.toggleTheme(), // ✅ Corrected method name
              ),
              const AboutListTile(
                icon: Icon(Icons.info),
                applicationIcon: Icon(Icons.person_2_outlined),
                applicationName: 'Taomlar',
                applicationVersion: '1.0.1',
                applicationLegalese: 'Telegram: @hbn_company',
                aboutBoxChildren: [
                  Image(image: NetworkImage('https://hbnnarzullayev.pythonanywhere.com/static/logo-no-background.png')),
                ],
                child: Text('About app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Profilepages extends StatefulWidget {
  const Profilepages({super.key});

  @override
  State<Profilepages> createState() => _Profilepages();
}

class _Profilepages extends State<Profilepages> {
  File? _image;
  int selectedPageIndex = 0;
  void logoutUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.login(""); // Clear the username
    authProvider.setLoggedInEmail("");
    authProvider.setscore(0);
    // You can also perform any additional logout actions here
  }

  Future<void> _uploadPhoto() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rasm tanlanmadi!')), // No image selected
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://hbnnarzullayev.pythonanywhere.com/api/upload_img'),
    )..fields['user_id'] =
        authProvider.username; // Sending the username as user_id

    // Read the image file as bytes
    List<int> imageBytes = await _image!.readAsBytes();
    http.MultipartFile file = http.MultipartFile.fromBytes(
      'photo', // The field name for the file in Flask
      Uint8List.fromList(imageBytes),
      filename: 'user_photo.jpg',
    );

    request.files.add(file); // Add the image file to the request

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Muvaffaqqiyatli yangilandi!')), // Successful upload message
        );
        await _saveImageLocally(imageBytes);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload: ${response.statusCode}')),
        );
      }
    } catch (error) {
      String errorMessage =
          'Xatolik yuz berdi! Iltimos, qaytadan urinib ko\'ring.';
      if (error is http.ClientException) {
        errorMessage =
        'Tarmoq xatosi. Internetga ulanishni tekshirib ko\'ring.';
      } else if (error is TimeoutException) {
        errorMessage =
        'Xizmat kutish vaqti tugadi. Iltimos, keyinroq urinib ko\'ring.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _saveImageLocally(List<int> imageBytes) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Use the path_provider package to get the local directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = authProvider.username == null
        ? 'assets/images/default.jpg'
        : '${directory.path}/${authProvider.username}_profile.jpg';
    final file = File(filePath);

    await file.writeAsBytes(imageBytes);
    print('Image saved locally at $filePath');
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil rasmini o'zgartirish"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? CircleAvatar(
              radius: 80,
              backgroundImage: FileImage(_image!),
            )
                : CircleAvatar(
              radius: 80,
              child: Icon(Icons.person, size: 80),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _pickImage();
              },
              child: Text('Rasm tanlash'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _uploadPhoto();
              },
              child: Text('Rasmni yuklash'),
            ),
          ],
        ),
      ),
    );
  }
}

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _Profilepage();
}


class _Profilepage extends State<Profilepage> {
  bool isAdmins =false;
  void initState() {
    super.initState();
    // Call fetchScore when the app is loaded
  }

  File? _image;
  int selectedPageIndex = 0;
  void logoutUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.login(""); // Clear the username
    authProvider.setLoggedInEmail("");
    authProvider.setscore(0);
    // You can also perform any additional logout actions here
  }

  Future<void> fetchStudentScores() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('https://hbnnarzullayev.pythonanywhere.com/api/studentcores'),
      );
      print(authProvider.username);
      print(authProvider.password);
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Get the directory for saving the file
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/student_scores.xlsx';

        // Write the bytes to an Excel file
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        // Notify the user of success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fayl saqlandi: $filePath'),
          ),
        );
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to fetch data. HTTP status: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (error) {
      // Handle any errors
      print('Error fetching student scores: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download data. Try again later.'),
        ),
      );
    }
  }

  void _exportToExcel(
      List<dynamic> data, String fileName, BuildContext context) async {
    // Request manage external storage permission before proceeding with file operations
    if (await Permission.manageExternalStorage.request().isGranted) {
      // Permission granted, proceed with file operation

      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Add headers
      sheet.appendRow(data[0].keys.toList());

      // Add data
      for (var item in data) {
        sheet.appendRow(item.values.toList());
      }

      // Ask the user to select a directory to save the file
      final result = await FilePicker.platform.getDirectoryPath();

      // If a directory is selected, save the file there
      if (result != null) {
        final filePath = '$result/$fileName.xlsx';
        final file = File(filePath);

        try {
          // Write the file
          await file.writeAsBytes(excel.encode()!);

          // Only show Snackbar if the widget is still mounted
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saqlandi: $filePath')),
            );

            // Share the file
            //Share.shareFiles([filePath], text: 'Excelni ulashish!');
          }

          print('File saved at: $filePath');
        } catch (e) {
          // Handle errors while writing the file
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving file: $e')),
            );
          }
        }
      } else {
        // If no directory was selected
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Directory selection cancelled')),
          );
        }
      }
    } else {
      // If permission is denied, show an error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    }
  }

  void _fetchMineResults(BuildContext context, String password) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse('https://hbnnarzullayev.pythonanywhere.com/api/mine_result'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': authProvider.username,
          'password': password,
          'app_id': 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _exportToExcel(data, 'MyResults', context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Results exported successfully!')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Test natijalarni yuklashda xatolik. Status: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  void _fetchStudentResults(BuildContext context, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://hbnnarzullayev.pythonanywhere.com/api/testscores'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password': password,
          'app_id': 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _exportToExcel(data, 'StudentResults', context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fayl muvaffaqqiyatli saqlandi')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Parol xato bo'lishi mumkin")),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Natijalarni yuklashda xatolik")),
        );
      }
    }
  }

  void _showStudentPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Parolni kiriting'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final password = passwordController.text.trim();
                if (password.isNotEmpty) {
                  _fetchStudentResults(context, password);
                }
              },
              child: const Text(
                'Tasdiqlash',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Bekor qilish',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMineOrStudentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tanlang'),
          content: const Text("Barchaning/shaxsiy test natijalarini yuklash"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchMineResults(context, '12345');
              },
              child: const Text(
                'Shaxsiy',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showStudentPasswordDialog(context);
              },
              child: const Text(
                'Barchaning',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Bekor qilish',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dynamic isAdminValues = userProvider.userrole;
    isAdmins = isAdminValues == 'Admin'; // Corrected role-check logic
    final model = Provider.of<ThemeModel>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          // Add a logout button to the app bar
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test natijalari yangilanmoqda!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/back.jpg'), // Replace with your image asset path
            fit: BoxFit.fill,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black38,
              ),
              accountName: Text(
                userProvider.username?.isNotEmpty == true ? userProvider.username! : 'MEHMON',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                userProvider.userphone?.isNotEmpty == true ? userProvider.userphone! : '+123456789',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture:
              CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://hbnnarzullayev.pythonanywhere.com/static/Image/${userProvider.username}.jpg',
                ),
                onBackgroundImageError: (_, __) {},
                child: Image.asset('assets/images/default.png'), // Fallback image
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black38),
              child: ListTile(
                leading: Icon(
                  Icons.home,
                  color: model.mode == ThemeMode.light
                      ? Colors.white
                      : Colors.lightBlueAccent,
                ),
                title: Text(
                  "Bosh sahifa",
                  style: TextStyle(
                    color: model.mode == ThemeMode.light
                        ? Colors.white
                        : Colors.lightBlueAccent,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black38),
              child: ListTile(
                leading: Icon(
                  Icons.login,
                  color: model.mode == ThemeMode.light
                      ? Colors.white
                      : Colors.lightBlueAccent,
                ),
                title: Text(
                  'Kirish',
                  style: TextStyle(
                    color: model.mode == ThemeMode.light
                        ? Colors.white
                        : Colors.lightBlueAccent,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black38),
              child: ListTile(
                leading: Icon(
                  Icons.change_circle,
                  color: model.mode == ThemeMode.light
                      ? Colors.white
                      : Colors.lightBlueAccent,
                ),
                title: Text(
                  "Profil rasmini o'zgartirish",
                  style: TextStyle(
                    color: model.mode == ThemeMode.light
                        ? Colors.white
                        : Colors.lightBlueAccent,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Profilepages()),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black38),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: model.mode == ThemeMode.light
                      ? Colors.white
                      : Colors.lightBlueAccent,
                ),
                title: Text(
                  'Chiqish',
                  style: TextStyle(
                    color: model.mode == ThemeMode.light
                        ? Colors.white
                        : Colors.lightBlueAccent,
                  ),
                ),
                onTap: () {
                  logoutUser(); // Call the logout function
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Muvaffaqqiyatli chiqish!'),
                    ),
                  );
                },
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
          ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool _obscureText = true; // To toggle the visibility of the password
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController pwdcController = TextEditingController();

  Future<void> registerUser() async {
    final String username = usernameController.text;
    final String email = emailController.text;
    final String password = pwdController.text;
    final String passwordc = pwdcController.text;

    final response = await http.post(
      Uri.parse(
          'https://hbnnarzullayev.pythonanywhere.com/register_app'), // Replace with your Flask API URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'pwd': password,
        'pwdc': passwordc,
        'app_id': '3'
      }),
    );

    if (response.statusCode == 200) {
      // Registration successful, handle the response
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Muvaffaqqiyatli ro'yxatdan o'tish!"),
        ),
      );
      // You can parse and use the response data here
    } else {
      // Registration failed, handle the error

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login yoki parol xato'),
        ),
      );
      // Handle error responses here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ro'yxatdan o'tish"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/back.jpg'), // Replace with your image asset path
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 150,
                child: Image.asset('assets/images/logo-no-background.png'),
              ),
              TextFormField(
                controller: usernameController,
                decoration:
                const InputDecoration(labelText: 'Foydalanuvchi nomi'),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email (Pochta)'),
              ),
              TextFormField(
                controller: pwdController,
                decoration:
                const InputDecoration(labelText: "Maxfiy so'z (Parol)"),
                obscureText: true,
              ),
              TextFormField(
                controller: pwdcController,
                decoration: const InputDecoration(
                    labelText: "Maxfiy so'zni takrorlang"),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: () {
                  // Call the registration function when the button is pressed
                  registerUser();
                },
                child: const Text("Ro'yxatdan o'tish"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final double containerWidthFraction = 0.45;
  final double containerHeightFraction = 0.15;
  const LoginPage({super.key});

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  String username = "";
  String password = "";
  String email = "";
  String adminv = "";

  Future<void> loginUser() async {
    try {
      final url = Uri.parse('https://hbnnarzullayev.pythonanywhere.com/logins');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nma': usernameController.text,
          'pwda': pwdController.text,
          'app_id': 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data');
        setState(() {
          username = data['username'];
          password = data['password'];
          email = data['email'];
          adminv = data['adminv'];
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userToken', 'your_token_here');

        // Update the authProvider here
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.login(username);
        authProvider.setLoggedInEmail(email);

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Muvaffaqqiyatli kirish!'),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );

        // Navigate to other pages after setting the authProvider
        // Example:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => YourNextPage()),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Muvaffaqqiyatsiz!'),
          ),
        );
      }
    } catch (e) {
      // Handle other exceptions (e.g., network issues) here
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login yoki parol xato.$e'),
        ),
      );
    }
  }

  void logoutUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.login(""); // Clear the username
    authProvider.setLoggedInEmail(""); // Clear the email
    // You can also perform any additional logout actions here
  }

  @override
  Widget build(BuildContext context) {
    final double containerWidthFraction = 0.45;
    final double containerHeightFraction = 0.15;
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor:Colors.red,
        foregroundColor: Colors.blue,
        bottomOpacity: 0.1,
        title: Text('Kirish... $username'),
        actions: [
          // Add a logout button to the app bar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              logoutUser(); // Call the logout function
              // Optionally, navigate to the login page or another page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Muvaffaqqiyatli chiqish!'),
                ),
              );
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('userToken');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/back.jpg'), // Replace with your image asset path
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            color: Colors.black38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height *
                      containerHeightFraction *
                      1.2,
                  child: Image.asset('assets/images/logo-no-background.png'),
                ),
                const Padding(padding: EdgeInsets.only(top: 9.0)),
                const Padding(padding: EdgeInsets.only(left: 9.0)),
                TextFormField(
                  controller: usernameController,
                  decoration:
                  const InputDecoration(labelText: 'Foydalanuvchi nomi'),
                ),
                TextFormField(
                  controller: pwdController,
                  decoration:
                  const InputDecoration(labelText: "Maxfiy so'z (Parol)"),
                  obscureText: true,
                ),
                const Padding(padding: EdgeInsets.only(top: 9.0)),
                Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height *
                          containerHeightFraction *
                          0.25,
                      width: MediaQuery.of(context).size.width *
                          containerWidthFraction *
                          0.9,
                      child: ElevatedButton(
                        onPressed: () {
                          // Call the registration function when the button is pressed
                          loginUser();
                          authProvider.login(username);
                          authProvider.setLoggedInEmail(email);
                        },
                        child: const Text('Kirish'),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(left: 9.0)),
                    Container(
                      height: MediaQuery.of(context).size.height *
                          containerHeightFraction *
                          0.25,
                      width: MediaQuery.of(context).size.width *
                          containerWidthFraction *
                          1,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegistrationPage()),
                          );
                        },
                        child: const Text('Registratsiya'),
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 5.0)),
                Container(
                  height: MediaQuery.of(context).size.height *
                      containerHeightFraction *
                      0.25,
                  width: MediaQuery.of(context).size.width *
                      containerWidthFraction *
                      0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage()),
                      );
                    },
                    child: const Text("Bosh sahifa"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class YouTubeVideoListScreen extends StatefulWidget {
  final String groupName; // Add groupName as a required parameter

  const YouTubeVideoListScreen({Key? key, required this.groupName})
      : super(key: key);

  @override
  _YouTubeVideoListScreenState createState() => _YouTubeVideoListScreenState();
}

class _YouTubeVideoListScreenState extends State<YouTubeVideoListScreen> {
  List<Map<String, String>> videos = [];
  bool isLoading = true;
  bool isAdmin = true;
  bool isAdmins = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    fetchVideos(authProvider.username, widget.groupName);
  }

  // Fetch video list from Flask API
  Future<void> fetchVideos(String username, String groupName) async {
    final apiUrl =
        'https://hbnnarzullayev.pythonanywhere.com/get_food_videos?username=$username&app_id=3&groupName=$groupName';
    print(apiUrl);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dynamic isAdminValues = userProvider.userrole;
    isAdmins = isAdminValues == 'Admin'; // Corrected role-check logic
    print('Adminmi: ${isAdmins}');

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode the response body
        final responseData = jsonDecode(response.body);
        // Check if the responseData is a Map or List
        if (responseData is Map<String, dynamic>) {
          // Extract `videos` and `is_admin` from the response
          final List<dynamic> videoData = responseData['video_list'];
          final isAdminValue = responseData['is_admin'];

          setState(() {
            videos = videoData.map((video) {
              return {
                'name': video['name'] as String? ?? 'Unknown Name',
                'url': video['url'] as String? ?? 'Unknown URL',
                'pkey': video['pkey'] as String? ?? 'Unknown pkey',
                'group_name': video['group_name'] as String? ?? 'Unknown Group',
                'video_id': (video['id'] ?? 'Unknown ID').toString(),
              };
            }).toList();
            var isAdminValue = responseData['is_admin'];
            isAdmin = (isAdminValue is bool)
                ? isAdminValue
                : (isAdminValue == 'true');
            isLoading = false;
          });
        } else if (responseData is List<dynamic>) {
          // If responseData is directly a List (videos only)
          setState(() {
            videos = responseData.map((video) {
              return {
                'name': video['name'] as String? ?? 'Unknown Name',
                'url': video['url'] as String? ?? 'Unknown URL',
                'pkey': video['pkey'] as String? ?? 'Unknown pkey',
                'group_name': video['group_name'] as String? ?? 'Unknown Group',
                'video_id': (video['id'] ?? 'Unknown ID').toString(),
              };
            }).toList();

            // Admin status cannot be determined if only a List is returned
            isAdmin = false; // Default assumption
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }

        print('Parsed videos: $videos');
      } else {
        throw Exception('Failed to load video lessons');
      }
    } catch (e) {
      print('Error fetching videos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchVideos_f(String username, String groupName) async {
    final apiUrl =
        'https://hbnnarzullayev.pythonanywhere.com/get_food_videos?username=$username&app_id=3&groupName=$groupName';
    print('Fetching videos from: $apiUrl');

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        // Decode the response body as a List
        final List<dynamic> videoData = jsonDecode(response.body);

        setState(() {
          videos = videoData.map((video) {
            return {
              'name': video['name'] as String? ?? 'Unknown Name',
              'url': video['url'] as String? ?? 'Unknown URL',
              'pkey': video['pkey'] as String? ?? 'Unknown pkey',
              'group_name': video['group_name'] as String? ?? 'Unknown Group',
              'video_id': (video['id'] ?? 'Unknown ID').toString(),
            };
          }).toList();
        });

        print('Parsed videos: $videos');
      } else {
        throw Exception('Failed to fetch videos: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching videos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteVideo(String videourl, videoId) async {
    final authProvider = Provider.of<AuthProvider>(context,
        listen: false); // Get the provider safely
    print("Deleting video with URL: $videourl");

    try {
      final response = await http.delete(
        Uri.parse(
            'https://hbnnarzullayev.pythonanywhere.com/delete_food_video'),
        headers: {
          'Content-Type': 'application/json'
        }, // Ensure the content type is set to JSON
        body: jsonEncode({
          'video_url': videourl,
          'pkey': videoId
        }), // Send video_url in the body
      );

      if (response.statusCode == 200) {
        fetchVideos(authProvider.username, widget.groupName);
        print('Video deleted successfully');
      } else {
        print('Failed to delete video: ${response.body}');
      }
    } catch (e) {
      print('Error deleting video: $e');
    }
  }

  // Function to show confirmation dialog before deleting video
  void _showDeleteConfirmation(String videourl, String videoId) {
    print(videourl);
    print(videoId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Video darsni o'chirish"),
        content: Text("Video darsni o'chirasizmi"),
        actions: [
          TextButton(
            onPressed: () {
              deleteVideo(videourl, videoId);
              print(videourl);
              Navigator.pop(context);
            },
            child: Text(
              'Ha',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Yo'q", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video darsliklar'),
        actions: [
          // Only show the Add Video button if the user is an admin
          if (isAdmins)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Navigate to the Add Video screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVideoPage(
                        groupName:
                        widget.groupName), // Navigate to the Add Video page
                  ),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(5),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Padding(
            padding: EdgeInsets.only(top: 5),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              tileColor: Colors.white30,
              focusColor: Colors.white,
              leading: const Icon(Icons.play_circle_filled),
              title: Text(video['name']!),
              subtitle: Text(video['url']!),
              trailing: isAdmins
                  ? Row(
                mainAxisSize: MainAxisSize
                    .min, // Ensure the row size is minimal
                children: [
                  // Edit button
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to the Edit Video screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditVideoScreen(
                            currentName: video['name'] ?? 'Unknown',
                            currentUrl: video['url'] ?? '',
                            currentvideoId: video['pkey'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmation(
                          video['url']!,
                          video[
                          'pkey']!); // Show confirmation dialog
                    },
                  ),
                ],
              )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YouTubeScreen(
                      videoUrl: video['url']!,
                      name: video['name']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AddVideoGroupPage extends StatefulWidget {
  const AddVideoGroupPage({Key? key}) : super(key: key);

  @override
  State<AddVideoGroupPage> createState() => _AddVideoGroupPageState();
}

class _AddVideoGroupPageState extends State<AddVideoGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  File? _selectedImage;

  // Replace with actual username retrieval

  final String _uploadUrl =
      'https://hbnappdatas.pythonanywhere.com/api/upload_img'; // Flask API

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  List<Map<String, dynamic>> foodGroups = [];
  Future<void> fetchFoodGroups_admin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dynamic username = userProvider.username;
    final dynamic admin = userProvider.userrole;
    bool isLoading = false;
    final url =
        'https://hbnnarzullayev.pythonanywhere.com/get_food_groups_admin?username=$username&app_id=4';
    print(url);

    try {
      bool isAdmin =false;
      bool isLoading = true;
      bool isAdmins = false;
      bool isConnected = true;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> foodGroupsList = data['food_groups_list'] ?? [];
        final dynamic isAdminValue = data['is_admin'];

        // Ensure Provider is accessed correctly
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final dynamic isAdminValues = userProvider.userrole;

        setState(() {
          foodGroups = foodGroupsList.map((group) {
            return {
              'text': group['name'] ?? 'Unknown',
              'groupName': group['group_name'] ?? 'Unknown',
              'image': group['image'] ?? '',
            };
          }).toList();

          // Ensure proper boolean conversion
          isAdmin = isAdminValue is bool ? isAdminValue : (isAdminValue.toString().toLowerCase() == 'true');
          isAdmins = isAdminValues == 'Admin'; // Corrected role-check logic

          isLoading = false;
          print('isAdmins: $isAdmins');
        });
      } else {
        throw Exception('Failed to load food groups');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching food groups: $e');
    }
  }

  Future<void> _uploadData() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide all required inputs.')),
      );
      return;
    }

    final groupName = _groupNameController.text.trim();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dynamic username = userProvider.username;
    final dynamic userid = userProvider.userid;
    print(userid);

    var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
    request.fields['group_name'] = groupName;
    request.fields['username'] = username; // Add username to request
    print(request);
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      _selectedImage!.path,
      filename: path.basename(_selectedImage!.path), // Now correctly calls basename
    ));

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group added successfully!')),
        );
        print('object');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['error'] ?? "Unknown error"}')),
        );
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guruh qo'shish"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(labelText: 'Guruh nomi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Guruh nomini kiriting";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage == null
                      ? const Center(child: Text("Rasm tanlang"))
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadData,
                child: const Text('Saqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditVideoScreen extends StatefulWidget {
  final String currentName;
  final String currentUrl;
  final String currentvideoId; // Add this parameter

  const EditVideoScreen({
    required this.currentName,
    required this.currentUrl,
    required this.currentvideoId,
    Key? key,
  }) : super(key: key);

  @override
  _EditVideoScreenState createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String videoName;
  late String videoUrl;
  late String videoId;
  bool _isLoading = false; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    videoName = widget.currentName;
    videoUrl = widget.currentUrl;
    videoId = widget.currentvideoId;
    print(videoId);
  }

  // Function to edit the video
  Future<void> editVideo() async {
    setState(() {
      _isLoading = true;
    });

    const apiUrl = 'https://hbnnarzullayev.pythonanywhere.com/edit_food_video';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': videoName,
          'url': videoUrl,
          'pkey': videoId,
        }),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video muvaffaqqiyatli tahrirlandi')),
          );
          Navigator.pop(context); // Close the screen
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tahrirlashda xatolik. Status: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video darsni tahrirlash')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
            child: CircularProgressIndicator()) // Show loading indicator
            : Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: videoName,
                decoration:
                const InputDecoration(labelText: 'Video nomi'),
                onChanged: (value) {
                  setState(() {
                    videoName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos video nomini kiriting';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: videoUrl,
                decoration:
                const InputDecoration(labelText: "Video URL(to'liq)"),
                onChanged: (value) {
                  setState(() {
                    videoUrl = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos URLni kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    editVideo();
                  }
                },
                child: const Text('Videoni tahrirlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddVideoPage extends StatefulWidget {
  final String groupName; // Add groupName as a required paramete
  const AddVideoPage({Key? key, required this.groupName}) : super(key: key);
  @override
  _AddVideoPageState createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  final _videoUrlController = TextEditingController();
  final _videoNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> addVideo() async {
    final videoUrl = _videoUrlController.text;
    final videoName = _videoNameController.text;

    if (videoUrl.isEmpty || videoName.isEmpty) {
      // Show error message if any field is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text("Ikala qatorni to'ldirish majburiy"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Replace with your actual Flask app URL
      final response = await http.post(
        Uri.parse('https://hbnnarzullayev.pythonanywhere.com/add_food_video'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'video_url': videoUrl,
          'app_id': 3,
          'name': videoName,
          'groupName': widget.groupName,
        }),
      );

      if (response.statusCode == 200) {
        // Success, show a message or navigate
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Video muvaffaqqiyatli saqlandi!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to previous screen
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Error occurred
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Videoni saqlashda xatolik.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
      // Show error if any exception occurs
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Xatolik yuz berdi'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video dars qo'shish"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _videoUrlController,
              decoration: InputDecoration(labelText: "Video URL(to'liq)"),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _videoNameController,
              decoration: InputDecoration(labelText: 'Video dars nomi'),
            ),
            SizedBox(height: 32),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: addVideo,
              child: Text("Video dars qo'shish"),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId:
      'ca-app-pub-7480088562684396/3085989451', // Replace with your Ad Unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd),
      width: _bannerAd.size.width.toDouble(),
      height: _bannerAd.size.height.toDouble(),
    )
        : SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }
}

class VideoProvider extends ChangeNotifier {
  List<Map<String, dynamic>> videos = [];

  Future<void> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse(
          'https://hbnnarzullayev.pythonanywhere.com/get_food_video'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        videos =
            jsonData.map((video) => Map<String, dynamic>.from(video)).toList();
        notifyListeners(); // Notify UI to update
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error: $e');
    }
  }

  Future<void> likeVideo(int videoId) async {
    await http.post(Uri.parse('https://hbnnarzullayev.pythonanywhere.com/like_video'),
        body: jsonEncode({'video_id': videoId}),
        headers: {'Content-Type': 'application/json'});
    await fetchVideos();
  }

  Future<void> dislikeVideo(int videoId) async {
    await http.post(Uri.parse('https://hbnnarzullayev.pythonanywhere.com/dislike_video'),
        body: jsonEncode({'video_id': videoId}),
        headers: {'Content-Type': 'application/json'});
    await fetchVideos();
  }
}

class VideoReelsScreen extends StatefulWidget {
  @override
  _VideoReelsScreenState createState() => _VideoReelsScreenState();
}

class _VideoReelsScreenState extends State<VideoReelsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoProvider>(context, listen: false).fetchVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    return Scaffold(
      body: videoProvider.videos.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching
          : PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoProvider.videos.length,
        itemBuilder: (context, index) {
          final video = videoProvider.videos[index];
          // return VideoItem(video: video);
        },
      ),
    );
  }
}

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<dynamic> videos = [];
  bool isLoading = true;
  String duration = '';
  String telegramBotToken =
      "7516221487:AAFqLzmU3oC3WYtdSNu3aARWJUimFS-7Naw"; // Replace with your bot token

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://hbnnarzullayev.pythonanywhere.com/get_food_video'),
      );
      if (response.statusCode == 200) {
        setState(() {
          videos = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      print('Error fetching videos: $e');
      setState(() => isLoading = false);
    }
  }

  Future<String> getThumbnail(
      String url, String? platform, String? videoId, String? file_id) async {
    if (url.contains("youtube.com") || url.contains("youtu.be")) {
      duration = await getYouTubeVideoDuration(url);
      return "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
    } else if (url.contains("t.me") && videoId != null && file_id != null) {
      return await getTelegramThumbnail(file_id);
    } else if (isLocalFile(url)) {
      return await getLocalVideoThumbnail(url);
    } else {
      return "https://via.placeholder.com/150";
    }
  }

  bool isLocalFile(String url) {
    return Uri.tryParse(url)?.scheme == null || url.startsWith('/');
  }

  Future<String> getYouTubeVideoDuration(String embedUrl) async {
    try {
      final response = await http.get(Uri.parse(embedUrl));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        print('document:');
        print(document);
        final metaTag = document
            .querySelector('meta[itemprop="duration"]')
            ?.attributes['content'];
        return metaTag ?? 'Unknown Duration';
      }
    } catch (e) {
      print("Error fetching YouTube duration: $e");
    }
    return 'Failed to get duration';
  }

  Future<String> getTelegramThumbnail(String file_id) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.telegram.org/bot$telegramBotToken/getFile?file_id=$file_id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('result') &&
            data['result'].containsKey('file_path')) {
          final filePath = data['result']['file_path'];
          final fileUrl =
              'https://api.telegram.org/file/bot$telegramBotToken/$filePath';

          print("✅ Telegram File URL: $fileUrl");

          return fileUrl;
        } else {
          print("⚠️ Error: 'result' or 'file_path' not found in response");
        }
      } else {
        print(
            "⚠️ Telegram API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching Telegram thumbnail: $e");
    }

    print("⚠️ Returning default image for Telegram");
    return "https://telegram.org/img/t_logo.png"; // Default placeholder
  }

  Future<String> getLocalVideoThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 100,
        quality: 50,
      );
      return thumbnailPath ?? "https://via.placeholder.com/150";
    } catch (e) {
      print("Error generating local video thumbnail: $e");
      return "https://via.placeholder.com/150";
    }
  }

  Map<String, dynamic> parseUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      String host = uri.host;

      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        String? videoId;
        if (host.contains('youtu.be')) {
          videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
        } else {
          videoId = uri.queryParameters['v'];
        }
        return {'platform': 'YouTube', 'videoId': videoId};
      } else if (host.contains('t.me')) {
        return {'platform': 'Telegram'};
      } else if (host.contains('instagram.com')) {
        return {'platform': 'Instagram'};
      } else if (host.contains('facebook.com') || host.contains('fb.com')) {
        return {'platform': 'Facebook'};
      } else {
        return {'platform': 'Unknown'};
      }
    } catch (e) {
      print("Error parsing URL: $e");
      return {'platform': 'Unknown'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video List")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchVideos,
        child: ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            print('video:');
            print(video);
            final String? url = video["url"] as String?;
            final String name =
                video["name"] as String? ?? "Unknown Name";
            final String? platform = video["link_type"]?.toString();
            final Map<String, dynamic> videoData =
            parseUrl(video["url"] ?? "");
            final String? videoId = videoData['videoId'] as String?;
            final String? duration =
            video["duration"]?.toString(); // ✅ FIXED
            final String file_id =
                video["file_id"] as String? ?? "Unknown file_id";
            final String file_url =
                video["file_url"] as String? ?? "Unknown file_id";
            final int totalSeconds =
                int.tryParse(video["duration"]?.toString() ?? "0") ?? 0;

            final int hours = totalSeconds ~/ 3600;
            final int minutes = (totalSeconds % 3600) ~/ 60;
            final int seconds = totalSeconds % 60;

            final String formattedDuration = hours > 0
                ? "$hours h $minutes min $seconds sec"
                : "$minutes min $seconds sec";
            print('duration:');
            print(formattedDuration);
            return FutureBuilder<String>(
              future: getThumbnail(url ?? "", platform ?? "",
                  videoId ?? "", file_id ?? ""),
              builder: (context, snapshot) {
                String thumbnail =
                    snapshot.data ?? "https://via.placeholder.com/150";

                return Column(
                  children: [
                    RecipeCard(
                      title: name,
                      rating: '4.9',
                      cookTime: formattedDuration ??
                          'N/A', // Defaults to 'N/A' if duration is null,
                      thumbnailUrl: thumbnail,
                      onTap: () {
                        if (videoId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Youtube(
                                  Name: name,
                                  videoId: videoId,
                                )),
                          );
                        } else {
                          print("Error: Video ID is null");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoScreen(
                                  linkType: video["link_type"],
                                  name: name,
                                  videoUrl: video["file_url"],
                                )),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoScreen(
                                  linkType: video["link_type"],
                                  name: name,
                                  videoUrl: video["file_url"],
                                )),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class Youtube extends StatefulWidget {
  final String Name;
  final String videoId;

  const Youtube({super.key, required this.videoId, required this.Name});

  @override
  _YoutubeState createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  late YoutubePlayerController _controller;
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    fetchLikes(); // Fetch initial like count
  }

  /// 🔹 **Fetch Initial Like Count from API**
  Future<void> fetchLikes() async {
    const String apiUrl =
        "https://www.pythonanywhere.com/get-likes"; // Replace with your API URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"videoId": widget.videoId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        likeCount = data["likeCount"] ?? 0;
        isLiked = data["liked"] ?? false;
      });
    }
  }

  /// 🔹 **Send Like Data to Flask API**
  Future<void> sendLike() async {
    const String apiUrl =
        "http://your-flask-api.com/like"; // Replace with your Flask API URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "videoId": widget.videoId,
        "liked": isLiked ? 1 : 0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        likeCount = data["likeCount"] ?? 0; // Update like count from API
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.Name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            widget.Name,
            style: const TextStyle(
                fontSize: 25, fontWeight: FontWeight.w600, color: Colors.blue),
          ),
          const SizedBox(height: 5),
          const Text(
            "Tayyorlash tartibi",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.redAccent : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked; // Toggle like state
                  });
                  sendLike(); // Send data to API
                },
              ),
              Text(
                likeCount.toString(),
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  final String name;
  final String videoUrl;
  final String linkType; // "youtube" or "telegram"

  const VideoScreen({
    super.key,
    required this.videoUrl,
    required this.name,
    required this.linkType,
  });

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  bool _showControls = false;
  late Timer _hideControlsTimer;
  YoutubePlayerController? _ytController;
  VideoPlayerController? _tgController;
  bool isLiked = false;
  int likeCount = 0;
  bool isTelegram = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        setState(() {
          _showControls = false;
        });
      });
    }
  }

  void _seekBackward() {
    _controller.seekTo(_controller.value.position - const Duration(seconds: 10));
  }

  void _seekForward() {
    _controller.seekTo(_controller.value.position + const Duration(seconds: 10));
  }

  void _playVideo() {
    _controller.play();
  }

  void _pauseVideo() {
    _controller.pause();
  }

  void _stopVideo() {
    _controller.pause();
    _controller.seekTo(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video'),),
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : const CircularProgressIndicator(),
            ),
            if (_showControls)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.replay_10), onPressed: _seekBackward),
                    IconButton(icon: const Icon(Icons.stop), onPressed: _stopVideo),
                    IconButton(icon: const Icon(Icons.play_arrow), onPressed: _playVideo),
                    IconButton(icon: const Icon(Icons.pause), onPressed: _pauseVideo),
                    IconButton(icon: const Icon(Icons.forward_10), onPressed: _seekForward),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer.cancel();
    super.dispose();
  }
}