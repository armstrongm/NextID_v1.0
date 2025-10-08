package com.company.iam.repository;

import com.company.iam.model.Group;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GroupRepository extends JpaRepository<Group, Long> {
    Optional<Group> findByName(String name);
    boolean existsByName(String name);
    
    @Query("SELECT g FROM Group g WHERE " +
           "LOWER(g.name) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(g.description) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Group> searchGroups(@Param("search") String search, Pageable pageable);
}