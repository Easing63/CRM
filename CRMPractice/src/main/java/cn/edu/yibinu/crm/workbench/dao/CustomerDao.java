package cn.edu.yibinu.crm.workbench.dao;

import cn.edu.yibinu.crm.workbench.domain.Customer;

public interface CustomerDao {

    Customer getCustomerByName(String company);

    int save(Customer cus);
}
