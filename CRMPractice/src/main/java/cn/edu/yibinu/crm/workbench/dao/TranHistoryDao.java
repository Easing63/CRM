package cn.edu.yibinu.crm.workbench.dao;

import cn.edu.yibinu.crm.workbench.domain.Tran;
import cn.edu.yibinu.crm.workbench.domain.TranHistory;

import java.util.List;

public interface TranHistoryDao {

    int save(TranHistory th);

    List<TranHistory> getTranHistoryList(String id);

}
