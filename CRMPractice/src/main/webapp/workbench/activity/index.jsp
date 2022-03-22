<%@ page contentType="text/html;charset=utf-8" language="java"%>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<%@page isELIgnored="false" %>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<%--要注意引入的先后顺序，比如分页插件是基于bootstrap的，所以要写在bootstrap的下面--%>
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

	<script type="text/javascript">

	$(function(){
		$("#addBtn").click(function () {
			//导入时间控件，是需要使用就可以了，因为输入的时间格式没有办法做到格式统一，就让用户进行选择
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			/*
				操作模态窗口，需要调用模态窗口的jquery对象，调用modal方法
				为该方法传递show参数，show表示打开，hide表示关闭模态窗口
			 */
			//alert("打开模态窗口之前的一些小操作");

			//在模态窗口的第一栏里面查出数据并显示在<option>当中

			//$("#createActivityModal").modal("show");		//打开模态窗口
			$.ajax({
				url:"workbench/activity/getUserList.do",
				type:"get",		//登录，和密码相关的用post，其他请求用get
				dataType:"json",
				success:function (data) {
					/*	分析返回的数据
					*  data:[{},{},{}]：是一个json格式的数据
					* */
					var html = "";

					//遍历的每一个element代表的e是每一个user对象
					$.each(data,function (i, e) {
						html += "<option value="+ e.id +">" + e.name +"</option>"
					})

					$("#create-marketActivityOwner").html(html);

					var id = "${sessionScope.user.id}";
					//将当前登录的用户设置为下拉框默认的选项
					$("#create-marketActivityOwner").val(id);
					//申请完所有的数据之后再打开模态窗口
					$("#createActivityModal").modal("show");
				}
			})

		})

		$("#savaBtn").click(function () {
			//绑定添加事件
			$.ajax({
				url:"workbench/activity/save.do",
				data:{
					"owner":$.trim($("#create-marketActivityOwner").val()),
					"name":$.trim($("#create-marketActivityName").val()),
					"startDate":$.trim($("#create-startTime").val()),
					"endDate":$.trim($("#create-endTime").val()),
					"cost":$.trim($("#create-cost").val()),
					"description":$.trim($("#create-describe").val())
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.success){
						//刷新市场活动信息表

                        //将模态窗口中的数据清空
                        $("#activityAddForm")[0].reset();
						//关闭操作的模态窗口
						$("#createActivityModal").modal("hide");
					}else{
						alert("添加失败！");
					}
				}
			})
		})

		$("#searchBtn").click(function () {
			//将表单域中的数据传给隐藏域
			$("#hidden-name").val($.trim( $("#search-name").val() ));
			$("#hidden-owner").val($.trim( $("#search-owner").val() ));
			$("#hidden-startDate").val($.trim( $("#startTime").val() ));
			$("#hidden-endDate").val($.trim( $("#endTime").val() ));
			getPageList(1,2);
		});


		//这个页面加载完毕就开始请求市场活动列表
		getPageList(1,2);

		/*
		 	需求：从数据库获取市场活动列表(调用getPageList方法)
		 	使用次数：1.点击市场活动的时候需要请求市场活动列表
		 	2.点击市场活动中的查询的时候需要请求市场活动列表
		 	3.创建保存后，修改，删除需要请求市场活动列表
		 	4.点击分页组件的时候需要请求
		*/
		function getPageList(pageNo,pageSize){
			//每一次刷新这个活动列表时就取消选中
			$("#chooseAll").prop("checked",false);

			//查询前，将隐藏域中的数据取出来
			$("#search-name").val($.trim( $("#hidden-name").val() ));
			$("#search-owner").val($.trim( $("#hidden-owner").val() ));
			$("#startTime").val($.trim( $("#hidden-startDate").val() ));
			$("#endTime").val($.trim( $("#hidden-endDate").val() ));

			//首先定义一个方法,pageNo:显示的表的页号，pageSize：每一页表显示的数据
			//alert("获取市场活动列表");
			$.ajax({
				url:"workbench/activity/getPageList.do",
				type:"post",
				data:{
					/*
						从前端传出去的数据：
							1.查询列表中的4个框的value,这四个值用动态sql来取，如果有就加入到sql中，如果没有，就不加
							2.pageNo和pageSize，页码和页的大小
					*/
					"name" : $.trim($("#search-name").val()),
					"owner" : $.trim($("#search-owner").val()),
					"startDate" : $.trim($("#startTime").val()),
					"endDate" : $.trim($("#endDate").val()),
					"pageNo" : pageNo,
					"pageSize" : pageSize
				},
				dataType:"json",
				success:function (data) {
					/*
						从后台传回来的数据：
						1.一个是实体市场活动对象
						2.另一个是查询到的满足条件的数据的条数，好用来做分组
							{"pageList":[{activity对象0},{activity对象0},{activity对象0}],"total":total}
					 */
					var html = "";
					$.each(data.list,function (i, e) {
						//i是索引，e是element
						/*
							动态生成的html代码
							<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
						 */
						html += '<tr class="active">';
						html += '<td><input name="choose" type="checkbox" value="'+ e.id + '"/></td>';
						html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.jsp\';">' + e.name + '</a></td>';
						html += '<td> '+ e.owner + '</td>';
						html += '<td>' + e.startDate + '</td>';
						html += '<td>' + e.endDate + '</td>';
						html += '</tr>';

						$("#activityListBody").html(html);

						//动态生成了表格之后

						//处理动态的分页组件
						var totalPages = data.total % pageSize==0 ? data.total / pageSize : parseInt(data.total /pageSize) + 1;
						$("#activityPage").bs_pagination({
							currentPage: pageNo, // 页码
							rowsPerPage: pageSize, // 每页显示的记录条数
							maxRowsPerPage: 20, // 每页最多显示的记录条数
							totalPages: totalPages, // 总页数
							totalRows: data.total, // 总记录条数

							visiblePageLinks: 3, // 显示几个卡片

							showGoToPage: true,
							showRowsPerPage: true,
							showRowsInfo: true,
							showRowsDefaultInfo: true,

							//该回调函数在点击分页组件的时候触发
							onChangePage : function(event, data){
								getPageList(data.currentPage , data.rowsPerPage);
							}
						}) 	//分页操作

					})
				}

			});	//ajax请求
		}		//定义请求市场活动列表的函数

		$("#chooseAll").click(function () {
			$("input[name=choose]").prop("checked",this.checked);
		})

		// $("input[name=choose]").click(function () {
		// 	alert("123")
		// })

		//这个对象就是需要绑定事件的有效外层元素
		$("#activityListBody").on("click",$("input[name=choose]"),function () {
			$("#chooseAll").prop("checked",$("input[name=choose]").length == $("input[name=choose]:checked").length);
		})



		$("#deleteBtn").click(function () {
			var $choose = $("input[name=choose]:checked");
			if($choose.length == 0){
				alert("请选择要删除的记录");
			}else{
				if(confirm("你确定要删除吗")){
					var param = "";
					for (var i = 0; i < $choose.length; i++) {
						param += "id=" + $($choose[i]).val();		//$choose[i]已经是dom对象了

						if(i<$choose.length - 1){
							param += "&";	//如果不是最后一个id
						}
					}

					$.ajax({
						url:"workbench/activity/delete.do",
						data:param,
						type:"post",
						dataType:"json",
						success:function (data) {
							/*
                            * 	只需要传回来一个是否成功，{"success":true/flase}
                            * */
							if(data.success){
								getPageList(1,2
								);
							}else{
								alert("删除市场活动失败");
							}
						}
					})
				}

			}	//else
		})	//为删除按钮绑定的点击事件

		//为修改按钮绑定事件，目的：打开修改的模态窗口
		$("#editBtn").click(function () {
			//找出选择了的复选框
			var $choose = $("input[name=choose]:checked");
			if($choose.length == 0){
				alert("请选择需要修改的市场活动");

				//只能选择一条
			}else if($choose.length > 1){
				alert("只能选择一条记录");
			}else{
				//能到这里就肯定只能是选择了一条的了
				var id = $choose.val();

				$.ajax({
					url:"workbench/activity/getUserListAndActivity.do",
					type:"get",
					data:{
						"id":id
					},
					dataType:"json",
					success:function (data) {
						//{"uList":[{用户1},{用户2},{}],"a":{市场活动}}
						var html = "";
						$.each(data.uList,function (i,e) {
							html += "<option value='+ e.name +'><option/>";
						})

						$("#edit-marketActivityOwner").html(html);
					}
				})
			}
		})		//展现修改的模态窗口

	});	//页面加载完成函数
	
</script>
</head>
<body>
	<input type="hidden" id="hidden-name">
	<input type="hidden" id="hidden-owner">
	<input type="hidden" id="hidden-startDate">
	<input type="hidden" id="hidden-endDate">

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activityAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">



								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startTime">
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endTime">
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="savaBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">



								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label time">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startTime">
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label time">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endTime">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">

								<%--关于文本域：1.标签一定要是以标签对的形式出现2.并且标签对之间要紧挨着（不能有空格）3.虽然是以标签对的形式展现的，
								对赋值取值操作，同样是用val()，--%>
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>

				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text"  id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="startTime"/>
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon" id="search-endDate">结束日期</div>
					  <input class="form-control" type="text" id="endTime">
				    </div>
				  </div>

				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>

				</form>
			</div>

			<%--
				data-toggle="modal" data-target="#createActivityModal":表示打开模态窗口
				这样写就会把代码写死，不能对代码的功能进行扩充，所以应该把这写操作放到js里面
			--%>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger"  id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="chooseAll" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityListBody">


					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage">
					<%--这里由分页插件动态填入--%>


				</div>
			</div>
			
		</div>
		
	</div>
</body>
</html>