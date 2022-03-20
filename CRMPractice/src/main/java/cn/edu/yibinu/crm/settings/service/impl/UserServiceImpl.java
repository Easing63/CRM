package cn.edu.yibinu.crm.settings.service.impl;

import cn.edu.yibinu.crm.exception.LoginException;
import cn.edu.yibinu.crm.settings.dao.UserDao;
import cn.edu.yibinu.crm.settings.domain.User;
import cn.edu.yibinu.crm.settings.service.UserService;
import cn.edu.yibinu.crm.utils.DateTimeUtil;
import cn.edu.yibinu.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserServiceImpl implements UserService {
    //获得dao对象
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    //打印这个dao对象
    @Override
    public User login(String loginAct, String loginPwd,String ip) throws LoginException {
        Map<String,Object> map = new HashMap<>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);

        User user = userDao.login(map);
        if(user == null){
            throw new LoginException("账号密码异常");
        }

        //程序执行到此，说明账号密码正确，需要继续验证其他三项信息

        //时间
        String expireTime = user.getExpireTime();
        String currentTime = DateTimeUtil.getSysTime();
        if(expireTime.compareTo(currentTime) < 0){
            //时间已失效
            throw new LoginException("时间已失效");
        }

        //锁状态
        String lockState = user.getLockState();
        if("0".equals(lockState)){
            throw new LoginException("账号已锁定");
        }

        //ip地址
        String allowIps = user.getAllowIps();
        if(!allowIps.contains(ip)){
            //数据库中不包含ip地址
            throw new LoginException("ip地址受限");
        }

        return user;
    }

    @Override
    public List<User> getUserList() {
        List<User> uList = userDao.getUserList();
        return uList;
    }

    @Override
    public int getAll() {
        return userDao.getAll();
    }
}
