package cn.edu.yibinu.crm.web.filter;


import cn.edu.yibinu.crm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        System.out.println("验证是否登录过");

        //用session来判断是否已经登录过了
        //getSession()是HttpServletRequest对象的方法，所以需要强转
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse)resp;

        //防止重复重定向导致的死循环
        User user = (User)request.getSession().getAttribute("user");
        String path = request.getServletPath();
        System.out.println("getServletPath：" + path);
        if("/login.jsp".equals(path) || "/settings/user/login.do".equals(path)){
            //是登录页就要放行
            chain.doFilter(req,resp);
        }else{
            //其他资源必须检验是否放行
            if(user == null){
                //没有登录就重定向到登录页
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }else {
                //登录了就放行
                chain.doFilter(req,resp);
            }
        }
    }
}
