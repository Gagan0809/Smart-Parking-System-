package com.gagan.smartparking.repository;

import com.gagan.smartparking.model.ParkingSlot;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ParkingSlotRepository extends MongoRepository<ParkingSlot, String> {
}