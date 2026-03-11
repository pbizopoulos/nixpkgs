import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://localhost:54321',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'build-placeholder',
  );
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _status = 'Ready.';
  String? _userEmail;
  SupabaseClient get _client => Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final response = await _client.auth.getUser();
    setState(() {
      _userEmail = response.user?.email;
    });
  }

  Future<void> _signUp() async {
    setState(() => _status = 'Signing up...');
    final response = await _client.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (response.user == null && response.session == null) {
      setState(() => _status = 'Check your email to confirm the account.');
      return;
    }
    setState(() {
      _status = 'Signed up.';
      _userEmail = response.user?.email;
    });
  }

  Future<void> _signIn() async {
    setState(() => _status = 'Signing in...');
    final response = await _client.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    setState(() {
      _status = response.user == null ? 'Sign in failed.' : 'Signed in.';
      _userEmail = response.user?.email;
    });
  }

  Future<void> _signOut() async {
    setState(() => _status = 'Signing out...');
    await _client.auth.signOut();
    setState(() {
      _status = 'Signed out.';
      _userEmail = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Supabase Auth')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hello World!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _signUp,
                  child: const Text('Sign up'),
                ),
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('Sign in'),
                ),
                OutlinedButton(
                  onPressed: _signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('User: ${_userEmail ?? 'none'}'),
            const SizedBox(height: 8),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
