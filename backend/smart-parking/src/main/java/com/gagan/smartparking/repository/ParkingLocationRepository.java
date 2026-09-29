package com.gagan.smartparking.repository;

import com.gagan.smartparking.model.ParkingLocation;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface ParkingLocationRepository extends MongoRepository<ParkingLocation, String> {

    Optional<ParkingLocation> findByNameIgnoreCase(String name);

    boolean existsByNameIgnoreCase(String name);
}
