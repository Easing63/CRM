<%@ page import="java.util.List" %>
<%@ page import="cn.edu.yibinu.crm.settings.domain.DicValue" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="cn.edu.yibinu.crm.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=utf-8" language="java"%>
<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
	//取出数据字典key为stage的字典值列表
	List<DicValue> dvList = (List<DicValue>) application.getAttribute("stage");

	//阶段和可能性的对应关系
	Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");

	//取出阶段的key值部分
	Set<String> set = pMap.keySet();

	//准备正常绿色图标和红色交易丢失图标的分界点
	int point = 0;	//这个就是分界点，真正的值在后面赋予
	for(int i=0; i < dvList.size(); i++){
		//从List集合中取得每一条dicValue对象
		DicValue dicValue = dvList.get(i);

		//然后从每一个dv对象中取value
		String value = dicValue.getValue();
		//通过value在服务器缓存中取出possibility
		String possibility = pMap.get(value);

		if("0".equals(possibility)){
			//说明找到了分界点point
			point = i;
			break;
		}
	}

%>
<%@page isELIgnored="false" %>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />

<style type="text/css">
.mystage{
	font-size: 20px;
	vertical-align: middle;
	cursor: pointer;
}
.closingDate{
	font-size : 15px;
	cursor: pointer;
	vertical-align: middle;
}
</style>
	
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});
		
		
		//阶段提示框
		$(".mystage").popover({
            trigger:'manual',
            placement : 'bottom',
            html: 'true',
            animation: false
        }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
                });


		showTranHistoryList();
	});

	function showTranHistoryList() {

		$.ajax({
			url:"workbench/transaction/getTranHistoryList.do",
			data:{
				"tranId":"${requestScope.tran.id}"
			},
			type:"get",
			dataType:"json",
			success:function (data) {
				var html = "";

				$.each(data,function (i, e) {
					html += '<tr>';
					html += '<td>'+e.stage+'</td>';
					html += '<td>'+e.money+'</td>';
					html += '<td>'+e.possibility+'</td>';
					html += '<td>'+e.expectedDate+'</td>';
					html += '<td>'+e.createTime+'</td>';
					html += '<td>'+e.createBy+'</td>';
					html += '</tr>';
				});

				$("#tranHistoryBody").html(html);
			}
		});
	}

	/*
	    改变交易阶段：
	    stage：需要改变的阶段
	    i：需要改变的阶段对应的下标
	 */
	function changeStage(stage,i) {
        // alert(stage);
        // alert(i);
        $.ajax({
            url:"workbench/transaction/changeStage.do",
            data:{
                "id":"${tran.id}",
                "stage":stage,
                "money":"${tran.money}",
                "expectedDate":"${tran.expectedDate}"
            },
            type:"post",
            dataType:"json",
            success:function (data) {
                if(data.success){
                    //刷新阶段以及交易信息
                    //data:{"success":true/false,"tran":{tran对象}}
                    $("#stage").html(data.tran.stage);
                    $("#possibility").html(data.tran.possibility);
                    $("#editBy").html(data.tran.editBy);
                    $("#editTime").html(data.tran.editTime);

                    changeIcon(stage,i);

                    //刷新历史交易列表
                    showTranHistoryList();
                }else{
                    alert("改变阶段失败")
                }
            }
        });
    }

    /*
        在点击图标后图标也需要跟改变
        stage：当前图标对应的阶段
        i：当前的图标对应的下标
     */
    function changeIcon(stage,index_temp){
        //准备currentStage
        var currentStage = stage;
        //索引
        var index = index_temp;
        //临界点
        var point = <%=point%>;
        //当前阶段可能性
        var currentPossibility = $("#possibility").html();

        /*alert("当前点击的阶段："+currentStage);
        alert("索引：" + index);
        alert("临界点：" + point);
        alert("可能性：" + currentPossibility);*/

        if(currentPossibility == "0"){
            //说明当前阶段为交易丢失

            //前面七个是黑圈，后面两个一个是红叉，一个是黑叉
            for (var i = 0; i < point; i++) {
                //黑圈--------------

                //移除原有样式
                $("#" + i).removeClass();
                //添加新样式
                $("#" + i).addClass("glyphicon glyphicon-record mystage");
                //添加颜色
                $("#" + i).css("color","#000000");
            }
            for (var i = point; i < <%=dvList.size()%>; i++) {
                //一个是红叉一个是黑叉
                if(index == i){
                    //红叉----------------

                    $("#" + i).removeClass();
                    //添加新样式
                    $("#" + i).addClass("glyphicon glyphicon-remove mystage");
                    //添加颜色
                    $("#" + i).css("color","#ff0000");
                }else{
                    //黑叉----------------

                    $("#" + i).removeClass();
                    //添加新样式
                    $("#" + i).addClass("glyphicon glyphicon-remove mystage");
                    //添加颜色
                    $("#" + i).css("color","#000000");
                }
            }

        //说明是绿圈+绿色标记+黑圈的形式
        }else{
            for (var i = 0; i < point; i++) {
                //遍历前7个
                if(index == i){
                    //当前阶段
                    //绿色标记---------------

                    $("#" + i).removeClass();
                    //添加新样式
                    $("#" + i).addClass("glyphicon glyphicon-map-marker mystage");
                    //添加颜色
                    $("#" + i).css("color","#90F790");
                }else if(i < index ){
                    //小于当前阶段
                    //绿圈-------------

                    $("#" + i).removeClass();
                    //添加新样式
                    $("#" + i).addClass("glyphicon glyphicon-ok-circle mystage");
                    //添加颜色
                    $("#" + i).css("color","#90F790");
                }else{
                    //大于当前阶段
                    //黑圈-----------------------

                    $("#" + i).removeClass();
                    //添加新样式
                    $("#" + i).addClass("glyphicon glyphicon-record mystage");
                    //添加颜色
                    $("#" + i).css("color","#000000");
                }
            }
            for (var i = point; i < <%=dvList.size()%>; i++) {
                //黑叉---------------------

                $("#" + i).removeClass();
                //添加新样式
                $("#" + i).addClass("glyphicon glyphicon-remove mystage");
                //添加颜色
                $("#" + i).css("color","#000000");
            }
        }
    }
	
	
</script>

</head>
<body>
	
	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${tran.customerId}-${tran.name} <small>￥${tran.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='edit.html';"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 阶段状态 -->
	<div style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

		<%
			//准备当前阶段
			Tran tran = (Tran) request.getAttribute("tran");
			String currentStage = tran.getStage();

			//准备当前阶段的可能性
			String currentPossibility = pMap.get(currentStage);


			//判断可能性
            if("0".equals(currentPossibility)){
                //当前阶段可能性为0，图标为前七个都是黑圈，后两个一个是红叉，一个是黑叉
                for (int i = 0; i < dvList.size(); i++) {
                    //取出DicValue的所有对象的value属性
                    DicValue dv = dvList.get(i);
                    String listStage = dv.getValue();

                    //再拿到可能性
                    String listPossibility = pMap.get(listStage);

                    //说明就是后面两个图标
                    if ("0".equals(listPossibility)){
                        //一个黑叉，一个红叉
                        if(listStage.equals(currentStage)){
                            //红叉--------------------------------------------------
            %>
                <span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
                      class="glyphicon glyphicon-remove mystage"
                      data-toggle="popover" data-placement="bottom"
                      data-content="<%=dv.getText()%>" style="color: #ff0000;"></span>
                -----------
            <%

                        }else{
                            //黑叉--------------------------------------------------
            %>
                <span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
                      class="glyphicon glyphicon-remove mystage"
                      data-toggle="popover" data-placement="bottom"
                      data-content="<%=dv.getText()%>" style="color: #000000;"></span>
                -----------
            <%

                        }
                    }else{
                        //前七个都是黑圈

                        //黑圈---------------------------------------------------
            %>
                <span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
                      class="glyphicon glyphicon-record mystage"
                      data-toggle="popover" data-placement="bottom"
                      data-content="<%=dv.getText()%>" style="color: #000000;"></span>
                -----------
            <%

                    }
                }

            //当前阶段可能性不为0，后两个一定是黑叉，前七个有绿色标记，绿色圆圈，黑色圆圈
            }else{
                //准备当前阶段对应的下标
                int index = 0;

                //找出下标
                for (int i = 0; i < dvList.size(); i++) {
                    DicValue dv = dvList.get(i);
                    String listStage = dv.getValue();
                    //String listPossibility = pMap.get(listStage);
                    if(listStage.equals(currentStage)){
                        index = i;
                        break;
                    }
                }


                for (int i = 0; i < dvList.size(); i++) {
                    DicValue dv = dvList.get(i);
                    String listStage = dv.getValue();
                    String listPossibility = pMap.get(listStage);

                    if ("0".equals(listPossibility)){
                        //一定为黑叉
                        //黑叉------------------------------------------
                    %>
                        <span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
                              class="glyphicon glyphicon-remove mystage"
                              data-toggle="popover" data-placement="bottom"
                              data-content="<%=dv.getText()%>" style="color: #000000;"></span>
                        -----------
                    <%

                    //当前阶段不为0
                    }else{
                        //当前阶段
                        if(i == index){
                            //绿色标记-----------------------------
                    %>
                        <span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
                              class="glyphicon glyphicon-map-marker mystage"
                              data-toggle="popover" data-placement="bottom"
                              data-content="<%=dv.getText()%>" style="color: #90F790;"></span>
                        -----------
                    <%
                        //小于当前阶段
                        }else if(i < index){
                            //绿圈------------------------------
                    %>
                        <span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
                              class="glyphicon glyphicon-ok-circle mystage"
                              data-toggle="popover" data-placement="bottom"
                              data-content="<%=dv.getText()%>" style="color: #90F790;"></span>
                        -----------
                    <%
                        //大于当前阶段
                        }else{
                            //黑圈----------------------------------
                    %>
                        <span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
                              class="glyphicon glyphicon-record mystage"
                              data-toggle="popover" data-placement="bottom"
                              data-content="<%=dv.getText()%>" style="color: #000000;"></span>
                        -----------
                    <%
                        }

                    }

                }

            }
		%>
		<!--<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="资质审查" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="需求分析" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="价值建议" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="确定决策者" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom" data-content="提案/报价" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="谈判/复审"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="成交"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="丢失的线索"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="因竞争丢失关闭"></span>
		------------->
		<span class="closingDate">${tran.expectedDate}</span>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.customerId}-${tran.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${tran.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.type}&nbsp;&nbsp;</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">${tran.possibility}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${tran.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">${tran.editBy}&nbsp;&nbsp;</b><small id="editTime" style="font-size: 10px; color: gray;">${tran.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${tran.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${tran.contactSummary}&nbsp;
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.nextContactTime}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 100px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="tranHistoryBody">
						<!--<tr>
							<td>资质审查</td>
							<td>5,000</td>
							<td>10</td>
							<td>2017-02-07</td>
							<td>2016-10-10 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>需求分析</td>
							<td>5,000</td>
							<td>20</td>
							<td>2017-02-07</td>
							<td>2016-10-20 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>谈判/复审</td>
							<td>5,000</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>2017-02-09 10:10:10</td>
							<td>zhangsan</td>
						</tr>-->
					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>