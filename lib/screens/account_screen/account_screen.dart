import 'package:appointment_mgmt_app/consts/colors.dart';
import 'package:appointment_mgmt_app/consts/strings.dart';
import 'package:appointment_mgmt_app/screens/qr_appointment/qrScanner_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    await _auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/auth');
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        List<UserInfo> providerData = user.providerData;
        if (providerData.any((info) => info.providerId == 'password')) {
          String? password = await _askForPassword();
          if (password == null) return; 

          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
        } 

        else if (providerData.any((info) => info.providerId == 'google.com')) {
          GoogleAuthProvider googleProvider = GoogleAuthProvider();
          await user.reauthenticateWithProvider(googleProvider);
        }

        await user.delete();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/auth');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete account. Please try again.")),
      );
    }
  }

  Future<String?> _askForPassword() async {
    String? password;
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: Text("Re-authenticate"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: "Enter your password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), 
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, passwordController.text);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    ).then((value) => password = value);
    return password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _auth.currentUser?.photoURL != null
                          ? NetworkImage(_auth.currentUser!.photoURL!)
                          : null,
                      child: _auth.currentUser?.photoURL == null
                          ? Icon(Icons.account_circle, size: 80, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _auth.currentUser?.displayName ?? "User",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppString.email}: ${_auth.currentUser?.email ?? "No Email"}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: AppColors.blue,
              ),
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text("QR Image", style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => QRScreen()));
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.redAccent,
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Sign Out", style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: _signOut,
            ),
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text("Delete Account", style: TextStyle(color: Colors.red, fontSize: 16)),
              onPressed: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}
