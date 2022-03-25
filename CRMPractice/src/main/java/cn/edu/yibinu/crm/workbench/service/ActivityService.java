package cn.edu.yibinu.crm.workbench.service;

import cn.edu.yibinu.crm.vo.ActivityVo;
import cn.edu.yibinu.crm.workbench.domain.Activity;
import cn.edu.yibinu.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityService {

    boolean save(Activity a);

    ActivityVo<Activity> getActivityList(Map<String,Object> map);

    boolean delete(String[] ids);

    Map<String, Object> getUserListAndActivity(String id);

    boolean update(Activity a);

    Activity detail(String id);

    List<ActivityRemark> getRemarkListById(String activityId);

    boolean deleteRemark(String id);

    boolean saveRemark(ActivityRemark ar);

    boolean updateRemark(ActivityRemark ar);

    List<Activity> getActivityListByClueId(String clueId);

    List<Activity> getActivityListByNameNotByClueId(Map<String, String> map);
}
