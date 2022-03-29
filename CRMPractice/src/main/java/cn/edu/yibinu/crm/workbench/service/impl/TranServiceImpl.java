package cn.edu.yibinu.crm.workbench.service.impl;

import cn.edu.yibinu.crm.utils.DateTimeUtil;
import cn.edu.yibinu.crm.utils.SqlSessionUtil;
import cn.edu.yibinu.crm.utils.UUIDUtil;
import cn.edu.yibinu.crm.workbench.dao.CustomerDao;
import cn.edu.yibinu.crm.workbench.dao.TranDao;
import cn.edu.yibinu.crm.workbench.dao.TranHistoryDao;
import cn.edu.yibinu.crm.workbench.domain.Customer;
import cn.edu.yibinu.crm.workbench.domain.Tran;
import cn.edu.yibinu.crm.workbench.domain.TranHistory;
import cn.edu.yibinu.crm.workbench.service.TranService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranServiceImpl implements TranService {

    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    @Override
    public boolean save(Tran t, String customerName) {
        boolean flag = true;
        //通过传过来的customerName来精确查找有没有这个id，没有则创建
        Customer cus = null;

        cus = customerDao.getCustomerByName(customerName);

        if(cus == null){
            //说明数据库中没有这个值，需要新建对象
            cus = new Customer();
            cus.setId(UUIDUtil.getUUID());
            cus.setContactSummary(t.getContactSummary());
            cus.setCreateBy(t.getCreateBy());
            cus.setDescription(t.getDescription());
            cus.setName(customerName);
            cus.setOwner(t.getOwner());
            cus.setNextContactTime(t.getNextContactTime());

            int count1 = customerDao.save(cus);
            if(count1 != 1){
                flag = false;
            }
        }

        //这下怎么样都有customer的id了,加入tran对象中
        t.setCustomerId(cus.getId());

        //添加交易到数据库
        int count2 = tranDao.save(t);
        if(count2 != 1){
            flag = false;
        }

        //添加交易历史
        TranHistory th = new TranHistory();

        th.setId(UUIDUtil.getUUID());
        th.setStage(t.getStage());
        th.setTranId(t.getId());
        th.setMoney(t.getMoney());
        th.setExpectedDate(t.getExpectedDate());
        th.setCreateTime(DateTimeUtil.getSysTime());
        th.setCreateBy(t.getCreateBy());

        int count3 = tranHistoryDao.save(th);
        if(count3 != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public Tran detail(String id) {
        Tran tran = tranDao.detail(id);

        return tran;
    }

    @Override
    public List<TranHistory> getTranHistoryList(String id) {
        List<TranHistory> thList = tranHistoryDao.getTranHistoryList(id);

        return thList;
    }

    @Override
    public boolean changeStage(Tran t) {
        boolean flag = true;

        //改变数据库中t的属性
        int count1 = tranDao.changeStage(t);
        if(count1 != 1){
            flag = false;
        }

        //增加一条交易历史
        TranHistory th = new TranHistory();
        th.setMoney(t.getMoney());
        th.setId(UUIDUtil.getUUID());
        th.setExpectedDate(t.getExpectedDate());
        th.setCreateTime(DateTimeUtil.getSysTime());
        th.setCreateBy(t.getEditBy());
        th.setTranId(t.getId());
        th.setStage(t.getStage());

        int count2 = tranHistoryDao.save(th);
        if(count2 != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public Map<String, Object> getCharts() {
        //获得total数
        int total = tranDao.getTotal();

        //获得dataList
        List<Map<String,Object>> dataList = tranDao.getCharts();

        //将两个数据打包到map中返回
        Map<String,Object> map = new HashMap<>();
        map.put("total",total);
        map.put("dataList",dataList);

        return map;
    }
}
