package cn.edu.yibinu.crm.workbench.service.impl;


import cn.edu.yibinu.crm.utils.SqlSessionUtil;
import cn.edu.yibinu.crm.utils.UUIDUtil;
import cn.edu.yibinu.crm.workbench.dao.ClueActivityRelationDao;
import cn.edu.yibinu.crm.workbench.dao.ClueDao;
import cn.edu.yibinu.crm.workbench.domain.Clue;
import cn.edu.yibinu.crm.workbench.domain.ClueActivityRelation;
import cn.edu.yibinu.crm.workbench.service.ClueService;


public class ClueServiceImp implements ClueService {
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
    private  ClueActivityRelationDao rDao = SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);

    @Override
    public boolean save(Clue c) {
        boolean flag = true;

        int count = clueDao.save(c);

        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public Clue detail(String id) {
        Clue clue = clueDao.detail(id);

        return clue;
    }

    @Override
    public boolean unbound(String relationId) {
        boolean flag = true;

        int count = clueDao.unbound(relationId);

        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean bound(String cId, String[] aIds) {
        boolean flag = true;
        for(String aId:aIds){
            ClueActivityRelation r = new ClueActivityRelation();
            r.setId(UUIDUtil.getUUID());
            r.setClueId(cId);
            r.setActivityId(aId);

            //这里再循环添加操作
            flag = rDao.bound(r);
        }
        return flag;
    }
}
