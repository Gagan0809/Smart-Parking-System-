package com.gagan.smartparking.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;

@Document(collection = "parking_slots")
public class ParkingSlot {

    @Id
    private String id;

    private String slotId;
    private String location;
    private String status;
    private Double price;
    private Double latitude;
    private Double longitude;
    private List<String> timeSlots;

    public ParkingSlot() {
    }

    public ParkingSlot(
            String slotId,
            String location,
            String status,
            Double price,
            Double latitude,
            Double longitude,
            List<String> timeSlots) {
        this.slotId = slotId;
        this.location = location;
        this.status = status;
        this.price = price;
        this.latitude = latitude;
        this.longitude = longitude;
        this.timeSlots = timeSlots;
    }

    public String getId() {
        return id;
    }

    public String getSlotId() {
        return slotId;
    }

    public void setSlotId(String slotId) {
        this.slotId = slotId;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Double getPrice() {
        return price;
    }

    public void setPrice(Double price) {
        this.price = price;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public List<String> getTimeSlots() {
        return timeSlots;
    }

    public void setTimeSlots(List<String> timeSlots) {
        this.timeSlots = timeSlots;
    }
}