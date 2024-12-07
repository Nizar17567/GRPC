package ma.projet.grpc.controllers;

import io.grpc.stub.StreamObserver;
import ma.projet.grpc.entities.CompteEntity;
import ma.projet.grpc.repository.CompteRepository;
import ma.projet.grpc.stubs.*;
import net.devh.boot.grpc.server.service.GrpcService;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Optional;

@GrpcService
public class CompteServiceImpl extends CompteServiceGrpc.CompteServiceImplBase {

    @Autowired
    private CompteRepository compteRepository;

    @Override
    public void allComptes(GetAllComptesRequest request, StreamObserver<GetAllComptesResponse> responseObserver) {
        GetAllComptesResponse.Builder responseBuilder = GetAllComptesResponse.newBuilder();


        compteRepository.findAll().forEach(compteEntity -> {
            Compte compte = Compte.newBuilder()
                    .setId(compteEntity.getId())
                    .setSolde(compteEntity.getSolde())
                    .setDateCreation(compteEntity.getDateCreation())
                    .setType(TypeCompte.valueOf(compteEntity.getType().name()))
                    .build();
            responseBuilder.addComptes(compte);
        });

        responseObserver.onNext(responseBuilder.build());
        responseObserver.onCompleted();
    }

    @Override
    public void compteById(GetCompteByIdRequest request, StreamObserver<GetCompteByIdResponse> responseObserver) {
        Optional<CompteEntity> optionalCompte = compteRepository.findById(request.getId());

        if (optionalCompte.isPresent()) {
            CompteEntity compteEntity = optionalCompte.get();
            Compte compte = Compte.newBuilder()
                    .setId(compteEntity.getId())
                    .setSolde(compteEntity.getSolde())
                    .setDateCreation(compteEntity.getDateCreation())
                    .setType(TypeCompte.valueOf(compteEntity.getType().name()))
                    .build();

            responseObserver.onNext(GetCompteByIdResponse.newBuilder().setCompte(compte).build());
            responseObserver.onCompleted();
        } else {
            responseObserver.onError(new Throwable("Compte non trouvé"));
        }
    }

    @Override
    public void totalSolde(GetTotalSoldeRequest request, StreamObserver<GetTotalSoldeResponse> responseObserver) {
        int count = (int) compteRepository.count();
        float sum = compteRepository.findAll().stream().map(CompteEntity::getSolde).reduce(0f, Float::sum);
        float average = count > 0 ? sum / count : 0;

        SoldeStats stats = SoldeStats.newBuilder()
                .setCount(count)
                .setSum(sum)
                .setAverage(average)
                .build();

        responseObserver.onNext(GetTotalSoldeResponse.newBuilder().setStats(stats).build());
        responseObserver.onCompleted();
    }

    @Override
    public void saveCompte(SaveCompteRequest request, StreamObserver<SaveCompteResponse> responseObserver) {
        CompteRequest compteReq = request.getCompte();


        CompteEntity compteEntity = new CompteEntity();
        compteEntity.setSolde(compteReq.getSolde());
        compteEntity.setDateCreation(compteReq.getDateCreation());
        compteEntity.setType(ma.projet.grpc.entities.TypeCompte.valueOf(compteReq.getType().name()));

        CompteEntity savedEntity = compteRepository.save(compteEntity);


        Compte compte = Compte.newBuilder()
                .setId(savedEntity.getId())
                .setSolde(savedEntity.getSolde())
                .setDateCreation(savedEntity.getDateCreation())
                .setType(TypeCompte.valueOf(savedEntity.getType().name()))
                .build();

        responseObserver.onNext(SaveCompteResponse.newBuilder().setCompte(compte).build());
        responseObserver.onCompleted();
    }

    @Override
    public void updateCompte(UpdateCompteRequest request, StreamObserver<UpdateCompteResponse> responseObserver) {
        Optional<CompteEntity> optionalCompte = compteRepository.findById(request.getId());

        if (optionalCompte.isPresent()) {
            CompteEntity compteEntity = optionalCompte.get();


            CompteRequest compteReq = request.getCompte();
            compteEntity.setSolde(compteReq.getSolde());
            compteEntity.setDateCreation(compteReq.getDateCreation());
            compteEntity.setType(ma.projet.grpc.entities.TypeCompte.valueOf(compteReq.getType().name()));

            CompteEntity updatedEntity = compteRepository.save(compteEntity);

            
            Compte compte = Compte.newBuilder()
                    .setId(updatedEntity.getId())
                    .setSolde(updatedEntity.getSolde())
                    .setDateCreation(updatedEntity.getDateCreation())
                    .setType(TypeCompte.valueOf(updatedEntity.getType().name()))
                    .build();

            responseObserver.onNext(UpdateCompteResponse.newBuilder().setCompte(compte).build());
            responseObserver.onCompleted();
        } else {
            responseObserver.onError(new Throwable("Compte non trouvé"));
        }
    }

    @Override
    public void deleteCompte(DeleteCompteRequest request, StreamObserver<DeleteCompteResponse> responseObserver) {
        if (compteRepository.existsById(request.getId())) {
            compteRepository.deleteById(request.getId());
            responseObserver.onNext(DeleteCompteResponse.newBuilder().setSuccess(true).build());
            responseObserver.onCompleted();
        } else {
            responseObserver.onError(new Throwable("Compte non trouvé"));
        }
    }
}
