package cn.edu.yibinu.crm.workbench.service;

import cn.edu.yibinu.crm.utils.ServiceFactory;
import cn.edu.yibinu.crm.workbench.service.impl.ClueServiceImp;
import cn.edu.yibinu.crm.workbench.service.impl.TranServiceImpl;
import org.junit.Assert;
import org.junit.Test;

public class TestClueService {
    @Test
    public void testConvert(){
        //测试ClueService的convert方法
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImp());
        System.out.println(clueService.convert("3aa591933b164258a586258f67b2b43f",null,"张三"));
        //clueService.convert("3aa591933b164258a586258f67b2b43f",null,"张三");

    }

//    @Test
//    public void testTranDetail(){
//        TranService tranService = (TranService) ServiceFactory.getService(new TranServiceImpl());
//        System.out.println(tranService.detail("fe12eba0e2ce4f3a8fbbb52b2bb9fc81"));
//    }
}
