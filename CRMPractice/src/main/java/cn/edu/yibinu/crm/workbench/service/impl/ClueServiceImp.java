package cn.edu.yibinu.crm.workbench.service.impl;


import cn.edu.yibinu.crm.utils.DateTimeUtil;
import cn.edu.yibinu.crm.utils.SqlSessionUtil;
import cn.edu.yibinu.crm.utils.UUIDUtil;
import cn.edu.yibinu.crm.workbench.dao.*;
import cn.edu.yibinu.crm.workbench.domain.*;
import cn.edu.yibinu.crm.workbench.service.ClueService;

import java.util.List;


public class ClueServiceImp implements ClueService {
    //线索相关表
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
    private  ClueActivityRelationDao clueActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);
    private ClueRemarkDao clueRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ClueRemarkDao.class);

    //市场活动相关表
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    //顾客相关表
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);

    //交易相关表
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private ContactsRemarkDao contactsRemarkDao= SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    private ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);

    //交易相关表
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
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
            flag = clueActivityRelationDao.bound(r);
        }
        return flag;
    }

    @Override
    public List<Activity> getActivityListByName(String aName) {
        List<Activity> aList = activityDao.getActivityListByName(aName);

        return aList;
    }

    @Override
    public boolean convert(String clueId, Tran t, String createBy) {
        String createTime = DateTimeUtil.getSysTime();
        boolean flag = true;
        /*
            (1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
			(2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
			(3) 通过线索对象提取联系人信息，保存联系人
			(4) 线索备注转换到客户备注以及联系人备注
			(5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系
			(6) 如果有创建交易需求，创建一条交易
			(7) 如果创建了交易，则创建一条该交易下的交易历史
			(8) 删除线索备注
			(9) 删除线索和市场活动的关系
			(10) 删除线索
         */
        //(1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
        Clue c = clueDao.getClueById(clueId);

        //(2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
        String company = c.getCompany();
        Customer cus = customerDao.getCustomerByName(company);

        if(cus == null){
            cus = new Customer();
            cus.setId(UUIDUtil.getUUID());
            cus.setAddress(c.getAddress());
            cus.setWebsite(c.getWebsite());
            cus.setPhone(c.getPhone());
            cus.setOwner(c.getOwner());
            cus.setNextContactTime(c.getNextContactTime());
            cus.setName(company);
            cus.setDescription(c.getDescription());
            cus.setCreateTime(createTime);
            cus.setCreateBy(createBy);
            cus.setContactSummary(c.getContactSummary());

            int count1 = customerDao.save(cus);
            if(count1 != 1){
                flag = false;
            }
        }

        //(3) 通过线索对象提取联系人信息，保存联系人
        Contacts con = new Contacts();
        con.setId(UUIDUtil.getUUID());
        con.setOwner(c.getOwner());
        con.setSource(c.getSource());
        con.setCustomerId(cus.getId());
        con.setFullname(c.getFullname());
        con.setAppellation(c.getAppellation());
        con.setEmail(c.getEmail());
        con.setMphone(c.getMphone());
        con.setJob(c.getJob());
        con.setCreateBy(c.getCreateBy());
        con.setCreateTime(c.getCreateTime());
        con.setDescription(c.getDescription());
        con.setContactSummary(c.getContactSummary());
        con.setNextContactTime(c.getNextContactTime());
        con.setAddress(c.getAddress());

        int count2 = contactsDao.save(con);
        if(count2 != 1){
            flag = false;
        }

        //(4) 线索备注转换到客户备注以及联系人备注
        List<ClueRemark> clueRemarkList = clueRemarkDao.getClueRemarkById(clueId);
        for(ClueRemark clueRemark:clueRemarkList){
            //取出备注信息
            String noteContent = clueRemark.getNoteContent();

            //创建客户备注对象
            CustomerRemark customerRemark = new CustomerRemark();
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setNoteContent(noteContent);
            customerRemark.setCreateTime(createTime);
            customerRemark.setCreateBy(createBy);
            customerRemark.setCustomerId(cus.getId());
            customerRemark.setEditFlag("0");
            int count3 = customerRemarkDao.save(customerRemark);
            if(count3 != 1){
                flag = false;
            }

            //添加联系人备注对象
            ContactsRemark contactsRemark = new ContactsRemark();
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setNoteContent(noteContent);
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setCreateBy(createBy);
            contactsRemark.setContactsId(con.getId());
            contactsRemark.setEditFlag("0");

            int count4 = contactsRemarkDao.save(contactsRemark);
            if(count4 != 1){
                flag = false;
            }
        }

        //(5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系
        //查询出和这个线索有关联的市场活动信息列表，所以可以直接根据线索id查找relation的id
        List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getClueActivityRelationByClueId(clueId);
        for (ClueActivityRelation clueActivityRelation:clueActivityRelationList){
            //取得每一条关联关系的activityId
            String activityId = clueActivityRelation.getActivityId();

            //创建“联系人和市场活动”关联对象
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setActivityId(activityId);
            contactsActivityRelation.setContactsId(con.getId());

            int count5 = contactsActivityRelationDao.save(contactsActivityRelation);
            if(count5 != 1){
                flag = false;
            }
        }

        //(6) 如果有创建交易需求，创建一条交易
        if(t!=null){
            //t对象在controller里面已封装了id,money,name,expectedTime,stage,activityId,createBy,createTime
            t.setSource(c.getSource());
            t.setOwner(c.getOwner());
            t.setCustomerId(cus.getId());
            t.setContactSummary(c.getContactSummary());
            t.setNextContactTime(c.getNextContactTime());
            t.setContactsId(con.getId());
            t.setDescription(c.getDescription());

            //添加交易
            int count6 = tranDao.save(t);       //测试没有通过，没有给这个表添加数据
            if(count6 != 1){
                flag = false;
            }
        }
        return flag;
    }

}
