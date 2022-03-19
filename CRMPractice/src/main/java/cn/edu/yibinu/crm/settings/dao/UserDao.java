package cn.edu.yibinu.crm.settings.dao;

import cn.edu.yibinu.crm.settings.domain.User;

import java.util.Map;

public interface UserDao {
    User login(Map<String, Object> map);
}
