<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
// Make sure your database has this table before using this page:
//
// CREATE TABLE IF NOT EXISTS users (
//   id INT AUTO_INCREMENT PRIMARY KEY,
//   email VARCHAR(255) UNIQUE NOT NULL,
//   password VARCHAR(255) NOT NULL,
//   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
// );

String error = "";

if(request.getMethod().equalsIgnoreCase("POST"))
{
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    if(email == null || email.trim().isEmpty() ||
       password == null || password.trim().isEmpty())
    {
        error = "Email and password are required";
    }
    else if(!password.equals(confirmPassword))
    {
        error = "Passwords do not match";
    }
    else
    {
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

            // Check if email already exists
            ps = con.prepareStatement("SELECT id FROM users WHERE email=?");
            ps.setString(1, email.trim());
            rs = ps.executeQuery();

            if(rs.next())
            {
                error = "An account with this email already exists";
            }
            else
            {
                rs.close();
                ps.close();

                ps = con.prepareStatement("INSERT INTO users(email, password) VALUES(?, ?)");
                ps.setString(1, email.trim());
                ps.setString(2, password);
                ps.executeUpdate();

                response.sendRedirect("login.jsp?registered=1");
                return;
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
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Sign Up - Movie Recommendation System</title>
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
<div class="logo">Create Account</div>
<div class="subtitle">Sign up to get started</div>

<form method="post" action="register.jsp">
<label>Email</label>
<input type="email" name="email" placeholder="Enter your email" required>

<label>Password</label>
<input type="password" name="password" placeholder="Enter your password" required>

<label>Confirm Password</label>
<input type="password" name="confirmPassword" placeholder="Re-enter your password" required>

<button type="submit">Sign Up</button>

<% if(!error.isEmpty()) { %>
<div class="error"><%= error %></div>
<% } %>
</form>

<div class="footer">Already have an account? <a href="login.jsp">Log in</a></div>
</div>
</body>
</html>
