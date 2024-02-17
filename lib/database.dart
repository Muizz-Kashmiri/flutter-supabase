import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({Key? key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  final _textController = TextEditingController();
  final _ageController = TextEditingController();
  late final SupabaseClient supabase;
  var someData = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    getData().then((response) {
      setState(() {
        someData = response as List<Map<String, dynamic>>;
      });
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  void addData(String name) async {
    await supabase.from('People').insert({'name': name});
  }

  void deleteData(int id) async {
    await supabase.from('People').delete().match({'id': id});
  }

  Future<PostgrestList> getData() async {
    final response = await supabase.from('People').select();
    print(response);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: someData.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: someData.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(someData[index]['id']?.toString() ?? ''),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    deleteData(someData[index]['id'] as int? ?? 0);
                    setState(() {
                      someData.removeAt(index);
                    });
                  },
                  direction: DismissDirection.endToStart,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          someData[index]['name'].toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteData(someData[index]['id'] as int? ?? 0);
                            setState(() {
                              someData.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                height: 200,
                child: Column(
                  children: [
                    const Text('Add a new person to the database'),
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        addData(_textController.text);
                        setState(() {
                          someData.add({'name': _textController.text});
                        });
                        _ageController.clear();
                        _textController.clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
