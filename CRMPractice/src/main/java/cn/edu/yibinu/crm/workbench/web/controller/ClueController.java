package cn.edu.yibinu.crm.workbench.web.controller;

import cn.edu.yibinu.crm.settings.domain.User;
import cn.edu.yibinu.crm.settings.service.UserService;
import cn.edu.yibinu.crm.settings.service.impl.UserServiceImpl;
import cn.edu.yibinu.crm.utils.DateTimeUtil;
import cn.edu.yibinu.crm.utils.PrintJson;
import cn.edu.yibinu.crm.utils.ServiceFactory;
import cn.edu.yibinu.crm.utils.UUIDUtil;
import cn.edu.yibinu.crm.workbench.domain.Activity;
import cn.edu.yibinu.crm.workbench.domain.Clue;
import cn.edu.yibinu.crm.workbench.service.ActivityService;
import cn.edu.yibinu.crm.workbench.service.ClueService;
import cn.edu.yibinu.crm.workbench.service.impl.ActivityServiceImpl;
import cn.edu.yibinu.crm.workbench.service.impl.ClueServiceImp;


import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClueController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到线索控制器");
        String path = request.getServletPath();

        if("/workbench/clue/getUserList.do".equals(path)){
            getUserList(request,response);
        }else if("/workbench/clue/save.do".equals(path)){
            save(request,response);
        }else if("/workbench/clue/detail.do".equals(path)){
            detail(request,response);
        }else if("/workbench/clue/getActivityListByClueId.do".equals(path)){
            getActivityListByClueId(request,response);
        }else if("/workbench/clue/unbound.do".equals(path)){
            unbound(request,response);
        }else if("/workbench/clue/getActivityListByNameNotByClueId.do".equals(path)){
            getActivityListByNameNotByClueId(request,response);
        }else if("/workbench/clue/bound.do".equals(path)){
            bound(request,response);
        }
    }

    private void bound(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行关联市场活动按钮");
        String cId = request.getParameter("cId");
        String[] aIds = request.getParameterValues("aId");

        ClueService cs = (ClueService) ServiceFactory.getService(new ClueServiceImp());

        boolean flag = cs.bound(cId,aIds);
        PrintJson.printJsonFlag(response,flag);
    }

    private void getActivityListByNameNotByClueId(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("添加关联的市场活动");
        String clueId = request.getParameter("clueId");
        String activityName = request.getParameter("activityName");

        //将前端传过来的两个数据打包成map传到后端
        Map<String,String> map = new HashMap<>();
        map.put("clueId",clueId);
        map.put("activityName",activityName);

        ActivityService as = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        List<Activity> aList = as.getActivityListByNameNotByClueId(map);
        PrintJson.printJsonObj(response,aList);

    }

    private void unbound(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("正在接触clue和activity的联系");
        String relationId = request.getParameter("relationId");
        ClueService cs = (ClueService) ServiceFactory.getService(new ClueServiceImp());

        boolean flag = cs.unbound(relationId);
        PrintJson.printJsonFlag(response,flag);
    }

    private void getActivityListByClueId(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("通过clue的id找出与之相关的市场活动列表");
        String clueId = request.getParameter("clueId");

        ActivityService as = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<Activity> aList = as.getActivityListByClueId(clueId);

        //传输给前端
        PrintJson.printJsonObj(response,aList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("请求线索的详情页面");
        ClueService cs = (ClueService) ServiceFactory.getService(new ClueServiceImp());
        //前端传过来了一个id
        String id = request.getParameter("id");

        //请求clue的数据
        Clue clue = cs.detail(id);
        request.setAttribute("c",clue);

        //结果是请求转发给detail.jsp
        request.getRequestDispatcher("/workbench/clue/detail.jsp").forward(request,response);
    }

    private void save(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行添加线索");
        ClueService cs = (ClueService) ServiceFactory.getService(new ClueServiceImp());

        String id = UUIDUtil.getUUID();
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");

        Clue c = new Clue();
        c.setId(id);
        c.setFullname(fullname);
        c.setAppellation(appellation);
        c.setOwner(owner);
        c.setCompany(company);
        c.setJob(job);
        c.setEmail(email);
        c.setPhone(phone);
        c.setWebsite(website);
        c.setMphone(mphone);
        c.setState(state);
        c.setSource(source);
        c.setCreateBy(createBy);
        c.setCreateTime(createTime);
        c.setDescription(description);
        c.setContactSummary(contactSummary);
        c.setNextContactTime(nextContactTime);
        c.setAddress(address);

        boolean flag = cs.save(c);
        PrintJson.printJsonFlag(response,flag);
    }

    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("获取线索模块的局部刷新的拥有者");
        UserService us = (UserService) ServiceFactory.getService(new UserServiceImpl());

        List<User> list = us.getUserList();
        PrintJson.printJsonObj(response,list);
    }
}
