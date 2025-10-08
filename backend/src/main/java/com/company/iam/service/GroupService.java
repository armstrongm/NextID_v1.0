package com.company.iam.service;

import com.company.iam.dto.GroupDTO;
import com.company.iam.model.Group;
import com.company.iam.repository.GroupRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class GroupService {

    @Autowired
    private GroupRepository groupRepository;

    public Page<GroupDTO> findAll(String search, Pageable pageable) {
        Page<Group> groups;
        
        if (search != null && !search.trim().isEmpty()) {
            groups = groupRepository.searchGroups(search.trim(), pageable);
        } else {
            groups = groupRepository.findAll(pageable);
        }
        
        return groups.map(GroupDTO::fromEntity);
    }

    public GroupDTO findById(Long id) {
        Group group = groupRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Group not found with id: " + id));
        return GroupDTO.fromEntity(group);
    }

    @Transactional
    public GroupDTO create(GroupDTO groupDTO) {
        if (groupRepository.existsByName(groupDTO.getName())) {
            throw new RuntimeException("Group name already exists");
        }

        Group group = new Group();
        group.setName(groupDTO.getName());
        group.setDescription(groupDTO.getDescription());

        Group savedGroup = groupRepository.save(group);
        return GroupDTO.fromEntity(savedGroup);
    }

    @Transactional
    public GroupDTO update(Long id, GroupDTO groupDTO) {
        Group group = groupRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Group not found with id: " + id));

        if (!group.getName().equals(groupDTO.getName()) && 
            groupRepository.existsByName(groupDTO.getName())) {
            throw new RuntimeException("Group name already exists");
        }

        group.setName(groupDTO.getName());
        group.setDescription(groupDTO.getDescription());

        Group updatedGroup = groupRepository.save(group);
        return GroupDTO.fromEntity(updatedGroup);
    }

    @Transactional
    public void delete(Long id) {
        if (!groupRepository.existsById(id)) {
            throw new RuntimeException("Group not found with id: " + id);
        }
        groupRepository.deleteById(id);
    }

    public long count() {
        return groupRepository.count();
    }
}