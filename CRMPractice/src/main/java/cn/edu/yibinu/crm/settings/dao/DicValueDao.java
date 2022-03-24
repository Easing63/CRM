package cn.edu.yibinu.crm.settings.dao;

import cn.edu.yibinu.crm.settings.domain.DicValue;

import java.util.List;

public interface DicValueDao {
    List<DicValue> getValueByCode(String code);
}
