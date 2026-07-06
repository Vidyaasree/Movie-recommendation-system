<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
String error = "";
String justRegistered = request.getParameter("registered");

if(request.getMethod().equalsIgnoreCase("POST"))
{
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try
    {
        Class.forName("com.mysql.cj.jdbc.Driver");

        String dbHost = System.getenv("MYSQL_HOST");
        String dbPort = System.getenv("MYSQL_PORT");
        String dbName = System.getenv("MYSQL_DB");
        String dbUser = System.getenv("MYSQL_USER");
        String dbPass = System.getenv("MYSQL_PASSWORD");
        String dbUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "?sslMode=REQUIRED&useSSL=true&serverTimezone=UTC";

        con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // Only credentials created via register.jsp will work here
        String sql = "SELECT * FROM users WHERE email=? AND password=?";
        ps = con.prepareStatement(sql);
        ps.setString(1, email);
        ps.setString(2, password);

        rs = ps.executeQuery();

        if(rs.next())
        {
            session.setAttribute("login", "yes");
            session.setAttribute("username", rs.getString("email"));
            response.sendRedirect("dashboard.jsp");
            return;
        }
        else
        {
            error = "Invalid email or password";
        }
    }
    catch(Exception e)
    {
        error = "Database Error: " + e.getMessage();
        e.printStackTrace();
    }
    finally
    {
        try {
            if(rs != null) rs.close();
            if(ps != null) ps.close();
            if(con != null) con.close();
        } catch(Exception e) {}
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Movie Recommendation System</title>
<style>
:root{
  --bg:#0b0b0d;
  --panel:#17171b;
  --panel-2:#1e1e23;
  --border:#2b2b31;
  --text:#e8e8ea;
  --muted:#9a9aa5;
  --accent:#5865f2;
  --accent-hover:#4752c4;
  --danger:#e5484d;
  --success:#3fb950;
}
*{
margin:0;
padding:0;
box-sizing:border-box;
font-family:'Segoe UI',sans-serif;
}
body{
height:100vh;
display:flex;
justify-content:center;
align-items:center;
background:var(--bg);
}
.card{
width:420px;
padding:40px 38px;
background:var(--panel);
border:1px solid var(--border);
border-radius:14px;
box-shadow:0 20px 50px rgba(0,0,0,.5);
display:flex;
flex-direction:column;
align-items:center;
}
.logo{
text-align:center;
font-size:30px;
font-weight:700;
color:var(--text);
letter-spacing:.5px;
line-height:1.3;
margin-bottom:5px;
}
.subtitle{
text-align:center;
color:var(--muted);
margin-bottom:25px;
font-size:14px;
}
form{
width:100%;
}
label{
display:block;
margin-bottom:6px;
margin-top:12px;
color:var(--text);
font-weight:600;
font-size:14px;
}
input{
width:100%;
padding:14px;
margin-bottom:10px;
border:1px solid var(--border);
border-radius:10px;
background:var(--panel-2);
color:var(--text);
font-size:15px;
outline:none;
transition:.2s;
}
input:focus{
border-color:var(--accent);
}
input::placeholder{
color:var(--muted);
}
button{
width:100%;
padding:14px;
margin-top:18px;
background:var(--accent);
border:none;
border-radius:10px;
color:white;
font-size:15px;
font-weight:600;
cursor:pointer;
transition:.2s;
}
button:hover{
background:var(--accent-hover);
}
.error{
margin-top:15px;
text-align:center;
color:var(--danger);
font-weight:bold;
}
.success{
margin-top:15px;
text-align:center;
color:var(--success);
font-weight:bold;
}
.footer{
margin-top:25px;
text-align:center;
font-size:13px;
color:var(--muted);
}
.footer a{
color:var(--accent);
text-decoration:none;
font-weight:600;
}
.footer a:hover{
text-decoration:underline;
}
</style>
</head>
<body>
<div class="card">
<div class="logo">Movie Recommendation</div>
<div class="subtitle">Sign in to continue</div>

<% if(justRegistered != null && justRegistered.equals("1")) { %>
<div class="success" style="margin-bottom:10px;">Account created! Please log in.</div>
<% } %>

<form method="post" action="login.jsp">
<label>Email</label>
<input type="email" name="email" placeholder="Enter your email" required>

<label>Password</label>
<input type="password" name="password" placeholder="Enter your password" required>

<button type="submit">Login</button>

<% if(!error.isEmpty()) { %>
<div class="error"><%= error %></div>
<% } %>
</form>

<div class="footer">Don't have an account? <a href="register.jsp">Sign up</a></div>
</div>
</body>
</html>
