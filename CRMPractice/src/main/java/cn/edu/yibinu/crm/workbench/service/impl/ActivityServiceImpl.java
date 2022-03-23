package cn.edu.yibinu.crm.workbench.service.impl;

import cn.edu.yibinu.crm.settings.dao.UserDao;
import cn.edu.yibinu.crm.settings.domain.User;
import cn.edu.yibinu.crm.utils.SqlSessionUtil;
import cn.edu.yibinu.crm.vo.ActivityVo;
import cn.edu.yibinu.crm.workbench.dao.ActivityDao;
import cn.edu.yibinu.crm.workbench.dao.ActivityRemarkDao;
import cn.edu.yibinu.crm.workbench.domain.Activity;
import cn.edu.yibinu.crm.workbench.domain.ActivityRemark;
import cn.edu.yibinu.crm.workbench.service.ActivityService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityServiceImpl implements ActivityService {
    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    @Override
    public boolean save(Activity a) {
        boolean flag = true;
        int count = activityDao.save(a);     //返回受影响的行数
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public ActivityVo<Activity> getActivityList(Map<String,Object>map) {
        //获取总记录条数
        int total = activityDao.getTotalByCondition(map);

        //获取满足条件的Activity对象的list
        List<Activity> activityList = activityDao.getActivityListByCondition(map);

        //将total和list封装到vo中
        ActivityVo<Activity> vo = new ActivityVo<>();
        vo.setList(activityList);
        vo.setTotal(total);

        //返回vo
        return vo;
    }

    @Override
    public boolean delete(String[] ids) {
        boolean flag = true;
        //查询出需要删除的备注的数量
        int count1 = activityRemarkDao.getCountByAids(ids);

        //删除备注，返回一个收到影响的条数（实际删除的数量）
        int count2 = activityRemarkDao.deleteByAids(ids);

        if(count1 != count2){
            flag = false;   //查询到的备注数和删除的备注数不同，删除失败
        }
        //删除市场活动
        int count3 = activityDao.delete(ids);
        if(count3 != ids.length){
            flag = false;       //如果删除的市场活动条数和传过去的市场活动数不相同，删除失败
        }
        return flag;
    }

    @Override
    public Map<String, Object> getUserListAndActivity(String id) {
        Map<String,Object> map = new HashMap<>();

        //查询uList对象,这个对象就是查询数据库中所有存在的用户
        List<User> uList = userDao.getUserList();

        //返回一个a，这个a是通过前端的id查到的
        Activity a = activityDao.getActivityById(id);

        map.put("uList",uList);
        map.put("a",a);
        //返回map
        return map;
    }

    @Override
    public boolean update(Activity a) {
        boolean flag = true;
        int count = activityDao.update(a);     //返回受影响的行数
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public Activity detail(String id) {
        //activityDao.getActivityById() 这个sql语句不能使用，以为这是无脑查所有，需求是查到的市场活动是和所有者关联的
        Activity a = activityDao.detail(id);

        return a;
    }

    @Override
    public List<ActivityRemark> getRemarkListById(String activityId) {
        List<ActivityRemark> arList = activityRemarkDao.getRemarkListById(activityId);

        return arList;
    }

    @Override
    public boolean deleteRemark(String id) {
        boolean flag = true;

        int count = activityRemarkDao.deleteRemark(id);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean saveRemark(ActivityRemark ar) {
        boolean flag = true;

        int count = activityRemarkDao.saveRemark(ar);
        if(count != 1){
            flag = false;
        }
        return flag;
    }


}
