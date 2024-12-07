import 'package:grpc/grpc.dart';
import 'src/generated/protos/compte.pb.dart';
import 'src/generated/protos/compte.pbgrpc.dart';

class GrpcService {
  late ClientChannel channel;
  late CompteServiceClient stub;

  Future<void> createChannel() async {
    channel = ClientChannel(
      '192.168.11.210',
      port: 9090,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = CompteServiceClient(channel);
  }

  // Method to fetch all comptes
  Future<List<Compte>> getAllComptes() async {
    final response = await stub.allComptes(GetAllComptesRequest());
    return response.comptes;
  }

  // Method to fetch compte by ID
  Future<Compte> getCompteById(int id) async {
    final response = await stub.compteById(GetCompteByIdRequest()..id = id);
    return response.compte;
  }

  // Method to fetch total solde stats
  Future<GetTotalSoldeResponse> getTotalSolde() async {
    return await stub.totalSolde(GetTotalSoldeRequest());
  }

  // Method to save a new compte
  Future<Compte> saveCompte(CompteRequest compteRequest) async {
    final response = await stub.saveCompte(SaveCompteRequest()..compte = compteRequest);
    return response.compte;
  }

  // Method to delete a compte
  Future<String> deleteCompte(int id) async {
    final response = await stub.deleteCompte(DeleteCompteRequest()..id = id);
    return response.success ? "Compte deleted successfully" : "Failed to delete compte";
  }

  Future<void> close() async {
    await channel.shutdown();
  }
}
