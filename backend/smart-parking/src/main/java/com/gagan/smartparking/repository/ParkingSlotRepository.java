package com.gagan.smartparking.repository;

import com.gagan.smartparking.model.ParkingSlot;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface ParkingSlotRepository extends MongoRepository<ParkingSlot, String> {

    boolean existsBySlotIdIgnoreCase(String slotId);

    Optional<ParkingSlot> findBySlotIdIgnoreCase(String slotId);

    long countByLocationIgnoreCase(String location);
}
