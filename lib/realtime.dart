import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_learn/quote_item.dart';

class RealtimePage extends StatefulWidget {
  const RealtimePage({Key? key}) : super(key: key);

  @override
  State<RealtimePage> createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  late final SupabaseClient supabase;
  var someData = <Map<String, dynamic>>[];
  late final Stream<List<Map<String, dynamic>>> stream;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    stream = supabase.from('Quotes').stream(primaryKey: ['id']);
    print(stream); // Print the value of stream for debugging
    stream.listen((data) {
      print("Stream data: $data"); // Print data from the stream for debugging
      setState(() {
        someData = data;
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }, onError: (error) {
      print("Stream error: $error"); // Print any errors from the stream
    });
  }

  Future<Map<String, dynamic>> fetchQuote() async {
    final response =
        await http.get(Uri.parse('https://animechan.xyz/api/random'));
    print(response);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load quote');
    }
  }

  void addQuote() async {
    final quoteData = await fetchQuote();
    print(quoteData); // Print the quote data for debugging
    final String quote = quoteData['quote'];
    final String author = quoteData['character'];
    final String anime = quoteData['anime'];
    await supabase
        .from('Quotes')
        .insert({'quote': quote, 'author': author, 'anime': anime});
  }

  void deleteQuote(int id) async {
    await supabase.from('Quotes').delete().match({'id': id});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No data available'),
            );
          }
          someData = snapshot.data!;
          return ListView.builder(
            controller: _scrollController,
            itemCount: someData.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Remove the item from the data source.
                  setState(() {
                    someData.removeAt(index);
                  });

                  // Then delete the item from the database.
                  deleteQuote(someData[index]['id'] as int);
                },
                child: QuoteItem(
                  quote: someData[index]['quote'].toString(),
                  author: someData[index]['author'].toString(),
                  anime: someData[index]['anime'].toString(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addQuote();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
