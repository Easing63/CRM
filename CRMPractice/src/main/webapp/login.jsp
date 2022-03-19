<%@ page contentType="text/html;charset=utf-8" language="java"%>
<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script>
		$(function () {
			//页面加载完毕后，把用户名的input内容清空
			$("#username").val("");
			//让页面一进入就把焦点聚集在用户名这一input中
			$("#username").focus();

			//登录的点击响应
			$("#loginBtn").click(function () {
				login();
			})	//登录按钮的点击事件

			//让用户按回车可以进行登录
			$(window).keydown(function (event) {
				//回车的码是13
				if(event.keyCode == 13){
					login();
				}
			})
		})	//页面加载完毕

		function login() {
			//alert("执行登录操作");
			//账号密码不能为空；同时，要取得用户名和密码
			var loginAct = $.trim($("#username").val());
			var loginPwd = $.trim($("#password").val());

			if(loginAct == "" || loginPwd == ""){
				$("#msg").html("字段不能为空");
				//如果账号密码为空，就可以返回了
				return false;
			}

			//用户名密码没有错就要进入后台进行判断
			$.ajax({
				url:"settings/user/login.do",
				data:{
					"loginAct":loginAct,
					"loginPwd":loginPwd
				},
				type:"post",
				dataType:"json",	//返回值类型一定是json类型
				success:function (data) {
					//是否登录成功
					//data {"success":true/flase}
					if(data.success){
						//跳转到工作台
						window.location.href = "workbench/index.jsp";
					}else{
						//如果失败，就要说明失败的原因
						$("#msg").html(data.msg);
					}
				}
			})

		}
	</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2017&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.html" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" type="text" placeholder="用户名" id="username">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" type="password" placeholder="密码" id="password">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">

							<span id="msg" style="color: red;"></span>
						
					</div>
					<%--按钮写在表单中，并且按钮的默认类型也为submit；主要是为了按钮所触发的行为让程序员自己决定--%>
					<button type="button" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;" id="loginBtn">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>