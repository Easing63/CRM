<%@ page contentType="text/html;charset=utf-8" language="java"%>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<%@page isELIgnored="false" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <base href="<%=basePath%>">
    <title>Title</title>
    <script type="text/javascript">
        $(function () {
            $.ajax({
                url:"",
                data:{

                },
                type:"",
                dataType:"json",
                success:function (data) {

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
        })
    </script>
    String createTime = DateTimeUtil.getSysTime();
    String createBy = ((User)request.getSession().getAttribute("user")).getName();
</head>
<body>

</body>
</html>
