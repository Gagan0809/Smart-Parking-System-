package com.gagan.smartparking.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "parking_locations")
public class ParkingLocation {

    @Id
    private String id;

    private String name;
    private String address;
    private Integer slots;
    private String status;
    private Double latitude;
    private Double longitude;

    public ParkingLocation() {
    }

    public ParkingLocation(
            String name,
            String address,
            Integer slots,
            String status,
            Double latitude,
            Double longitude) {
        this.name = name;
        this.address = address;
        this.slots = slots;
        this.status = status;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Integer getSlots() {
        return slots;
    }

    public void setSlots(Integer slots) {
        this.slots = slots;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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
}
