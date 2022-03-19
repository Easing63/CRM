package cn.edu.yibinu.crm.settings.web.controller;

import cn.edu.yibinu.crm.settings.domain.User;
import cn.edu.yibinu.crm.settings.service.UserService;
import cn.edu.yibinu.crm.settings.service.impl.UserServiceImpl;
import cn.edu.yibinu.crm.utils.MD5Util;
import cn.edu.yibinu.crm.utils.PrintJson;
import cn.edu.yibinu.crm.utils.ServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class UserController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到用户控制器");
        String path = request.getServletPath();

        if("/settings/user/login.do".equals(path)){
            //说明在请求登录
            login(request,response);
        } else if("/settings/user/xxx.do".equals(path)){
            login(request,response);
        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到验证登录");

        //从前端获取用户名和密码
        String loginAct = request.getParameter("loginAct");
        String loginPwd = request.getParameter("loginPwd");
        //密码还要加密才能识别
        loginPwd = MD5Util.getMD5(loginPwd);

        //还需要获取浏览器端ip地址
        String ip = request.getRemoteAddr();
        System.out.println("========ip=============:" + ip);

        //创建UserService对象
        /*
        *  UserService user = new UserServiceImpl(); 以后的事务可能会添加需求，所以用动态代理的方式来创建UserService对象
         * */
        UserService us = (UserService) ServiceFactory.getService(new UserServiceImpl());
        //在控制器中处理异常
        try{
            User user = us.login(loginAct,loginPwd,ip);
            //然后把user添加到session域中
            request.getSession().setAttribute("user",user);

            //如果执行到此处，那么就说明没有发生异常，输入的数据符合登录成功要求

            //发送数据{"success":true}
            PrintJson.printJsonFlag(response,true);

        }catch (Exception e){
            e.printStackTrace();

            //程序执行到这里了，就说明业务层提供了验证失败，为controller抛出了异常
            //{"success": false, "msg":"xxx"}
            String msg = e.getMessage();
            //错误信息的包装方式：1.封装成map集合；2.封装成一个vo对象：有success和msg属性
            //需求量大就用vo对象，需求量小就用map
            Map<String,Object> map = new HashMap<>();
            map.put("success",false);
            map.put("msg",msg);
            PrintJson.printJsonObj(response,map);
        }
    }
}
