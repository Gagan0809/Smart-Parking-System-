package com.gagan.smartparking.config;

import com.gagan.smartparking.security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.CsrfConfigurer;
import org.springframework.security.config.annotation.web.configurers.FormLoginConfigurer;
import org.springframework.security.config.annotation.web.configurers.HttpBasicConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        configuration.setAllowedOrigins(List.of("*"));
        configuration.setAllowedMethods(List.of(
                "GET",
                "POST",
                "PUT",
                "DELETE",
                "OPTIONS"
        ));
        configuration.setAllowedHeaders(List.of("*"));

        UrlBasedCorsConfigurationSource source =
                new UrlBasedCorsConfigurationSource();

        source.registerCorsConfiguration("/**", configuration);

        return source;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) {
        http
                .csrf(CsrfConfigurer::disable)

                .cors(cors ->
                        cors.configurationSource(
                                corsConfigurationSource()
                        )
                )

                .formLogin(FormLoginConfigurer::disable)

                .httpBasic(HttpBasicConfigurer::disable)

                .sessionManagement(session ->
                        session.sessionCreationPolicy(
                                SessionCreationPolicy.STATELESS
                        )
                )

                .authorizeHttpRequests(auth -> auth

                        // Public user authentication endpoints
                        .requestMatchers(
                                "/api/users/register",
                                "/api/users/login",
                                "/api/admin/login"
                        ).permitAll()

                        // IoT endpoints:
                        // Spring Security allows the request through.
                        // IotController validates X-IOT-KEY.
                        .requestMatchers("/api/iot/**")
                        .permitAll()

                        // WebSocket handshake endpoint
                        .requestMatchers("/ws/**")
                        .permitAll()

                        // Parking slot access
                        .requestMatchers(
                                HttpMethod.GET,
                                "/api/parking-slots"
                        )
                        .authenticated()

                        // Parking slot creation
                        .requestMatchers(
                                HttpMethod.POST,
                                "/api/parking-slots"
                        )
                        .hasRole("ADMIN")

                        // Parking slot update
                        .requestMatchers(
                                HttpMethod.PUT,
                                "/api/parking-slots/**"
                        )
                        .hasRole("ADMIN")

                        // Parking slot deletion
                        .requestMatchers(
                                HttpMethod.DELETE,
                                "/api/parking-slots/**"
                        )
                        .hasRole("ADMIN")

                        // All remaining admin endpoints
                        .requestMatchers("/api/admin/**")
                        .hasRole("ADMIN")

                        // Everything else requires JWT authentication
                        .anyRequest()
                        .authenticated()
                )

                .addFilterBefore(
                        jwtAuthenticationFilter,
                        UsernamePasswordAuthenticationFilter.class
                );

        return http.build();
    }
}