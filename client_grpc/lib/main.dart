import 'package:flutter/material.dart';
import 'compte_service_client.dart';
import 'src/generated/protos/compte.pb.dart';
import 'src/generated/protos/compte.pbgrpc.dart';

void main() {
  runApp(GrpcClientApp());
}

class GrpcClientApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gRPC Client - Comptes Service',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          buttonColor: Colors.deepPurple,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
         
          
        ),
      ),
      home: GrpcHomePage(),
    );
  }
}

class GrpcHomePage extends StatefulWidget {
  @override
  _GrpcHomePageState createState() => _GrpcHomePageState();
}

class _GrpcHomePageState extends State<GrpcHomePage> {
  final GrpcService grpcService = GrpcService();
  late Future<List<Compte>> comptes;
  late Future<GetTotalSoldeResponse> soldeStats;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _soldeController = TextEditingController();
  final TextEditingController _dateCreationController = TextEditingController();
  TypeCompte _type = TypeCompte.COURANT;

  @override
  void initState() {
    super.initState();
    grpcService.createChannel().then((_) {
      refreshComptes();
      soldeStats = grpcService.getTotalSolde();
    });
  }

  void refreshComptes() {
    setState(() {
      comptes = grpcService.getAllComptes();
    });
  }

  @override
  void dispose() {
    grpcService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("gRPC Client - Comptes Service"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddAccountSection(),
              SizedBox(height: 24),
              _buildAllComptesSection(),
              SizedBox(height: 24),
              _buildCompteByIdSection(),
              SizedBox(height: 24),
              _buildDeleteCompteSection(),
             /* SizedBox(height: 24),
              _buildFilterByTypeSection(),*/
              SizedBox(height: 24),
              _buildTotalSoldeSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddAccountSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 12),
            TextField(
              controller: _soldeController,
              decoration: InputDecoration(
                labelText: "Solde",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _dateCreationController,
              decoration: InputDecoration(
                labelText: "Date Creation (YYYY-MM-DD)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<TypeCompte>(
              value: _type,
              onChanged: (TypeCompte? newValue) => setState(() => _type = newValue!),
              items: TypeCompte.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "Account Type",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final compte = CompteRequest()
                  ..solde = double.parse(_soldeController.text)
                  ..dateCreation = _dateCreationController.text
                  ..type = _type;

                grpcService.saveCompte(compte).then((_) => refreshComptes());
              },
              child: Text("Add Account"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllComptesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Comptes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 12),
            FutureBuilder<List<Compte>>(
              future: comptes,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final compte = snapshot.data![index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text('Compte ID: ${compte.id}', style: TextStyle(fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Solde: ${compte.solde}'),
                            Text('Date Creation: ${compte.dateCreation}'),
                            Text('Type: ${compte.type.toString().split('.').last}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompteByIdSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get Compte by ID', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 12),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: "ID",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                grpcService.getCompteById(int.parse(_idController.text)).then((compte) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Compte Found'),
                      content: Text('ID: ${compte.id}\nSolde: ${compte.solde}\nDate: ${compte.dateCreation}\nType: ${compte.type}'),
                    ),
                  );
                });
              },
              child: Text("Get Compte by ID"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteCompteSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete Compte by ID', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 12),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: "ID",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                grpcService.deleteCompte(int.parse(_idController.text)).then((message) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                  refreshComptes();
                });
              },
              child: Text("Delete Compte"),
            ),
          ],
        ),
      ),
    );
  }

 /* Widget _buildFilterByTypeSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Comptes by Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 12),
            DropdownButtonFormField<TypeCompte>(
              value: _type,
              onChanged: (TypeCompte? newValue) => setState(() => _type = newValue!),
              items: TypeCompte.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "Account Type",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => comptes = grpcService.getComptesByType(_type)),
              child: Text("Filter by Type"),
            ),
          ],
        ),
      ),
    );
  }*/

  Widget _buildTotalSoldeSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Solde', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 12),
            FutureBuilder<GetTotalSoldeResponse>(
              future: soldeStats,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final stats = snapshot.data!.stats;
                return Text(
                  'Total: ${stats.sum}, Avg: ${stats.average}',
                  style: TextStyle(fontSize: 18),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
