import 'package:chatapp/models/users_model.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<AppUser?> _currentUserFuture;
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _fetchCurrentUser();
    _usersStream = _getAllUsers();
  }

  Future<AppUser?> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  Stream<QuerySnapshot> _getAllUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where(
          'uid',
          isNotEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '',
        )
        .snapshots();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text("Home"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Logout') {
                signOut();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'Logout', child: Text('Logout')),
                ],
          ),
        ],
      ),

      body: FutureBuilder<AppUser?>(
        future: _currentUserFuture,
        builder: (context, currentUserSnapshot) {
          if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!currentUserSnapshot.hasData ||
              currentUserSnapshot.data == null) {
            return const Center(child: Text("No data found"));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder: (context, usersSnapshot) {
              if (usersSnapshot.hasError) {
                return const Center(child: Text('Error loading users'));
              }

              final users =
                  usersSnapshot.data?.docs
                      .map((doc) => AppUser.fromFirestore(doc))
                      .toList() ??
                  [];

              if (users.isEmpty) {
                return const Center(child: Text('No other users found'));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserCard(context, user);
                },
              );
            },
          );
        },
      ),
    );
  }
}

Widget _buildUserCard(BuildContext context, AppUser user) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: InkWell(
      onTap: () => _startChat(context, user),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundImage: NetworkImage("url"),
            radius: 25,
          ),
          title: Text(user.displayName),
          subtitle: Text(user.email),
          trailing: const Icon(Icons.chat),
        ),
      ),
    ),
  );
}

Future<void> _startChat(BuildContext context, AppUser otherUser) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  // create or get existing chat
  final participants = [currentUser.uid, otherUser.uid]..sort();
  final chatId = participants.join('_');

  final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
  final chatSnapshot = await chatRef.get();
  if (!chatSnapshot.exists) {
    await chatRef.set({
      'participants': participants,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'chatName': '${currentUser.displayName ?? ''} & ${otherUser.displayName}',
    });
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => ChatScreen(
            chatId: chatId,
            otherUserId: otherUser.uid,
            otherUserName: otherUser.displayName,
          ),
    ),
  );
}
