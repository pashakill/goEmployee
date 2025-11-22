import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  // --- 1. DEKLARASIKAN CONTROLLER ---
  // Buat satu controller untuk setiap TextField
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- 2. TAMBAHKAN DISPOSE ---
  // Selalu dispose controller Anda untuk menghindari kebocoran memori
  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Berhasil!')),
            );
            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
          } else if (state is LoginFailure) {
            // Tampilkan pesan error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login Gagal: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade800, // Hijau tua
                  Colors.green.shade400, // Hijau lebih terang
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ... (Logo dan Judul Anda tetap sama) ...
                    const Icon(
                      Icons.shield_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'GoEmployee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Text(
                      'Silakan login untuk melanjutkan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ... (Form Card Anda tetap sama) ...
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24.0),
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          // --- 3. PASANG CONTROLLER (di pemanggilan widget) ---
                          _buildTextField(
                            label: 'Employee ID',
                            icon: Icons.person_outline,
                            controller: _employeeIdController, // Kirim controller
                          ),
                          const SizedBox(height: 20),

                          _buildPasswordField(
                            controller: _passwordController, // Kirim controller
                          ),
                          const SizedBox(height: 32),

                          _buildLoginButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 3. TERIMA CONTROLLER (di helper method) ---
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller, // Terima controller
  }) {
    return TextField(
      controller: controller, // Pasang controller di sini
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  // --- 3. TERIMA CONTROLLER (di helper method) ---
  Widget _buildPasswordField({
    required TextEditingController controller, // Terima controller
  }) {
    return TextField(
      controller: controller, // Pasang controller di sini
      style: const TextStyle(color: Colors.white),
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  // --- Widget Helper untuk Tombol Login ---
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green.shade800,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: () async {
          /*
          LOGIC JIKA DISURUH MEMBUAT USER DARI DATA OFFLINE
          final String username = _employeeIdController.text;
          final String password = _passwordController.text;

          if (username.isEmpty || password.isEmpty) {
            showAppSnackBar(context, 'Username atau Password tidak boleh kosong.', SnackBarType.error);
            return;
          }

          // --- MULAI DARI SINI ---

          // 1.  memanggil helper dengan username & password
          final dbHelper = DatabaseHelper.instance;
          final User? user = await dbHelper.getUserLogin(username, password);

          // 2.  mengecek apakah 'user' ada (login berhasil)
          if (user != null) {

            // --- LOGIN BERHASIL ---
            // 'user' adalah OBJEK LENGKAP dari database (hasil SELECT)
            // Isinya: user.id, user.nama, user.username, user.role, dll.

            // 3. INI JAWABANNYA: Ambil 'id' dari objek 'user'
            // 'user.id' ini adalah 'user_id' yang Anda cari
            final int? userId = user.id;

            // 4. Cek apakah ID-nya valid
            if (userId != null) {

              await SessionManager().saveSession(userId.toString());

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }
            } else {
              // (Skenario error jika id dari db null)
              showAppSnackBar(context, 'Login gagal: ID user tidak valid.', SnackBarType.error);
            }
          } else {
            // --- LOGIN GAGAL ---
            // 'user' adalah null karena tidak ada data yang cocok
            showAppSnackBar(context, 'Username atau Password salah.', SnackBarType.error);
          }

           */


          // --- 4. BACA TEXT DARI CONTROLLER ---
          // Gunakan .text untuk mendapatkan nilai string-nya
          final String username = _employeeIdController.text;
          final String password = _passwordController.text;

          // Sekarang Anda bisa gunakan variabel ini
          print('--- Tombol Login Ditekan ---');
          print('Employee ID: $username');
          print('Password: $password'); // <-- Jangan print password di production!

          // Contoh validasi sederhana
          if (username.isEmpty) {

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Employee ID tidak boleh kosong!', style: TextStyle(color: Colors.black),),
                backgroundColor: Colors.white, // Beri warna untuk error
                duration: Duration(seconds: 2), // Tampilkan selama 2 detik
              ),
            );

            return;
          }

          if(password.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password tidak boleh kosong!', style: TextStyle(color: Colors.black),),
                backgroundColor: Colors.white, // Beri warna untuk error
                duration: Duration(seconds: 2), // Tampilkan selama 2 detik
              ),
            );
            return;
          }
          context.read<LoginBloc>().add(
            LoginButtonPressed(
              password: _passwordController.text, username: _employeeIdController.text,
            ),
          );
          /*
          final newUser = User(
            nama: "Barry Vasyah S.kom, M.Kom",
            username: username,
            password: password,
            companyName: "PT.Jatelindo Perkasa Abadi",
            role: "Dosen",
            dateNow: DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now()),
            jadwalMulaiKerja: '08:00',
            jadwalSelesaiKerja: '17:00'
          );


          // 2. Panggil DatabaseHelper untuk insert
          try {
            final dbHelper = DatabaseHelper.instance;
            int userId = await dbHelper.insertUser(newUser);
            await SessionManager().saveSession(userId.toString());
            print("Sukses! User baru '$userId - ${newUser.nama}' berhasil disimpan.");
            // TODO: Navigasi ke halaman home
            AppNavigator.offAll(Routes.home);
          } catch (e) {
            print("Gagal menyimpan user: $e");

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal menyimpan data user',
                  style: TextStyle(color: Colors.black),),
                backgroundColor: Colors.white,
                duration: Duration(seconds: 2),
              ),
            );
          }
           */
        },
        child: const Text(
          'LOGIN',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}