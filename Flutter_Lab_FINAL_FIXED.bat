@echo off
setlocal
title Flutter Lab Experiment Generator

REM One self-contained BAT file. All question templates are embedded below.
set "FLUTTER_LAB_SELF=%~f0"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$file=$env:FLUTTER_LAB_SELF; $raw=[IO.File]::ReadAllText($file); $marker='### FLUTTER_'+'LAB_PAYLOAD ###'; $pos=$raw.IndexOf($marker,[StringComparison]::Ordinal); if($pos -lt 0){ Write-Host 'ERROR: Embedded Flutter lab content was not found.' -ForegroundColor Red; exit 2 }; $payload=$raw.Substring($pos+$marker.Length); $temp=Join-Path $env:TEMP ('flutter_lab_'+[guid]::NewGuid().ToString()+'.ps1'); [IO.File]::WriteAllText($temp,$payload,[Text.UTF8Encoding]::new($false)); try { & $temp; if($global:FlutterLabExitCode -ne $null){ exit [int]$global:FlutterLabExitCode } else { exit 0 } } finally { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }"

set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" (
  echo.
  echo Flutter Lab generator failed. Review the error above.
  pause
)
exit /b %RESULT%

### FLUTTER_LAB_PAYLOAD ###
$ErrorActionPreference = 'Stop'
$global:FlutterLabExitCode = 0

function New-Experiment {
  param(
    [Parameter(Mandatory=$true)][string]$Question,
    [Parameter(Mandatory=$true)][ValidateSet('A','B')][string]$Part,
    [Parameter(Mandatory=$true)][string]$ProjectPath
  )
$ErrorActionPreference = "Stop"
$code = ""

switch ("$Question$Part") {
"1A" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(
  body: Center(child: Text('Flutter and Dart are installed!')),
)));
'@
}
"1B" {
$code = @'
void main() {
  String studentName = 'Student';
  int questionNumber = 1;
  double percentage = 87.5;
  bool isLearningFlutter = true;
  List<String> topics = ['Variables', 'Data types', 'Functions'];

  print('Name: $studentName');
  print('Question: $questionNumber');
  print('Percentage: $percentage');
  print('Learning Flutter: $isLearningFlutter');
  print('Topics:');
  for (final topic in topics) {
    print('- $topic');
  }
  print('Square of 5 = ${square(5)}');
}

int square(int number) => number * number;
'@
}
"2A" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: WidgetDemo()));

class WidgetDemo extends StatelessWidget {
  const WidgetDemo({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Basic Flutter Widgets')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Text widget', style: TextStyle(fontSize: 24)),
      const SizedBox(height: 12),
      Container(height: 90, color: Colors.blue, alignment: Alignment.center,
        child: const Text('Container', style: TextStyle(color: Colors.white))),
      const SizedBox(height: 12),
      Image.network('https://picsum.photos/500/180',
        height: 140, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80)),
      const ListTile(leading: Icon(Icons.star), title: Text('ListTile widget'),
        subtitle: Text('An example row')),
      const Icon(Icons.flutter_dash, size: 60, color: Colors.blue),
      ElevatedButton(onPressed: () {}, child: const Text('Button')),
    ]),
  );
}
'@
}
"2B" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: LayoutDemo()));

class LayoutDemo extends StatelessWidget {
  const LayoutDemo({super.key});
  Widget tile(String text, Color color) => Container(
    width: 85, height: 65, color: color,
    alignment: Alignment.center, child: Text(text));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Row, Column and Stack')),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ROW', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [tile('One', Colors.orange), tile('Two', Colors.green), tile('Three', Colors.blue)]),
        const SizedBox(height: 24),
        const Text('COLUMN', style: TextStyle(fontWeight: FontWeight.bold)),
        Column(children: [tile('Top', Colors.purple), tile('Middle', Colors.teal), tile('Bottom', Colors.indigo)]),
        const SizedBox(height: 24),
        const Text('STACK', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 150, width: 220, child: Stack(children: [
          Container(width: 200, height: 130, color: Colors.blue.shade100),
          Positioned(right: 0, bottom: 0, child: tile('On top', Colors.red)),
        ])),
      ],
    )),
  );
}
'@
}
"4A" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: HomePage()));

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Navigator Example')),
    body: Center(child: ElevatedButton(
      child: const Text('Open second screen'),
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SecondPage())),
    )),
  );
}
class SecondPage extends StatelessWidget {
  const SecondPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Second Screen')),
    body: Center(child: ElevatedButton(
      child: const Text('Go back'),
      onPressed: () => Navigator.pop(context),
    )),
  );
}
'@
}
"4B" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (_) => const HomePage(),
    '/details': (_) => const DetailsPage(),
  },
));

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Named Routes')),
    body: Center(child: ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/details'),
      child: const Text('Go to details'),
    )),
  );
}
class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Details Screen')),
    body: const Center(child: Text('Opened using the /details named route')),
  );
}
'@
}
"5A" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: WidgetTypesDemo()));

class LabelCard extends StatelessWidget {
  const LabelCard({super.key});
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(padding: EdgeInsets.all(16), child: Text('Stateless: fixed content')),
  );
}
class CounterCard extends StatefulWidget {
  const CounterCard({super.key});
  @override
  State<CounterCard> createState() => _CounterCardState();
}
class _CounterCardState extends State<CounterCard> {
  int count = 0;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    title: Text('Stateful counter: $count'),
    trailing: IconButton(icon: const Icon(Icons.add),
      onPressed: () => setState(() => count++)),
  ));
}
class WidgetTypesDemo extends StatelessWidget {
  const WidgetTypesDemo({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Stateless and Stateful')),
    body: const Column(children: [LabelCard(), CounterCard()]),
  );
}
'@
}
"5B" {
$code = @'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(create: (_) => CounterModel(), child: const MyApp()),
);

class CounterModel extends ChangeNotifier {
  int count = 0;
  void increment() { count++; notifyListeners(); }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Provider State Management')),
      body: Center(child: Consumer<CounterModel>(
        builder: (_, model, __) => Text('Count: ${model.count}',
          style: const TextStyle(fontSize: 28)),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterModel>().increment(),
        child: const Icon(Icons.add),
      ),
    ),
  );
}
'@
}
"6A" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: CustomWidgetDemo()));

class ProfileTile extends StatelessWidget {
  final String name;
  final String role;
  const ProfileTile({super.key, required this.name, required this.role});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: Text(role),
      trailing: const Icon(Icons.arrow_forward_ios),
    ),
  );
}
class CustomWidgetDemo extends StatelessWidget {
  const CustomWidgetDemo({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reusable Custom Widget')),
    body: const Column(children: [
      ProfileTile(name: 'Aarav', role: 'Flutter Developer'),
      ProfileTile(name: 'Diya', role: 'UI Designer'),
    ]),
  );
}
'@
}
"6B" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const ThemeDemo());

class ThemeDemo extends StatelessWidget {
  const ThemeDemo({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),
    ),
    home: Scaffold(
      appBar: AppBar(title: const Text('Theme and Custom Styles')),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Themed heading', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {}, child: const Text('Styled button')),
      ])),
    ),
  );
}
'@
}
"7A" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: RegistrationForm()));

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});
  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}
class _RegistrationFormState extends State<RegistrationForm> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  String course = 'CSE';
  @override
  void dispose() { nameController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Student Registration Form')),
    body: Padding(padding: const EdgeInsets.all(20), child: Form(
      key: formKey,
      child: ListView(children: [
        TextFormField(controller: nameController,
          decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
          validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null),
        const SizedBox(height: 16),
        TextFormField(keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: course, decoration: const InputDecoration(labelText: 'Course'),
          items: ['CSE', 'AIML', 'ECE'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => course = v!)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {
          if (formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registered ${nameController.text} for $course')));
          }
        }, child: const Text('Submit')),
      ]),
    )),
  );
}
'@
}
"7B" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ValidationDemo()));

class ValidationDemo extends StatefulWidget {
  const ValidationDemo({super.key});
  @override
  State<ValidationDemo> createState() => _ValidationDemoState();
}
class _ValidationDemoState extends State<ValidationDemo> {
  final keyForm = GlobalKey<FormState>();
  final password = TextEditingController();
  final confirm = TextEditingController();
  @override
  void dispose() { password.dispose(); confirm.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Validation and Error Handling')),
    body: Padding(padding: const EdgeInsets.all(20), child: Form(
      key: keyForm,
      child: Column(children: [
        TextFormField(controller: password, obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
          validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null),
        TextFormField(controller: confirm, obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm password'),
          validator: (v) => v != password.text ? 'Passwords do not match' : null),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () {
          if (keyForm.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Validation successful!')));
          }
        }, child: const Text('Validate')),
      ]),
    )),
  );
}
'@
}
"8A" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: FadeDemo()));

class FadeDemo extends StatefulWidget {
  const FadeDemo({super.key});
  @override
  State<FadeDemo> createState() => _FadeDemoState();
}
class _FadeDemoState extends State<FadeDemo> {
  bool visible = true;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Fade Animation')),
    body: Center(child: AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 700),
      child: Container(width: 180, height: 180, color: Colors.deepPurple,
        alignment: Alignment.center,
        child: const Text('Fade me', style: TextStyle(color: Colors.white, fontSize: 22))),
    )),
    floatingActionButton: FloatingActionButton(
      onPressed: () => setState(() => visible = !visible),
      child: const Icon(Icons.animation)),
  );
}
'@
}
"8B" {
$code = @'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: SlideDemo()));

class SlideDemo extends StatefulWidget {
  const SlideDemo({super.key});
  @override
  State<SlideDemo> createState() => _SlideDemoState();
}
class _SlideDemoState extends State<SlideDemo> {
  bool show = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Slide Animation')),
    body: Center(child: AnimatedSlide(
      offset: show ? Offset.zero : const Offset(0, 2),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      child: Container(width: 180, height: 100, color: Colors.teal,
        alignment: Alignment.center,
        child: const Text('Sliding widget', style: TextStyle(color: Colors.white))),
    )),
    floatingActionButton: FloatingActionButton(
      onPressed: () => setState(() => show = !show),
      child: const Icon(Icons.swap_vert)),
  );
}
'@
}
default { throw "No code template exists for question $Question part $Part." }
}

# Add Provider dependency only for experiment 5B.
if ("$Question$Part" -eq "5B") {
  Push-Location $ProjectPath
  try {
    & flutter pub add provider
    if ($LASTEXITCODE -ne 0) { throw "Could not install the provider package." }
  }
  finally {
    Pop-Location
  }
}
$lib = Join-Path $ProjectPath "lib"
New-Item -ItemType Directory -Force -Path $lib | Out-Null
Set-Content -Path (Join-Path $lib "main.dart") -Value $code -Encoding UTF8
Write-Host "Created lib/main.dart for question $Question part $Part"
}

Write-Host ''
Write-Host '================================================'
Write-Host '          FLUTTER LAB EXPERIMENT GENERATOR'
Write-Host '================================================'
Write-Host ''
Write-Host 'Choose a question. Both A and B will be generated.'
Write-Host ''
Write-Host '  1. Flutter and Dart SDK / Dart basics'
Write-Host '  2. Flutter widgets / Row, Column and Stack'
Write-Host '  4. Navigator / Named routes'
Write-Host '  5. Stateful and Stateless / setState and Provider'
Write-Host '  6. Custom widgets / Themes and styles'
Write-Host '  7. Forms / Validation and error handling'
Write-Host '  8. Fade and slide animations'
Write-Host ''

$question = Read-Host 'Enter question number (1, 2, 4, 5, 6, 7, 8)'
if ($question -notin @('1','2','4','5','6','7','8')) {
  Write-Host 'Invalid question number. Choose one from the list.' -ForegroundColor Red
  $global:FlutterLabExitCode = 1
}
elseif (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host 'Flutter is not installed or its bin folder is not in PATH.' -ForegroundColor Red
  Write-Host 'Install Flutter first, add its bin folder to PATH, then run: flutter doctor'
  $global:FlutterLabExitCode = 1
}
else {
  $desktop = [Environment]::GetFolderPath('Desktop')
  if ([string]::IsNullOrWhiteSpace($desktop)) {
    $desktop = Join-Path $env:USERPROFILE 'Desktop'
  }

  $root = Join-Path $desktop "FlutterLab\Q$question"
  $partAPath = Join-Path $root 'Part_A'
  $partBPath = Join-Path $root 'Part_B'

  Write-Host ''
  Write-Host 'The two projects will be created here:'
  Write-Host "  $partAPath"
  Write-Host "  $partBPath"
  Write-Host ''

  $existing = (Test-Path $partAPath) -or (Test-Path $partBPath)
  $proceed = $true
  if ($existing) {
    $answer = Read-Host 'These projects already exist. Recreate both folders? (Y/N)'
    if ($answer -notmatch '^(?i)y$') {
      Write-Host 'Cancelled. Existing projects were not changed.'
      $proceed = $false
    }
  }

  if ($proceed) {
    New-Item -ItemType Directory -Path $root -Force | Out-Null

    try {
      foreach ($part in @('A','B')) {
        $projectPath = Join-Path $root "Part_$part"
        $packageName = "q${question}_part_$($part.ToLowerInvariant())"

        Write-Host ''
        Write-Host '================================================'
        Write-Host "Creating Question $question - Part $part"
        Write-Host '================================================'

        if (Test-Path $projectPath) {
          Remove-Item -LiteralPath $projectPath -Recurse -Force
        }

        & flutter create --project-name $packageName --platforms=android,windows $projectPath
        if ($LASTEXITCODE -ne 0) {
          throw "Flutter could not create Part $part. Exit code: $LASTEXITCODE"
        }

        New-Experiment -Question $question -Part $part -ProjectPath $projectPath

        Push-Location $projectPath
        try {
          & flutter pub get
          if ($LASTEXITCODE -ne 0) {
            throw "flutter pub get failed for Part $part. Exit code: $LASTEXITCODE"
          }
        }
        finally {
          Pop-Location
        }
      }

      Write-Host ''
      Write-Host 'Both projects have been generated.'
      Write-Host "Opening: $root"

      if (Get-Command code -ErrorAction SilentlyContinue) {
        Start-Process -FilePath 'code' -ArgumentList @('--new-window', $root)
      }
      else {
        Write-Warning "VS Code command 'code' was not found in PATH. Open this folder manually."
      }

      foreach ($part in @('A','B')) {
        $projectPath = Join-Path $root "Part_$part"
        Write-Host ''
        Write-Host '================================================'
        Write-Host "RUNNING QUESTION $question - PART $part"
        Write-Host '================================================'
        Push-Location $projectPath
        try {
          if ($question -eq '1' -and $part -eq 'B') {
            if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
              Write-Warning 'Dart command was not found. Run this Dart basics program manually with: dart run lib/main.dart'
            }
            else {
              & dart run lib/main.dart
              if ($LASTEXITCODE -ne 0) {
                Write-Warning "Dart run for Part B ended with exit code $LASTEXITCODE."
              }
            }
          }
          else {
            Write-Host 'Press q in this terminal to stop the app and continue to the next part.'
            & flutter run
            if ($LASTEXITCODE -ne 0) {
              Write-Warning "Flutter run for Part $part ended with exit code $LASTEXITCODE."
            }
          }
        }
        finally {
          Pop-Location
        }
      }

      Write-Host ''
      Write-Host 'DONE: Both A and B have been generated and run.'
      Write-Host "Projects: $root"
    }
    catch {
      Write-Host ''
      Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
      Write-Host 'Check flutter doctor, Android SDK setup, licenses, and connected devices.'
      $global:FlutterLabExitCode = 1
    }
  }
}

Read-Host 'Press Enter to close' | Out-Null
