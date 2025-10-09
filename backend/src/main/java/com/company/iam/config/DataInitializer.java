package com.company.iam.config;

import com.company.iam.model.AuthUser;
import com.company.iam.repository.AuthUserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @Autowired
    private AuthUserRepository authUserRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        logger.info("Checking for admin user...");

        if (!authUserRepository.existsByUsername("admin")) {
            logger.info("Creating default admin user...");

            AuthUser admin = new AuthUser();
            admin.setUsername("admin");
            admin.setEmail("admin@iam.local");
            admin.setPasswordHash(passwordEncoder.encode("admin123"));
            admin.setRole(AuthUser.Role.ADMIN);
            admin.setEnabled(true);

            authUserRepository.save(admin);
            logger.info("✓ Default admin user created successfully");
            logger.info("  Username: admin");
            logger.info("  Password: admin123");
        } else {
            logger.info("Admin user already exists");
        }

        logger.info("Total users in database: {}", authUserRepository.count());
    }
}