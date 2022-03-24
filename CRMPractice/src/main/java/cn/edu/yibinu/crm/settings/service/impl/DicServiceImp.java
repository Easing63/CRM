package cn.edu.yibinu.crm.settings.service.impl;

import cn.edu.yibinu.crm.settings.dao.DicTypeDao;
import cn.edu.yibinu.crm.settings.dao.DicValueDao;
import cn.edu.yibinu.crm.settings.domain.DicType;
import cn.edu.yibinu.crm.settings.domain.DicValue;
import cn.edu.yibinu.crm.settings.service.DicService;
import cn.edu.yibinu.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DicServiceImp implements DicService {
    DicTypeDao dicTypeDao = SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    DicValueDao dicValueDao = SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);

    @Override
    public Map<String, List<DicValue>> getAll() {
        //从tbl_dic_type这张表中查所有然后取code
        List<DicType> dtList = dicTypeDao.getAll();

        //map用来传值回listenler
        Map<String,List<DicValue>> map = new HashMap<>();

        for(DicType dicType:dtList){
            //取code
            String code = dicType.getCode();

            //从tbl_dic_value这张表中根据上面查到的结果分组查value
            List<DicValue> dvList = dicValueDao.getValueByCode(code);

            map.put(code,dvList);
        }
        return map;
    }
}
