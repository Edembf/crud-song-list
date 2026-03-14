import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBZnUMWgc_2ZmirrqyQh_GE6XqtxRCswAQ",
        authDomain: "songlist-fc95c.firebaseapp.com",
        projectId: "songlist-fc95c",
        storageBucket: "songlist-fc95c.firebasestorage.app",
        messagingSenderId: "876102196332",
        appId: "1:876102196332:web:c724897100c5bdaa844c49"
    ),
  );

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Songs List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SongsListScreen(),
    );
  }
}

class SongsListScreen extends StatefulWidget {
  @override
  _SongsListScreenState createState() => _SongsListScreenState();
}

class _SongsListScreenState extends State<SongsListScreen> {
  final CollectionReference songs = FirebaseFirestore.instance.collection('songs');
  List<Map<String, dynamic>> songsList = [];
  final TextEditingController songController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    QuerySnapshot snapshot = await songs.get();
    setState(() {
      songsList = snapshot.docs.map((doc) => {'id': doc.id, 'title': doc['title']}).toList();
    });
  }

  Future<void> addSong(String title) async {
    await songs.add({'title': title});
    fetchSongs(); // Refresh the list after adding
  }

  Future<void> deleteSong(String id) async {
    await songs.doc(id).delete();
    fetchSongs(); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Songs List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: songController,
              decoration: InputDecoration(
                labelText: 'Enter Song Title',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (songController.text.isNotEmpty) {
                      addSong(songController.text);
                      songController.clear(); // Clear the text field after adding
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: songsList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(songsList[index]['title']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteSong(songsList[index]['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}