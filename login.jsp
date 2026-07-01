<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
String error = "";

if(request.getMethod().equalsIgnoreCase("POST"))
{
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try
    {
        // Load MySQL Driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Database connection parameters
        String dbHost = "localhost";
        String dbPort = "3306";
        String dbName = "moviedb";  // Your database name
        String dbUser = "root";
        String dbPass = "";  // Your MySQL password (leave empty if no password)
        String dbUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName;
        
        // Establish connection
        con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // Query to check user credentials
        String sql = "SELECT * FROM users WHERE username=? AND password=?";
        ps = con.prepareStatement(sql);
        ps.setString(1, username);
        ps.setString(2, password);

        rs = ps.executeQuery();

        if(rs.next())
        {
            // Login successful
            session.setAttribute("login", "yes");
            session.setAttribute("username", username);
            response.sendRedirect("dashboard.jsp");  // Go to dashboard
            return;
        }
        else
        {
            error = "Invalid Username or Password";
        }
    }
    catch(Exception e)
    {
        error = "Database Error: " + e.getMessage();
        e.printStackTrace();  // Print error for debugging
    }
    finally
    {
        // Close resources
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
background:linear-gradient(135deg,#0F172A,#1E293B,#0B1120);
overflow:hidden;
}
body::before{
content:"";
position:absolute;
width:350px;
height:350px;
background:#2563EB;
border-radius:50%;
top:-120px;
left:-120px;
filter:blur(90px);
opacity:.45;
}
body::after{
content:"";
position:absolute;
width:320px;
height:320px;
background:#06B6D4;
border-radius:50%;
bottom:-120px;
right:-120px;
filter:blur(90px);
opacity:.35;
}
.card{
position:relative;
z-index:1;
width:420px;
padding:40px 38px;
background:rgba(255,255,255,.08);
backdrop-filter:blur(15px);
border:1px solid rgba(255,255,255,.12);
border-radius:22px;
box-shadow:0 20px 50px rgba(0,0,0,.5);
display:flex;
flex-direction:column;
align-items:center;
}
.logo{
text-align:center;
font-size:32px;
font-weight:700;
color:white;
letter-spacing:1px;
line-height:1.3;
margin-bottom:5px;
}
.subtitle{
text-align:center;
color:#CBD5E1;
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
color:white;
font-weight:600;
font-size:14px;
}
input{
width:100%;
padding:14px;
margin-bottom:10px;
border:none;
border-radius:12px;
background:rgba(255,255,255,.12);
color:white;
font-size:15px;
outline:none;
transition:.3s;
}
input:focus{
background:rgba(255,255,255,.18);
border:1px solid #38BDF8;
}
input::placeholder{
color:rgba(255,255,255,0.5);
}
button{
width:100%;
padding:14px;
margin-top:18px;
background:#2563EB;
border:none;
border-radius:12px;
color:white;
font-size:15px;
font-weight:600;
cursor:pointer;
transition:.3s;
}
button:hover{
background:#1D4ED8;
transform:translateY(-2px);
box-shadow:0 10px 25px rgba(37,99,235,.4);
}
.error{
margin-top:15px;
text-align:center;
color:#F87171;
font-weight:bold;
}
.footer{
margin-top:25px;
text-align:center;
font-size:13px;
color:#94A3B8;
}
</style>
</head>
<body>
<div class="card">
<div class="logo">MOVIE RECOMMENDATION</div>
<p class="subtitle">Sign in to continue</p>
<form method="post">
<label>Username</label>
<input type="text" name="username" placeholder="Enter Username" required>
<label>Password</label>
<input type="password" name="password" placeholder="Enter Password" required>
<button type="submit">LOGIN</button>
</form>
<%
if(!error.equals(""))
{
%>
<div class="error"><%=error%></div>
<%
}
%>
<div class="footer">Powered by JSP | JDBC | MySQL</div>
</div>
</body>
</html>