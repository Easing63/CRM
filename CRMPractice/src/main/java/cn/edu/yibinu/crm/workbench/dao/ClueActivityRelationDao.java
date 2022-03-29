package cn.edu.yibinu.crm.workbench.dao;

import cn.edu.yibinu.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationDao {

    boolean bound(ClueActivityRelation r);

    List<ClueActivityRelation> getClueActivityRelationByClueId(String clueId);

    int delete(ClueActivityRelation clueActivityRelation);
}
