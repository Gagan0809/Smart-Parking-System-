package com.gagan.smartparking;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = {
		"spring.mongodb.uri=mongodb://localhost:27017/smartparking_test",
		"jwt.secret=test-only-jwt-secret-at-least-32-characters-long",
		"jwt.expiration=86400000",
		"iot.device-key=test-only-iot-device-key"
})
class SmartParkingApplicationTests {

	@Test
	void contextLoads() {
	}

}
