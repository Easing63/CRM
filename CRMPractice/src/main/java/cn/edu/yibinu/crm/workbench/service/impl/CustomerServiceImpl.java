package cn.edu.yibinu.crm.workbench.service.impl;

import cn.edu.yibinu.crm.utils.SqlSessionUtil;
import cn.edu.yibinu.crm.workbench.dao.CustomerDao;
import cn.edu.yibinu.crm.workbench.service.CustomerService;

import java.util.List;

public class CustomerServiceImpl implements CustomerService {
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);

    @Override
    public List<String> getCustomerName(String name) {
        List<String> sList = customerDao.getCustomerName(name);

        return sList;
    }
}
