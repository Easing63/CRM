package cn.edu.yibinu.crm.settings.service;

import cn.edu.yibinu.crm.settings.domain.DicValue;

import java.util.List;
import java.util.Map;

public interface DicService {


    Map<String, List<DicValue>> getAll();
}
