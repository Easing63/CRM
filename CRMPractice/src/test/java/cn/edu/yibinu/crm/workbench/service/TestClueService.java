package cn.edu.yibinu.crm.workbench.service;

import cn.edu.yibinu.crm.utils.ServiceFactory;
import cn.edu.yibinu.crm.workbench.service.impl.ClueServiceImp;
import org.junit.Assert;
import org.junit.Test;

public class TestClueService {
    @Test
    public void testConvert(){
        //测试ClueService的convert方法
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImp());
        System.out.println(clueService.convert("3aa591933b164258a586258f67b2b43f",null,"张三"));
    }
}
