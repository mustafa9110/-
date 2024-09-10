import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

// الشاشة الرئيسية تحتوي على أزرار للقراء والإدمن
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Login as Admin'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReadOnlyScreen()),
                );
              },
              child: Text('Read Only Mode'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String adminUsername = 'admin';
  String adminPassword = 'password';

  void _login() {
    if (_usernameController.text == adminUsername &&
        _passwordController.text == adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ReadOnlyScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// واجهة القراءة فقط للقارئ العادي
class ReadOnlyScreen extends StatelessWidget {
  final String? pdfPath; // مسار ملف PDF المعدل

  ReadOnlyScreen({this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: pdfPath != null
            ? SfPdfViewer.file(File(pdfPath!)) // عرض الملف المعدل
            : SfPdfViewer.asset('assets/moot.pdf'), // عرض الملف الافتراضي
      ),
    );
  }
}

// واجهة التعديل الخاصة بالإدمن
class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _textController = TextEditingController();
  String extractedText = "هذا النص مستخرج من ملف PDF للتعديل";
  String? _modifiedPdfPath;

  @override
  void initState() {
    super.initState();
    _textController.text = extractedText;
  }

  // وظيفة لحفظ التعديلات كملف PDF جديد
  void _saveAsPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text(_textController.text),
        ],
      ),
    );

    // الحصول على المسار المؤقت
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/edited_document.pdf");

    // حفظ النص المعدل في ملف PDF
    await file.writeAsBytes(await pdf.save());

    setState(() {
      _modifiedPdfPath = file.path; // حفظ مسار الملف المعدل
    });

    // إظهار رسالة نجاح ثم الانتقال تلقائيًا إلى صفحة القارئ
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("تم حفظ التعديل في ملف PDF بنجاح!"),
    ));

    // الانتقال إلى صفحة القارئ وعرض الملف المعدل
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReadOnlyScreen(pdfPath: _modifiedPdfPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Editor'),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: SfPdfViewer.asset('assets/moot.pdf'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Edit PDF Text',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAsPDF,
                  child: Text('Save and View as User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
