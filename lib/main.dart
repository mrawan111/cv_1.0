import 'package:fluent_ui/fluent_ui.dart';
import 'package:firedart/firedart.dart';

const projectId = 'ocrcv-1e6fe';

void main() {
  Firestore.initialize(projectId);
  runApp(const FireStoreApp());
}

class FireStoreApp extends StatelessWidget {
  const FireStoreApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FluentApp(
      title: 'Cloud Firestore Windows',
      home: FireStoreHome(),
    );
  }
}

class FireStoreHome extends StatefulWidget {
  const FireStoreHome({Key? key}) : super(key: key);

  @override
  _FireStoreHomeState createState() => _FireStoreHomeState();
}

class _FireStoreHomeState extends State<FireStoreHome> {
  CollectionReference cvCollection = Firestore.instance.collection('CV');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController docIdController = TextEditingController();

  /// 🔹 **Add New CV (User Input)**
  Future<void> addData(BuildContext context) async {
    if (nameController.text.isEmpty) {
      showSnackbar(context, "⚠ Please enter a name!", Colors.orange);
      return;
    }
    try {
      final newDoc = await cvCollection.add({
        "CV1ForTest": {"Name": nameController.text}
      });
      showSnackbar(context, "✅ Added CV with ID: ${newDoc.id}", Colors.green);
    } catch (e) {
      showSnackbar(context, "❌ Error adding CV: $e", Colors.red);
    }
  }

  /// 🔹 **Retrieve All CVs**
  Future<void> getData(BuildContext context) async {
    try {
      final querySnapshot = await cvCollection.get();

      if (querySnapshot.isEmpty) {
        showSnackbar(context, "📭 No CVs found!", Colors.orange);
        return;
      }

      String records = querySnapshot.map((doc) {
        // Check if the field exists before accessing it
        final data = doc.map;
        String name = data.containsKey("CV1ForTest") && data["CV1ForTest"].containsKey("Name")
            ? data["CV1ForTest"]["Name"]
            : "❓ Unknown Name";

        return "🆔 ID: ${doc.id}, Name: $name";
      }).join("\n");

      showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text("📜 Retrieved CVs"),
          content: SingleChildScrollView(child: Text(records)),
          actions: [
            Button(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

    } catch (e) {
      showSnackbar(context, "❌ Error retrieving CVs: $e", Colors.red);
    }
  }
  /// 🔹 **Update CV (User Input)**
  Future<void> updateData(BuildContext context) async {
    if (docIdController.text.isEmpty || nameController.text.isEmpty) {
      showSnackbar(context, "⚠ Enter document ID & new name!", Colors.orange);
      return;
    }
    try {
      await cvCollection.document(docIdController.text).update({
        "CV1ForTest": {"Name": nameController.text}
      });
      showSnackbar(context, "✅ Updated CV ID: ${docIdController.text}", Colors.orange);
    } catch (e) {
      showSnackbar(context, "❌ Error updating CV: $e", Colors.red);
    }
  }

  /// 🔹 **Delete CV (User Input)**
  Future<void> deleteData(BuildContext context) async {
    if (docIdController.text.isEmpty) {
      showSnackbar(context, "⚠ Enter document ID to delete!", Colors.orange);
      return;
    }
    try {
      await cvCollection.document(docIdController.text).delete();
      showSnackbar(context, "✅ Deleted CV ID: ${docIdController.text}", Colors.green);
    } catch (e) {
      showSnackbar(context, "❌ Error deleting CV: $e", Colors.red);
    }
  }

  /// 🔹 **Show Feedback Messages**
  void showSnackbar(BuildContext context, String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text("Firestore Action"),
        content: Text(message),
        actions: [
          Button(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InfoLabel(
              label: "CV Name:",
              child: TextBox(controller: nameController, placeholder: "Enter Name"),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: "Document ID (for Update/Delete):",
              child: TextBox(controller: docIdController, placeholder: "Enter Doc ID"),
            ),
            const SizedBox(height: 20),
            Button(child: const Text("➕ Add CV"), onPressed: () => addData(context)),
            const SizedBox(height: 10),
            Button(child: const Text("📜 Retrieve All CVs"), onPressed: () => getData(context)),
            const SizedBox(height: 10),
            Button(child: const Text("📝 Update CV"), onPressed: () => updateData(context)),
            const SizedBox(height: 10),
            Button(child: const Text("🗑 Delete CV"), onPressed: () => deleteData(context)),
          ],
        ),
      ),
    );
  }
}
