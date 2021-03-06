package cn.edu.yibinu.crm.workbench.dao;

import cn.edu.yibinu.crm.workbench.domain.Clue;

public interface ClueDao {


    int save(Clue c);

    Clue detail(String id);

    int unbound(String relationId);

    Clue getClueById(String clueId);

    int delete(String clueId);
}
