<%@ page contentType="text/html;charset=utf-8" language="java"%>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page isELIgnored="false" %>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">
	$(function(){
		$("#isCreateTransaction").click(function(){
			if(this.checked){
				$("#create-transaction2").show(200);
			}else{
				$("#create-transaction2").hide(200);
			}
		});

		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});

		$("#openSearchActivityBtn").click(function () {
			//为放大镜图标绑定点击事件
			//打开模态窗口
			$("#searchActivityModal").modal("show");
		});

		$("#activityName").keydown(function (event) {
			if(event.keyCode == 13){
				//获取市场活动列表
				$.ajax({
					url:"workbench/clue/getActivityListByName.do",
					data:{
						"activityName":$.trim($("#activityName").val())
					},
					type:"get",
					dataType:"json",
					success:function (data) {
						//[{市场活动1},{市场活动2},{市场活动3}]

						var html = "";

						$.each(data,function (i,e) {
							html += '<tr>';
							html += '<td><input type="radio" name="activity" value="'+e.id+'"/></td>';
							html += '<td id='+e.id+'>'+e.name+'</td>';
							html += '<td>'+e.startDate+'</td>';
							html += '<td>'+e.endDate+'</td>';
							html += '<td>'+e.owner+'</td>';
							html += '</tr>';
						});

						$("#activityBody").html(html);
					}
				});
				return false;
			}		//if
		});

		$("#submitActivityNameBtn").click(function () {
			//alert("提交!");
			//点击提交按钮将选中的市场活动的id和市场活动的名字传给模态窗口
			var aId = $("input[name=activity]:checked").val();

			var aName = $("#" + aId).html();

			//将市场活动的名字传给表单
			$("#activity").val(aName);

			//将选中的市场活动id传给隐藏域
			$("#checkedActivityId").val(aId);

			//关闭模态窗口
			$("#searchActivityModal").modal("hide");
		});

		$("#convert").click(function () {
			//为转换按钮绑定事件

			//判断用户是否点击了创建交易的复选框
			if($("#isCreateTransaction").prop("checked")){
				//alert("用户需要创建交易");
				//需要创建交易，还要绑定交易表单中的信息
				<%--window.location.href="workbench/clue/convert.do?clueId=${param.clueId}";--%>

				//用提交表单的传统方式方便后续添加字段
				$("#tranForm").submit();
			}else{
				//alert("用户不需要创建交易");
				window.location.href="workbench/clue/convert.do?clueId=${param.clueId}";	//不需要创建交易，传递一个clueId就可以了
			}
		})

	});
</script>

</head>
<body>
	
	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询" id="activityName">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activityBody">
							<!--<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="radio" name="activity"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>-->
						</tbody>
					</table>
				</div>

				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="submitActivityNameBtn">提交</button>
				</div>

			</div>
		</div>
	</div>

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<h4>转换线索 <small>${param.fullname}${param.appellation}-${param.company}</small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：${param.company}
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${param.fullname}${param.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
	
		<form id="tranForm" method="post" action="workbench/clue/convert.do">

			<%--创建一个用来标记是否需要传输交易表单的标志信息--%>
			<input type="hidden" name="flag" value="yes"/>
			<%--这样的话，请求路径也相当于workbench/clue/convert.do?clueId=xxxx&money=xxxx&name=xxx&expectedDate=xxx--%>
			<%--提交表单也需要clueId，但是不能挂载在请求路径后面，所以写一个input--%>
			<input type="hidden" name="clueId" value="${param.clueId}"/>

		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="amountOfMoney">金额</label>
		    <input type="text" class="form-control" id="amountOfMoney" name="money">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="tradeName">交易名称</label>
		    <input type="text" class="form-control" id="tradeName" value="${param.company}-" name="name">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedClosingDate">预计成交日期</label>
		    <input type="text" class="form-control time" id="expectedClosingDate" name="expectedDate">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">阶段</label>
		    <select id="stage"  class="form-control" name="stage">
		    	<option></option>
		    	<c:forEach items="${stage}" var="s">
					<option value="${s.value}">${s.text}</option>
				</c:forEach>
		    </select>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="activity">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" style="text-decoration: none;" id="openSearchActivityBtn"><span class="glyphicon glyphicon-search"></span></a></label>
		    <input type="text" class="form-control" id="activity" placeholder="点击上面搜索" readonly>
			  <input type="hidden" id="checkedActivityId" name="checkedActivityId"/>
		  </div>
		</form>
		
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${param.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" type="button" value="转换" id="convert">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" value="取消">
	</div>
</body>
</html>