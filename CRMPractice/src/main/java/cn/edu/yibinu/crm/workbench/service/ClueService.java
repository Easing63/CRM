package cn.edu.yibinu.crm.workbench.service;


import cn.edu.yibinu.crm.workbench.domain.Clue;

public interface ClueService {


    boolean save(Clue c);

    Clue detail(String id);

    boolean unbound(String relationId);

    boolean bound(String cId, String[] aIds);
}
