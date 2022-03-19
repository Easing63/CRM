package cn.edu.yibinu.crm.web.filter;

import javax.servlet.*;
import java.io.IOException;

public class EncodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        System.out.println("进入到中文乱码的过滤器");

        //处理请求的中文乱码
        req.setCharacterEncoding("UTF-8");
        //处理响应中文乱码
        resp.setContentType("text/html;charset=utf-8");
        //将请求放行
        chain.doFilter(req,resp);
    }
}
