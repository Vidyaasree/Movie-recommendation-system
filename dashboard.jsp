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
*{
margin:0;
padding:0;
box-sizing:border-box;
font-family:'Segoe UI',sans-serif;
}
body{
background:linear-gradient(135deg,#0F172A,#1E293B,#0B1120);
min-height:100vh;
overflow-x:hidden;
}
body::before{
content:"";
position:fixed;
width:350px;
height:350px;
background:#2563EB;
border-radius:50%;
top:-120px;
left:-120px;
filter:blur(100px);
opacity:.35;
}
body::after{
content:"";
position:fixed;
width:320px;
height:320px;
background:#06B6D4;
border-radius:50%;
bottom:-120px;
right:-120px;
filter:blur(100px);
opacity:.30;
}
.navbar{
width:100%;
padding:22px 60px;
background:rgba(255,255,255,.08);
backdrop-filter:blur(15px);
display:flex;
justify-content:space-between;
align-items:center;
border-bottom:1px solid rgba(255,255,255,.12);
}
.logo{
font-size:28px;
font-weight:bold;
color:white;
letter-spacing:2px;
}
.user-info{
color:#94A3B8;
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
background:#EF4444;
border:none;
border-radius:10px;
color:white;
font-size:15px;
cursor:pointer;
transition:.3s;
}
.logout button:hover{
background:#DC2626;
transform:translateY(-2px);
}
.container{
width:90%;
margin:auto;
padding:60px 0;
}
.title{
text-align:center;
color:white;
font-size:38px;
margin-bottom:15px;
}
.subtitle{
text-align:center;
color:#CBD5E1;
margin-bottom:60px;
font-size:18px;
}
.cards{
display:flex;
justify-content:center;
gap:50px;
flex-wrap:wrap;
}
.card{
width:360px;
padding:40px;
background:rgba(255,255,255,.08);
backdrop-filter:blur(15px);
border-radius:22px;
border:1px solid rgba(255,255,255,.12);
box-shadow:0 20px 40px rgba(0,0,0,.35);
transition:.35s;
text-align:center;
}
.card:hover{
transform:translateY(-10px);
box-shadow:0 25px 50px rgba(37,99,235,.35);
}
.card h2{
color:white;
margin-bottom:20px;
font-size:28px;
}
.card p{
color:#CBD5E1;
line-height:28px;
margin-bottom:35px;
font-size:16px;
}
.card button{
padding:14px 35px;
background:#2563EB;
color:white;
border:none;
border-radius:10px;
font-size:16px;
cursor:pointer;
transition:.3s;
}
.card button:hover{
background:#1D4ED8;
transform:scale(1.05);
}
.footer{
text-align:center;
margin-top:70px;
color:#94A3B8;
font-size:14px;
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
<h2> Admin Panel</h2>
<p>Manage your movie collection by adding new movies with genres and ratings. View all available movies stored in the database.</p>
<a href="admin.jsp">
<button>Open Admin Panel</button>
</a>
</div>
<div class="card">
<h2> User Panel</h2>
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