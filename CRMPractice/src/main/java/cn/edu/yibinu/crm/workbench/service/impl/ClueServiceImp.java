package cn.edu.yibinu.crm.workbench.service.impl;


import cn.edu.yibinu.crm.utils.SqlSessionUtil;
import cn.edu.yibinu.crm.workbench.dao.ClueDao;
import cn.edu.yibinu.crm.workbench.domain.Clue;
import cn.edu.yibinu.crm.workbench.service.ClueService;


public class ClueServiceImp implements ClueService {
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);


    @Override
    public boolean save(Clue c) {
        boolean flag = true;

        int count = clueDao.save(c);

        if(count != 1){
            flag = false;
        }
        return flag;
    }
}
