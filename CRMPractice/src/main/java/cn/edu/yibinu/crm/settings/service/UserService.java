package cn.edu.yibinu.crm.settings.service;

import cn.edu.yibinu.crm.settings.domain.User;

public interface UserService {
    User login(String loginAct, String loginPwd);
}
