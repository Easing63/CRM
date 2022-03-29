package cn.edu.yibinu.crm.workbench.web.controller;

import cn.edu.yibinu.crm.settings.domain.User;
import cn.edu.yibinu.crm.settings.service.UserService;
import cn.edu.yibinu.crm.settings.service.impl.UserServiceImpl;
import cn.edu.yibinu.crm.utils.DateTimeUtil;
import cn.edu.yibinu.crm.utils.PrintJson;
import cn.edu.yibinu.crm.utils.ServiceFactory;
import cn.edu.yibinu.crm.utils.UUIDUtil;
import cn.edu.yibinu.crm.workbench.domain.Tran;
import cn.edu.yibinu.crm.workbench.domain.TranHistory;
import cn.edu.yibinu.crm.workbench.service.CustomerService;
import cn.edu.yibinu.crm.workbench.service.TranService;
import cn.edu.yibinu.crm.workbench.service.impl.CustomerServiceImpl;
import cn.edu.yibinu.crm.workbench.service.impl.TranServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class TranController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到交易控制器");
        String path = request.getServletPath();

        if("/workbench/transaction/add.do".equals(path)){
            add(request,response);
        }else if("/workbench/transaction/getCustomerName.do".equals(path)){
            getCustomerName(request,response);
        }else if("/workbench/transaction/save.do".equals(path)){
            save(request,response);
        }else if("/workbench/transaction/detail.do".equals(path)){
            detail(request,response);
        }else if("/workbench/transaction/getTranHistoryList.do".equals(path)){
            getTranHistoryList(request,response);
        }else if("/workbench/transaction/changeStage.do".equals(path)){
            changeStage(request,response);
        }else if("/workbench/transaction/getCharts.do".equals(path)){
            getCharts(request,response);
        }
    }

    private void getCharts(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("查找stage对应的数量");

        TranService ts = (TranService) ServiceFactory.getService(new TranServiceImpl());
        Map<String,Object> map = ts.getCharts();

        PrintJson.printJsonObj(response,map);
    }

    private void changeStage(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("改变阶段");
        String id = request.getParameter("id");
        String stage = request.getParameter("stage");
        String money = request.getParameter("money");
        String expectedDate = request.getParameter("expectedDate");
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();

        Tran t = new Tran();
        t.setId(id);
        t.setStage(stage);
        t.setMoney(money);
        t.setEditBy(editBy);
        t.setExpectedDate(expectedDate);
        t.setEditTime(editTime);

        //去找可能性
        Map<String,String> pMap = (Map<String,String>)this.getServletContext().getAttribute("pMap");
        t.setPossibility(pMap.get(stage));

        TranService ts = (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = ts.changeStage(t);
        Map<String,Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("tran",t);

        PrintJson.printJsonObj(response,map);


    }

    private void getTranHistoryList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("获取交易历史列表");
        String id = request.getParameter("tranId");

        TranService ts = (TranService) ServiceFactory.getService(new TranServiceImpl());
        List<TranHistory> thList = ts.getTranHistoryList(id);

        //将possibility加给thList中的每一个对象
        Map<String,String> pMap = (Map<String,String>)this.getServletContext().getAttribute("pMap");

        for (TranHistory th : thList){
            String stage = th.getStage();

            //通过stage来在服务器缓存中查找可能性
            String possibility = pMap.get(stage);

            th.setPossibility(possibility);
        }

        //发送json数据给前端
        PrintJson.printJsonObj(response,thList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到请求交易详细页的控制器");
        String id = request.getParameter("tranId");

        TranService ts = (TranService) ServiceFactory.getService(new TranServiceImpl());
        Tran tran = ts.detail(id);

        //同样是从application缓存中取possibility属性
        Map<String,String> pMap = (Map<String, String>) this.getServletContext().getAttribute("pMap");

        String possibility = pMap.get(tran.getStage());
        tran.setPossibility(possibility);

        request.setAttribute("tran",tran);
        //使用转发的原因不仅仅是因为使用了请求域；更重要的是为了在刷新页面的时候，能够再一次获取到后台信息
        //如果使用了重定向，name再次请求的路径是.jsp，是没有数据的
        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request,response);
    }

    private void save(HttpServletRequest request, HttpServletResponse response) throws IOException {
        System.out.println("执行添加交易操作");
        String id = UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String money = request.getParameter("money");
        String name = request.getParameter("name");
        String expectedDate = request.getParameter("expectedDate");
        String customerName = request.getParameter("customerName");     //从前端传回来的只有customer名字，没有id
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String activityId = request.getParameter("activityId");
        String contactsId = request.getParameter("contactsId");
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");

        Tran t = new Tran();
        t.setId(id);
        t.setOwner(owner);
        t.setMoney(money);
        t.setName(name);
        t.setExpectedDate(expectedDate);
        t.setStage(stage);
        t.setType(type);
        t.setSource(source);
        t.setActivityId(activityId);
        t.setContactsId(contactsId);
        t.setCreateBy(createBy);
        t.setCreateTime(createTime);
        t.setDescription(description);
        t.setContactSummary(contactSummary);
        t.setNextContactTime(nextContactTime);

        TranService ts = (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = ts.save(t,customerName);

        //使用重定向，不使用转发：因为没有使用请求域的需求；并且转发的话请求路径没有改变，是请求的.do页面
        response.sendRedirect(request.getContextPath() + "/workbench/transaction/index.jsp");
    }

    private void getCustomerName(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("查询客户名字");
        String name = request.getParameter("name");

        CustomerService cs = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());

        List<String> sList = cs.getCustomerName(name);

        PrintJson.printJsonObj(response,sList);
    }

    private void add(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("获取所有的所有者的名字");
        UserService us = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList = us.getUserList();

        request.setAttribute("uList",uList);
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request,response);
    }
}
