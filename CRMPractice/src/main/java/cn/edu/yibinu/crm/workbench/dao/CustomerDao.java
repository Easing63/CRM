package cn.edu.yibinu.crm.workbench.dao;

import cn.edu.yibinu.crm.workbench.domain.Customer;

import java.util.List;

public interface CustomerDao {

    Customer getCustomerByName(String company);

    int save(Customer cus);

    List<String> getCustomerName(String name);
}
