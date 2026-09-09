package com.gagan.smartparking.controller;

import com.gagan.smartparking.model.ParkingSlot;
import com.gagan.smartparking.repository.ParkingSlotRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/parking-slots")
@CrossOrigin(origins = "*")
public class ParkingSlotController {

    private final ParkingSlotRepository parkingSlotRepository;

    public ParkingSlotController(ParkingSlotRepository parkingSlotRepository) {
        this.parkingSlotRepository = parkingSlotRepository;
    }

    @GetMapping
    public ResponseEntity<List<ParkingSlot>> getAllSlots() {
        return ResponseEntity.ok(parkingSlotRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<ParkingSlot> addSlot(@RequestBody ParkingSlot parkingSlot) {
        ParkingSlot savedSlot = parkingSlotRepository.save(parkingSlot);
        return ResponseEntity.ok(savedSlot);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ParkingSlot> updateSlot(
            @PathVariable String id,
            @RequestBody ParkingSlot updatedSlot) {

        Optional<ParkingSlot> existingSlot =
                parkingSlotRepository.findById(id);

        if (existingSlot.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ParkingSlot slot = existingSlot.get();
        slot.setSlotId(updatedSlot.getSlotId());
        slot.setLocation(updatedSlot.getLocation());
        slot.setStatus(updatedSlot.getStatus());

        return ResponseEntity.ok(parkingSlotRepository.save(slot));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSlot(@PathVariable String id) {

        if (!parkingSlotRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        parkingSlotRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}