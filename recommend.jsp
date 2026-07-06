<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
if(session.getAttribute("login") == null)
{
    response.sendRedirect("login.jsp");
    return;
}

String watchedMovieName = request.getParameter("watchMovie");

if(watchedMovieName == null || watchedMovieName.trim().isEmpty())
{
    response.sendRedirect("user.jsp");
    return;
}
watchedMovieName = watchedMovieName.trim();

String watchedMovieGenre = "";
double watchedMovieRating = 0;
String recMovieName = "";
String recMovieGenre = "";
double recMovieRating = 0;
boolean hasRecommendation = false;

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

    String username = (String) session.getAttribute("username");

    // Log the watch event
    ps = con.prepareStatement(
        "INSERT INTO watch_history(username, movie_name, watched_time) VALUES(?, ?, NOW())"
    );
    ps.setString(1, username != null ? username : "anonymous");
    ps.setString(2, watchedMovieName);
    ps.executeUpdate();
    ps.close();

    // Look up the genre + rating of the watched movie
    ps = con.prepareStatement("SELECT genre, rating FROM movies WHERE movie_name=?");
    ps.setString(1, watchedMovieName);
    rs = ps.executeQuery();

    if(rs.next())
    {
        watchedMovieGenre = rs.getString("genre");
        watchedMovieRating = rs.getDouble("rating");
    }
    rs.close();
    ps.close();

    // Find the next highest rated movie in the same genre (excluding the one just watched)
    if(watchedMovieGenre != null && !watchedMovieGenre.isEmpty())
    {
        ps = con.prepareStatement(
            "SELECT movie_name, genre, rating FROM movies WHERE genre=? AND movie_name<>? ORDER BY rating DESC LIMIT 1"
        );
        ps.setString(1, watchedMovieGenre);
        ps.setString(2, watchedMovieName);
        rs = ps.executeQuery();

        if(rs.next())
        {
            recMovieName = rs.getString("movie_name");
            recMovieGenre = rs.getString("genre");
            recMovieRating = rs.getDouble("rating");
            hasRecommendation = true;
        }
        rs.close();
        ps.close();
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Recommendation</title>
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
  --gold:#f5c542;
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
padding:40px;
}
.container{
width:90%;
max-width:800px;
margin:auto;
}
.navbar{
display:flex;
justify-content:space-between;
align-items:center;
background:var(--panel);
padding:15px 30px;
border-radius:12px;
margin-bottom:35px;
border:1px solid var(--border);
}
.nav-logo{
color:var(--text);
font-size:20px;
font-weight:bold;
letter-spacing:1px;
}
.logout-btn{
padding:10px 20px;
background:var(--danger);
border:none;
border-radius:8px;
color:white;
cursor:pointer;
transition:.2s;
font-size:14px;
font-weight:500;
}
.logout-btn:hover{
background:var(--danger-hover);
}
.watched-box{
background:var(--panel);
border:1px solid var(--border);
border-left:4px solid var(--accent);
border-radius:12px;
padding:24px 28px;
margin-bottom:30px;
}
.watched-box .label{
color:var(--muted);
font-size:13px;
text-transform:uppercase;
letter-spacing:.5px;
margin-bottom:8px;
}
.watched-box h2{
color:var(--text);
font-size:26px;
margin-bottom:6px;
}
.watched-box p{
color:var(--muted);
font-size:15px;
}
.rec-section h2{
color:var(--text);
font-size:24px;
margin-bottom:20px;
text-align:center;
}
.rec-card{
background:var(--panel);
border:1px solid var(--border);
border-left:4px solid var(--gold);
border-radius:12px;
padding:28px;
text-align:center;
}
.rec-card h3{
color:var(--text);
font-size:28px;
margin-bottom:12px;
}
.rec-card .genre-tag{
display:inline-block;
padding:5px 14px;
border-radius:20px;
font-size:13px;
font-weight:600;
background:var(--panel-2);
color:var(--muted);
border:1px solid var(--border);
margin-bottom:16px;
}
.stars-row{
display:flex;
align-items:center;
justify-content:center;
gap:8px;
margin-bottom:24px;
}
.stars{
display:flex;
gap:3px;
}
.star{ font-size:22px; }
.star.filled { color:var(--gold); }
.star.half   { color:var(--gold); opacity:.6; }
.star.empty  { color:#3a3a40; }
.rating-num{
font-size:14px;
color:var(--muted);
}
.actions{
display:flex;
gap:14px;
justify-content:center;
flex-wrap:wrap;
}
.actions form, .actions a{
display:inline-block;
text-decoration:none;
}
.btn-primary{
padding:13px 28px;
background:var(--accent);
color:white;
border:none;
border-radius:8px;
cursor:pointer;
font-size:15px;
font-weight:600;
transition:.2s;
}
.btn-primary:hover{
background:var(--accent-hover);
}
.btn-secondary{
padding:13px 28px;
background:transparent;
border:1px solid var(--border);
color:var(--text);
border-radius:8px;
cursor:pointer;
font-size:15px;
transition:.2s;
}
.btn-secondary:hover{
border-color:var(--accent);
}
.no-rec{
text-align:center;
color:var(--muted);
padding:30px;
font-size:16px;
}
.bottom{
text-align:center;
margin-top:35px;
}
</style>
</head>
<body>
<div class="container">

  <div class="navbar">
    <span class="nav-logo">MovieApp</span>
    <a href="logout.jsp"><button class="logout-btn">Logout</button></a>
  </div>

  <div class="watched-box">
    <div class="label">You watched</div>
    <h2><%= watchedMovieName %></h2>
    <p>Genre: <%= watchedMovieGenre %></p>
  </div>

  <div class="rec-section">
    <h2>Recommended For You</h2>
    <% if(hasRecommendation) {
        int fullStars = (int) recMovieRating;
        boolean hasHalf = (recMovieRating - fullStars) >= 0.4;
        int emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);
    %>
    <div class="rec-card">
      <h3><%= recMovieName %></h3>
      <span class="genre-tag"><%= recMovieGenre %></span>
      <div class="stars-row">
        <div class="stars">
          <% for(int i=0;i<fullStars;i++){ %>
            <span class="star filled">&#9733;</span>
          <% } %>
          <% if(hasHalf){ %>
            <span class="star half">&#9733;</span>
          <% } %>
          <% for(int i=0;i<emptyStars;i++){ %>
            <span class="star empty">&#9733;</span>
          <% } %>
        </div>
        <span class="rating-num"><%= recMovieRating %>/5</span>
      </div>
      <div class="actions">
        <form method="post" action="recommend.jsp">
          <input type="hidden" name="watchMovie" value="<%= recMovieName %>">
          <button type="submit" class="btn-primary">Watch This Instead</button>
        </form>
        <a href="user.jsp"><button type="button" class="btn-secondary">Back to All Movies</button></a>
      </div>
    </div>
    <% } else { %>
    <div class="rec-card">
      <div class="no-rec">No other movies found in the genre "<%= watchedMovieGenre %>"</div>
      <div class="actions">
        <a href="user.jsp"><button type="button" class="btn-secondary">Back to All Movies</button></a>
      </div>
    </div>
    <% } %>
  </div>

  <div class="bottom">
    <a href="dashboard.jsp"><button class="btn-secondary">Dashboard</button></a>
  </div>
</div>
</body>
</html>

<%
}
catch(Exception e)
{
    out.println("<h3 style='color:#e5484d;text-align:center;'>Error: " + e.getMessage() + "</h3>");
}
finally
{
    try {
        if(rs != null) rs.close();
        if(ps != null) ps.close();
        if(con != null) con.close();
    } catch(Exception e) {}
}
%>
