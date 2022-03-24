package cn.edu.yibinu.crm.settings.web.listenler;

import cn.edu.yibinu.crm.settings.domain.DicValue;
import cn.edu.yibinu.crm.settings.service.DicService;
import cn.edu.yibinu.crm.settings.service.impl.DicServiceImp;
import cn.edu.yibinu.crm.utils.ServiceFactory;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SysInitListenler implements ServletContextListener {
    //监听那个域就实现那个监听器对象

    //上下文对象创建后就调用该方法
    //even表示能够取得的监听的对象
    @Override
    public void contextInitialized(ServletContextEvent event) {
        System.out.println("上下文监听器启动了");

        ServletContext application = event.getServletContext();

        //从数据库中取出tbl_dic_type中的code字段，再code字段作为参数传给tbl_dic_value查找value和text

        //用service来调用方法来查数据库信息
        DicService ds = (DicService) ServiceFactory.getService(new DicServiceImp());

        //服务器存值的方式：Map<String,List<DicValue>>
        /*
            业务层需要7个List
            可以打包成一个map
            map.put("appellation":dvList1);
            map.put("clueState":dvList2);
            map.put("xxx":dvList3);
            map.put("xxx":dvList4);
            .....
            map.put("xxx":divList7);

         */
        Map<String,List<DicValue>> map = ds.getAll();

        //将map中的键值对解析为域对象中保存的键值对
        Set<String> set = map.keySet();
        for(String key:set){
            //在上下文对象中存值
            application.setAttribute(key,map.get(key));
        }
        System.out.println("上下文监听器结束了");
    }
}
