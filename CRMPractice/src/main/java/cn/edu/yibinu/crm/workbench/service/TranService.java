package cn.edu.yibinu.crm.workbench.service;

import cn.edu.yibinu.crm.workbench.domain.Tran;
import cn.edu.yibinu.crm.workbench.domain.TranHistory;

import java.util.List;
import java.util.Map;

public interface TranService {
    boolean save(Tran t, String customerName);

    Tran detail(String id);

    List<TranHistory> getTranHistoryList(String id);

    boolean changeStage(Tran t);

    Map<String, Object> getCharts();
}
