import 'package:flutter/material.dart';

// ====== موديل المنتج ======
class Product {
  String id;
  String title;
  String category;
  double price;
  String image;
  double rating;
  Product({required this.id, required this.title, required this.category, required this.price, required this.image, this.rating = 4.5});
}

void main() => runApp(HamudiStoreApp());

class HamudiStoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hamudi Store',
      theme: ThemeData(primarySwatch: Colors.amber, scaffoldBackgroundColor: Color(0xFFF5F5F5)),
      home: StoreHome(),
    );
  }
}

class StoreHome extends StatefulWidget {
  @override
  _StoreHomeState createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  // منتجات افتراضية - تكدر تمسحها وتضيف مالك
  List<Product> allProducts = [
    Product(id: '1', title: 'iPhone 15 Pro Max 256GB', category: 'موبايلات', price: 1450000, image: 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400'),
    Product(id: '2', title: 'ساعة ذكية Ultra 8', category: 'الكترونيات', price: 45000, image: 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400'),
    Product(id: '3', title: 'تيشيرت رجالي قطن', category: 'ملابس', price: 15000, image: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400'),
    Product(id: '4', title: 'عطر لطافة فاخر', category: 'عطور', price: 35000, image: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?w=400'),
    Product(id: '5', title: 'خلاط كهربائي', category: 'منزل', price: 75000, image: 'https://images.unsplash.com/photo-1585237672814-8cce9ff6c6d7?w=400'),
    Product(id: '6', title: 'حذاء رياضي نايك', category: 'ملابس', price: 55000, image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400'),
  ];

  List<Product> filtered = [];
  List<Product> cart = [];
  String selectedCategory = 'الكل';
  String searchQuery = '';
  List<String> categories = ['الكل', 'موبايلات', 'الكترونيات', 'ملابس', 'عطور', 'منزل', 'اطفال'];

  @override
  void initState() {
    super.initState();
    filtered = allProducts;
  }

  void filterProducts() {
    setState(() {
      filtered = allProducts.where((p) {
        bool catMatch = selectedCategory == 'الكل' || p.category == selectedCategory;
        bool searchMatch = p.title.toLowerCase().contains(searchQuery.toLowerCase());
        return catMatch && searchMatch;
      }).toList();
    });
  }

  void addToCart(Product p) {
    setState(() => cart.add(p));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت الاضافة للسلة: ${p.title}'), duration: Duration(seconds: 1)));
  }

  void showAddProductDialog() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'الكترونيات');
    final imageCtrl = TextEditingController();

    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('نشر منتج جديد - مثل امازون'),
      content: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'اسم المنتج - مثلا: سماعة بلوتوث')),
          TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'السعر بالدينار - مثلا: 25000'), keyboardType: TextInputType.number),
          TextField(controller: catCtrl, decoration: InputDecoration(labelText: 'القسم: موبايلات، ملابس، عطور...')),
          TextField(controller: imageCtrl, decoration: InputDecoration(labelText: 'رابط الصورة (اختياري)')),
          SizedBox(height: 10),
          Text('اذا ما خليت رابط صورة، راح اخلي صورة افتراضية', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      )),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: Text('إلغاء')),
        ElevatedButton(onPressed: (){
          if(titleCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
          setState(() {
            allProducts.insert(0, Product(
              id: DateTime.now().toString(),
              title: titleCtrl.text,
              category: catCtrl.text.isEmpty ? 'الكل' : catCtrl.text,
              price: double.tryParse(priceCtrl.text) ?? 0,
              image: imageCtrl.text.isEmpty ? 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400' : imageCtrl.text,
            ));
          });
          filterProducts();
          Navigator.pop(context);
        }, child: Text('نشر المنتج')),
      ],
    ));
  }

  void showCart() {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Text('السلة (${cart.length})', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Divider(),
        Expanded(child: cart.isEmpty ? Center(child: Text('السلة فارغة')) : ListView.builder(
          itemCount: cart.length,
          itemBuilder: (_, i) => ListTile(
            leading: Image.network(cart[i].image, width: 50, errorBuilder: (_,__,___)=>Icon(Icons.image)),
            title: Text(cart[i].title, maxLines: 1),
            subtitle: Text('${cart[i].price.toStringAsFixed(0)} د.ع'),
            trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: (){ setState(()=>cart.removeAt(i)); Navigator.pop(context); showCart(); }),
          ),
        )),
        if(cart.isNotEmpty) ...[
          Divider(),
          Text('المجموع: ${cart.fold(0.0, (a,b)=>a+b.price).toStringAsFixed(0)} د.ع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 10),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: Icon(Icons.chat),
            label: Text('اطلب عبر الواتساب'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.all(14)),
            onPressed: (){
              // هنا تربطه برقم واتسابك
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('راح يفتح واتساب برقمك - اربطه بـ url_launcher')));
            },
          )),
        ]
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF131A22),
        title: Row(children: [
          Icon(Icons.shopping_cart, color: Colors.amber),
          SizedBox(width: 8),
          Text('Hamudi Store', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(' | كلشي', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ]),
        actions: [
          Stack(children: [
            IconButton(icon: Icon(Icons.shopping_bag, color: Colors.white), onPressed: showCart),
            if(cart.isNotEmpty) Positioned(right: 0, child: CircleAvatar(radius: 9, backgroundColor: Colors.red, child: Text('${cart.length}', style: TextStyle(fontSize: 10, color: Colors.white)))),
          ]),
        ],
        bottom: PreferredSize(preferredSize: Size.fromHeight(60), child: Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            onChanged: (v){ searchQuery=v; filterProducts(); },
            decoration: InputDecoration(
              hintText: 'ابحث عن اي شي... موبايل، عطر، ملابس',
              filled: true, fillColor: Colors.white,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        )),
      ),
      body: Column(children: [
        // فئات
        Container(height: 45, color: Color(0xFF232F3E), child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: (){ selectedCategory=categories[i]; filterProducts(); },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selectedCategory==categories[i] ? Colors.amber : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30),
              ),
              child: Center(child: Text(categories[i], style: TextStyle(color: selectedCategory==categories[i] ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            ),
          ),
        )),
        // شبكة منتجات
        Expanded(child: GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: filtered.length,
          itemBuilder: (_, i){
            final p = filtered[i];
            return Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(8)), child: Image.network(p.image, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,__,___)=>Container(color: Colors.grey[200], child: Icon(Icons.image, size: 40))))),
                Padding(padding: EdgeInsets.all(6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),
                  Row(children: [Icon(Icons.star, size: 12, color: Colors.amber), Text(' ${p.rating}', style: TextStyle(fontSize: 11)), Spacer(), Container(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), child: Text(p.category, style: TextStyle(fontSize: 9, color: Colors.blue))) ]),
                  SizedBox(height: 4),
                  Text('${p.price.toStringAsFixed(0)} د.ع', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB12704), fontSize: 15)),
                  SizedBox(height: 4),
                  SizedBox(width: double.infinity, height: 28, child: ElevatedButton(onPressed: ()=>addToCart(p), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFD814), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: EdgeInsets.zero), child: Text('أضف للسلة', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
                ])),
              ]),
            );
          },
        )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddProductDialog,
        backgroundColor: Color(0xFF131A22),
        icon: Icon(Icons.add, color: Colors.amber),
        label: Text('نشر منتج جديد', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}