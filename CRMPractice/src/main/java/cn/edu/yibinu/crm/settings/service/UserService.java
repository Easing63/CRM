package cn.edu.yibinu.crm.settings.service;

import cn.edu.yibinu.crm.settings.domain.User;

import javax.security.auth.login.LoginException;

public interface UserService {
    User login(String loginAct, String loginPwd,String ip) throws LoginException;
}
