package cn.edu.yibinu.crm.workbench.service;


import cn.edu.yibinu.crm.workbench.domain.Activity;
import cn.edu.yibinu.crm.workbench.domain.Clue;
import cn.edu.yibinu.crm.workbench.domain.Tran;

import java.util.List;

public interface ClueService {


    boolean save(Clue c);

    Clue detail(String id);

    boolean unbound(String relationId);

    boolean bound(String cId, String[] aIds);

    List<Activity> getActivityListByName(String aName);

    boolean convert(String clueId, Tran t, String createBy);
}
