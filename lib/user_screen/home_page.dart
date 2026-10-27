import 'package:flutter/material.dart';
import 'package:task_products_list/core/product_api.dart';
import 'package:task_products_list/model/post_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  List<Product> products = [];
  List<Product> filteredProducts = [];

  late Future<List<Product>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = getProducts();
  }

  void reloadProducts() {
    setState(() {
      productsFuture = getProducts();
    });
  }

  void searchProducts(String value) {
    setState(() {
      filteredProducts = products
          .where(
            (product) => product.title
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.shop),
          )
        ],
        backgroundColor: Colors.grey,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              onChanged: searchProducts,
              decoration: InputDecoration(
                hintText: "Search products",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchProducts("");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Product>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: IconButton(
                      onPressed: reloadProducts,
                      icon: const Icon(
                        Icons.replay_outlined,
                        size: 45,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No data found"),
                  );
                }

                products = snapshot.data!;

                if (filteredProducts.isEmpty &&
                    searchController.text.isEmpty) {
                  filteredProducts = products;
                }

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text("No products found"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 120,
                              width: 100,
                              child: Image.network(
                                product.image ?? "",
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "\$${product.price ?? 0}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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