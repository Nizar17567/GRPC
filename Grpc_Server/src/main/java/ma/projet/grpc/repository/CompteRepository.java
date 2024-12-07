package ma.projet.grpc.repository;

import ma.projet.grpc.entities.CompteEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CompteRepository extends JpaRepository<CompteEntity, Integer> {

}
