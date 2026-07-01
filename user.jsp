<%@ page import="java.sql.*" %>

<%
if(session.getAttribute("login") == null)
{
    response.sendRedirect("login.jsp");
    return;
}

String recommendedMovie = "";
String recommendedGenre = "";
double recommendedRating = 0;
String watchMessage = "";

Connection con = null;
PreparedStatement ps = null;
Statement st = null;
ResultSet rs = null;

try
{
    Class.forName("com.mysql.cj.jdbc.Driver");

    String dbHost = "localhost";
    String dbPort = "3306";
    String dbName = "moviedb";
    String dbUser = "root";
    String dbPass = "";
    String dbUrl  = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName;
    
    con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

    String watchMovie = request.getParameter("watchMovie");

    if(watchMovie != null && !watchMovie.trim().isEmpty())
    {
        String username = (String)session.getAttribute("username");
        
        ps = con.prepareStatement(
            "INSERT INTO watch_history(username, movie_name, watched_time) VALUES(?, ?, NOW())"
        );
        ps.setString(1, username != null ? username : "anonymous");
        ps.setString(2, watchMovie.trim());
        ps.executeUpdate();
        ps.close();
        
        watchMessage = "You watched: " + watchMovie;

        String genre = "";
        ps = con.prepareStatement(
            "SELECT genre FROM movies WHERE movie_name=?"
        );
        ps.setString(1, watchMovie.trim());
        ResultSet r1 = ps.executeQuery();

        if(r1.next())
        {
            genre = r1.getString("genre");
        }
        r1.close();
        ps.close();

        if(!genre.isEmpty())
        {
            ps = con.prepareStatement(
                "SELECT * FROM movies WHERE genre=? AND movie_name<>? ORDER BY rating DESC LIMIT 1"
            );
            ps.setString(1, genre);
            ps.setString(2, watchMovie.trim());
            ResultSet r2 = ps.executeQuery();

            if(r2.next())
            {
                recommendedMovie = r2.getString("movie_name");
                recommendedGenre = r2.getString("genre");
                recommendedRating = r2.getDouble("rating");
            }
            r2.close();
            ps.close();
        }
    }

    st = con.createStatement();
    rs = st.executeQuery("SELECT * FROM movies ORDER BY movie_name");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Panel</title>
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
padding:40px;
position:relative;
overflow-x:hidden;
}
body::before{
content:"";
position:fixed;
width:300px;
height:300px;
background:#2563EB;
border-radius:50%;
top:-100px;
left:-100px;
filter:blur(100px);
opacity:.35;
}
body::after{
content:"";
position:fixed;
width:300px;
height:300px;
background:#06B6D4;
border-radius:50%;
bottom:-100px;
right:-100px;
filter:blur(100px);
opacity:.30;
}
.container{
width:90%;
margin:auto;
position:relative;
z-index:10;
}
.header{
text-align:center;
color:white;
margin-bottom:35px;
}
.header h1{
font-size:38px;
margin-bottom:10px;
}
.header p{
color:#CBD5E1;
}
.watch-msg{
text-align:center;
color:#4ADE80;
margin-bottom:20px;
font-weight:bold;
}
.movies{
display:grid;
grid-template-columns:repeat(auto-fit,minmax(250px,1fr));
gap:20px;
}
.card{
background:rgba(255,255,255,.08);
backdrop-filter:blur(15px);
padding:20px;
border-radius:15px;
box-shadow:0 10px 25px rgba(0,0,0,.4);
color:white;
transition:.3s;
}
.card:hover{
transform:translateY(-5px);
}
.card h2{
color:#38BDF8;
margin-bottom:10px;
}
.card p{
margin:8px 0;
color:#E2E8F0;
}
button{
padding:10px 20px;
background:#2563EB;
color:white;
border:none;
border-radius:8px;
cursor:pointer;
transition:.3s;
margin-top:10px;
}
button:hover{
background:#1D4ED8;
transform:translateY(-2px);
}
.recommend{
margin-top:30px;
background:rgba(255, 248, 220, 0.15);
backdrop-filter:blur(10px);
padding:20px;
border-left:6px solid gold;
border-radius:10px;
color:white;
}
.recommend h2{
color:gold;
}
.bottom{
text-align:center;
margin-top:30px;
}
.bottom a{
text-decoration:none;
margin:10px;
}
.no-movies{
text-align:center;
color:#94A3B8;
padding:40px;
font-size:18px;
}
</style>
</head>
<body>
<div class="container">
<div class="header">
<h1>Movie Recommendation System</h1>
<p>Select a movie to watch</p>
</div>
<% if(!watchMessage.isEmpty()){ %>
<div class="watch-msg">&#10003; <%= watchMessage %></div>
<% } %>
<div class="movies">
<%
if(rs != null && rs.next())
{
    do {
%>
<div class="card">
<h2><%= rs.getString("movie_name") %></h2>
<p><b>Genre:</b> <%= rs.getString("genre") %></p>
<p><b>Rating:</b> <%= rs.getDouble("rating") %>/5</p>
<form method="post">
<input type="hidden" name="watchMovie" value="<%= rs.getString("movie_name") %>">
<button type="submit">Watch Movie</button>
</form>
</div>
<%
    } while(rs.next());
}
else
{
%>
<div class="no-movies">No movies available. Please check back later.</div>
<%
}
%>
</div>
<%
if(!recommendedMovie.isEmpty())
{
%>
<div class="recommend">
<h2>&#127775; Recommended Movie</h2>
<p><b>Movie:</b> <%= recommendedMovie %></p>
<p><b>Genre:</b> <%= recommendedGenre %></p>
<p><b>Rating:</b> <%= recommendedRating %>/5</p>
</div>
<%
}
%>
<div class="bottom">
<a href="../dashboard.jsp"><button>Dashboard</button></a>
<a href="admin.jsp"><button>Admin Panel</button></a>
<a href="logout.jsp"><button style="background:#DC2626;">Logout</button></a>
</div>
</div>
</body>
</html>

<%
if(rs != null) rs.close();
if(con != null) con.close();
}
catch(Exception e)
{
    out.println("<h3 style='color:red;text-align:center;'>Error: " + e.getMessage() + "</h3>");
}
%>