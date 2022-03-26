package cn.edu.yibinu.crm.workbench.dao;

import cn.edu.yibinu.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    List<ClueRemark> getClueRemarkById(String clueId);
}
