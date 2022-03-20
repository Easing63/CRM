package cn.edu.yibinu.crm.workbench.service.impl;

import cn.edu.yibinu.crm.utils.SqlSessionUtil;
import cn.edu.yibinu.crm.workbench.dao.ActivityDao;
import cn.edu.yibinu.crm.workbench.domain.Activity;
import cn.edu.yibinu.crm.workbench.service.ActivityService;

public class ActivityServiceImpl implements ActivityService {
    private ActivityDao ad = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    @Override
    public boolean save(Activity a) {
        boolean flag = true;
        int count = ad.save(a);     //返回受影响的行数
        if(count != 1){
            flag = false;
        }
        return flag;
    }
}
