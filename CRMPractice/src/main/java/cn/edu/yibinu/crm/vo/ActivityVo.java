package cn.edu.yibinu.crm.vo;

import java.util.List;

public class ActivityVo<T> {
    private List<T> list;
    private int total;

    public ActivityVo() {
    }

    public List<T> getList() {
        return list;
    }

    public void setList(List<T> list) {
        this.list = list;
    }

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }
}
