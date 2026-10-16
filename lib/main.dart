import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Items',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ItemsPage(),
    );
  }
}

// Model معدل لإضافة userId
class Item {
  final int userId;
  final int id;
  final String title;
  final String body;

  const Item({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late Future<List<Item>> itemsFuture;

  // متغيرات للتحكم في البحث والفلترة
  String searchQuery = '';
  int? selectedUserId;

  @override
  void initState() {
    super.initState();
    itemsFuture = fetchItems();
  }

  Future<List<Item>> fetchItems() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => Item.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load items: ${response.statusCode}');
    }
  }

  void reloadItems() {
    setState(() {
      itemsFuture = fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items from an API'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: reloadItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 الجزء الخاص بـ Extension 1 & 2 (واجهة البحث والفلترة)
          Container(
            margin: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 1. مربع البحث
                TextField(
                  controller: TextEditingController(text: searchQuery)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: searchQuery.length),
                    ),
                  decoration: InputDecoration(
                    hintText: 'Search by title...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                        });
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // 2. القائمة المنسدلة للفلترة بـ User ID
                DropdownButtonFormField<int?>(
                  value: selectedUserId,
                  decoration: InputDecoration(
                    labelText: 'Filter by Author',
                    prefixIcon: const Icon(Icons.person_search_rounded),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.people_outline, size: 20),
                          SizedBox(width: 8),
                          Text('All Authors'),
                        ],
                      ),
                    ),
                    ...List.generate(
                      10,
                          (index) => DropdownMenuItem<int?>(
                        value: index + 1,
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, size: 20),
                            const SizedBox(width: 8),
                            Text('User ${index + 1}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedUserId = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // 🔹 عرض قائمة العناصر المفلترة
          Expanded(
            child: FutureBuilder<List<Item>>(
              future: itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Could not load items.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: reloadItems,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final rawItems = snapshot.data ?? [];

                // تطبيق شرط الفلترة بالبحث والـ Author
                final filteredItems = rawItems.where((item) {
                  final matchesTitle = item.title
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                  final matchesUser = selectedUserId == null ||
                      item.userId == selectedUserId;
                  return matchesTitle && matchesUser;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Center(child: Text('No matching items found.'));
                }

                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${item.id}')),
                        title: Text(item.title),
                        subtitle: Text(
                          'User ID: ${item.userId}\n${item.body}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}