<%
if(session.getAttribute("login") == null)
{
    response.sendRedirect("login.jsp");
    return;
}
String username = (String)session.getAttribute("username");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Dashboard</title>
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
  --danger-hover:#c53438;
}
*{
margin:0;
padding:0;
box-sizing:border-box;
font-family:'Segoe UI',sans-serif;
}
body{
background:var(--bg);
min-height:100vh;
}
.navbar{
width:100%;
padding:22px 60px;
background:var(--panel);
display:flex;
justify-content:space-between;
align-items:center;
border-bottom:1px solid var(--border);
}
.logo{
font-size:26px;
font-weight:bold;
color:var(--text);
letter-spacing:1px;
}
.user-info{
color:var(--muted);
font-size:14px;
display:flex;
align-items:center;
gap:15px;
}
.logout{
text-decoration:none;
}
.logout button{
padding:10px 25px;
background:var(--danger);
border:none;
border-radius:8px;
color:white;
font-size:14px;
cursor:pointer;
transition:.2s;
}
.logout button:hover{
background:var(--danger-hover);
}
.container{
width:90%;
max-width:1100px;
margin:auto;
padding:60px 0;
}
.title{
text-align:center;
color:var(--text);
font-size:34px;
margin-bottom:12px;
}
.subtitle{
text-align:center;
color:var(--muted);
margin-bottom:55px;
font-size:16px;
}
.cards{
display:flex;
justify-content:center;
gap:40px;
flex-wrap:wrap;
}
.card{
width:340px;
padding:36px;
background:var(--panel);
border:1px solid var(--border);
border-radius:14px;
transition:.2s;
text-align:center;
}
.card:hover{
border-color:var(--accent);
transform:translateY(-4px);
}
.card h2{
color:var(--text);
margin-bottom:16px;
font-size:24px;
}
.card p{
color:var(--muted);
line-height:26px;
margin-bottom:28px;
font-size:15px;
}
.card button{
padding:13px 32px;
background:var(--accent);
color:white;
border:none;
border-radius:8px;
font-size:15px;
cursor:pointer;
transition:.2s;
}
.card button:hover{
background:var(--accent-hover);
}
.card a{
text-decoration:none;
}
.footer{
text-align:center;
margin-top:65px;
color:var(--muted);
font-size:13px;
}
</style>
</head>
<body>
<div class="navbar">
<div class="logo">MOVIE RECOMMENDATION</div>
<div class="user-info">
<span>Welcome, <%= username != null ? username : "User" %></span>
<a href="logout.jsp" class="logout">
<button>Logout</button>
</a>
</div>
</div>
<div class="container">
<h1 class="title">Welcome to Dashboard</h1>
<p class="subtitle">Choose an option to continue</p>
<div class="cards">
<div class="card">
<h2>Admin Panel</h2>
<p>Manage your movie collection by adding new movies with genres and ratings. View all available movies stored in the database.</p>
<a href="admin.jsp">
<button>Open Admin Panel</button>
</a>
</div>
<div class="card">
<h2>User Panel</h2>
<p>Browse available movies, watch your favourites and receive intelligent recommendations based on your viewing history.</p>
<a href="user.jsp">
<button>Open User Panel</button>
</a>
</div>
</div>
<div class="footer">Movie Recommendation System | JSP • JDBC • MySQL</div>
</div>
</body>
</html>
