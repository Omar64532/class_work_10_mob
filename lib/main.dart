import 'package:flutter/material.dart';
import 'database.dart';

void main() {
  runApp(CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FolderScreen(),
    );
  }
}

class FolderScreen extends StatefulWidget {
  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  late Future<List<Map<String, dynamic>>> _foldersFuture;

  @override
  void initState() {
    super.initState();
    _foldersFuture = CardDatabase.instance.getFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Organizer'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _foldersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No folders found.'));
          }

          final folders = snapshot.data!;

          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return ListTile(
                title: Text(folder['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardScreen(folderId: folder['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CardScreen extends StatefulWidget {
  final int folderId;

  CardScreen({required this.folderId});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  late Future<List<Map<String, dynamic>>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _cardsFuture = CardDatabase.instance.getCardsInFolder(widget.folderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cards found.'));
          }

          final cards = snapshot.data!;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(card['imageUrl'], height: 100),
                    Text(card['name']),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
