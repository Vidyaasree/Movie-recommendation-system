<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
if(session.getAttribute("login") == null)
{
    response.sendRedirect("login.jsp");
    return;
}

String watchMessage = "";
List<Map<String, Object>> recommendations = new ArrayList<>();
String watchedMovieGenre = "";

Connection con = null;
PreparedStatement ps = null;
Statement st = null;
ResultSet rs = null;

try
{
    Class.forName("com.mysql.cj.jdbc.Driver");

    // Database connection parameters - UPDATED FOR AIVEN
    String dbHost = System.getenv("MYSQL_HOST");
    String dbPort = System.getenv("MYSQL_PORT");
    String dbName = System.getenv("MYSQL_DB");
    String dbUser = System.getenv("MYSQL_USER");
    String dbPass = System.getenv("MYSQL_PASSWORD");
    String dbUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "?sslMode=REQUIRED&useSSL=true&serverTimezone=UTC";
    
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

        // Get the genre of the watched movie
        ps = con.prepareStatement(
            "SELECT genre FROM movies WHERE movie_name=?"
        );
        ps.setString(1, watchMovie.trim());
        ResultSet r1 = ps.executeQuery();

        if(r1.next())
        {
            watchedMovieGenre = r1.getString("genre");
        }
        r1.close();
        ps.close();

        // Get ALL movies of the same genre (excluding the watched one), sorted by rating DESC
        if(watchedMovieGenre != null && !watchedMovieGenre.isEmpty())
        {
            ps = con.prepareStatement(
                "SELECT * FROM movies WHERE genre=? AND movie_name<>? ORDER BY rating DESC"
            );
            ps.setString(1, watchedMovieGenre);
            ps.setString(2, watchMovie.trim());
            ResultSet r2 = ps.executeQuery();

            while(r2.next())
            {
                Map<String, Object> movie = new HashMap<>();
                movie.put("movie_name", r2.getString("movie_name"));
                movie.put("genre", r2.getString("genre"));
                movie.put("rating", r2.getDouble("rating"));
                recommendations.add(movie);
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

/* Navigation Bar Styles */
.navbar{
display:flex;
justify-content:space-between;
align-items:center;
background:rgba(255,255,255,.08);
backdrop-filter:blur(15px);
padding:15px 30px;
border-radius:15px;
margin-bottom:35px;
border:1px solid rgba(255,255,255,.12);
}
.nav-left{
display:flex;
align-items:center;
gap:20px;
}
.nav-logo{
color:white;
font-size:22px;
font-weight:bold;
letter-spacing:1px;
}
.nav-links{
display:flex;
gap:15px;
}
.nav-links a{
text-decoration:none;
}
.nav-links button{
padding:10px 22px;
background:transparent;
border:1px solid rgba(255,255,255,.2);
border-radius:10px;
color:white;
cursor:pointer;
transition:.3s;
font-size:14px;
font-weight:500;
}
.nav-links button:hover{
background:rgba(255,255,255,.1);
transform:translateY(-2px);
}
.nav-links .active{
background:#2563EB;
border-color:#2563EB;
}
.nav-links .active:hover{
background:#1D4ED8;
}
.nav-user{
color:#94A3B8;
font-size:14px;
}
.logout-btn{
padding:10px 22px;
background:#EF4444;
border:none;
border-radius:10px;
color:white;
cursor:pointer;
transition:.3s;
font-size:14px;
font-weight:500;
}
.logout-btn:hover{
background:#DC2626;
transform:translateY(-2px);
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
font-size:18px;
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
font-size:20px;
}
.card p{
margin:8px 0;
color:#E2E8F0;
}
.stars-row{
display:flex;
align-items:center;
gap:8px;
margin:8px 0;
}
.stars{
display:flex;
gap:2px;
}
.star{ font-size:16px; }
.star.filled { color:#FBBF24; }
.star.half   { color:#FBBF24; opacity:.6; }
.star.empty  { color:#475569; }
.rating-num{
font-size:14px;
color:#94A3B8;
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
font-size:14px;
font-weight:500;
}
button:hover{
background:#1D4ED8;
transform:translateY(-2px);
}

/* Recommendations Section */
.recommendations-section{
margin-top:40px;
background:rgba(255, 248, 220, 0.08);
backdrop-filter:blur(10px);
padding:25px;
border-radius:15px;
border:1px solid rgba(255,215,0,0.2);
}
.recommendations-section h2{
color:gold;
margin-bottom:20px;
font-size:26px;
text-align:center;
}
.recommendations-section h2 span{
font-size:20px;
}
.recommendations-grid{
display:grid;
grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
gap:20px;
}
.rec-card{
background:rgba(255,255,255,.1);
padding:18px;
border-radius:12px;
border-left:4px solid gold;
transition:.3s;
}
.rec-card:hover{
transform:translateY(-3px);
background:rgba(255,255,255,.15);
}
.rec-card h3{
color:white;
font-size:17px;
margin-bottom:6px;
}
.rec-card p{
color:#CBD5E1;
font-size:14px;
margin:4px 0;
}
.rec-card .stars-row{
margin:4px 0;
}
.rec-card .rating-num{
font-size:13px;
}
.no-recommendations{
text-align:center;
color:#94A3B8;
padding:20px;
font-size:16px;
}
.bottom{
text-align:center;
margin-top:30px;
}
.bottom a{
text-decoration:none;
margin:10px;
}
.bottom button{
padding:13px 28px;
background:#2563EB;
color:white;
border:none;
border-radius:10px;
cursor:pointer;
font-size:15px;
transition:.3s;
}
.bottom button:hover{
background:#1D4ED8;
transform:translateY(-2px);
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
  
  <!-- Navigation Bar -->
  <div class="navbar">
    <div class="nav-left">
      <span class="nav-logo">🎬 MovieApp</span>
      <div class="nav-links">
        <a href="dashboard.jsp"><button>🏠 Dashboard</button></a>
        <a href="admin.jsp"><button>⚙️ Admin</button></a>
        <a href="user.jsp"><button class="active">🎥 User Panel</button></a>
      </div>
    </div>
    <div style="display:flex;align-items:center;gap:15px;">
      <span class="nav-user">👤 <%= session.getAttribute("username") %></span>
      <a href="logout.jsp"><button class="logout-btn">🚪 Logout</button></a>
    </div>
  </div>

  <div class="header">
    <h1>🎥 Movie Recommendation System</h1>
    <p>Select a movie to watch and get recommendations</p>
  </div>
  
  <% if(!watchMessage.isEmpty()){ %>
    <div class="watch-msg">✅ <%= watchMessage %></div>
  <% } %>
  
  <div class="movies">
  <%
    if(rs != null && rs.next())
    {
        do {
            double rating = rs.getDouble("rating");
            int fullStars = (int) rating;
            boolean hasHalf = (rating - fullStars) >= 0.4;
            int emptyStars = 10 - fullStars - (hasHalf ? 1 : 0);
  %>
    <div class="card">
      <h2><%= rs.getString("movie_name") %></h2>
      <p><b>Genre:</b> <%= rs.getString("genre") %></p>
      <div class="stars-row">
        <div class="stars">
          <% for(int i=0;i<fullStars;i++){ %>
            <span class="star filled">★</span>
          <% } %>
          <% if(hasHalf){ %>
            <span class="star half">★</span>
          <% } %>
          <% for(int i=0;i<emptyStars;i++){ %>
            <span class="star empty">★</span>
          <% } %>
        </div>
        <span class="rating-num"><%= rating %>/10</span>
      </div>
      <form method="post">
        <input type="hidden" name="watchMovie" value="<%= rs.getString("movie_name") %>">
        <button type="submit">▶ Watch Movie</button>
      </form>
    </div>
  <%
        } while(rs.next());
    }
    else
    {
  %>
    <div class="no-movies">🎬 No movies available. Please check back later.</div>
  <%
    }
  %>
  </div>

  <!-- Recommendations Section -->
  <% if(!recommendations.isEmpty()) { %>
    <div class="recommendations-section">
      <h2>🎯 <span>Movies in Genre:</span> <%= watchedMovieGenre %></h2>
      <p style="text-align:center;color:#94A3B8;margin-bottom:20px;">Top rated movies you might like!</p>
      <div class="recommendations-grid">
      <%
        for(Map<String, Object> movie : recommendations) {
            String movieName = (String) movie.get("movie_name");
            String genre = (String) movie.get("genre");
            double rating = (Double) movie.get("rating");
            
            int fullStars = (int) rating;
            boolean hasHalf = (rating - fullStars) >= 0.4;
            int emptyStars = 10 - fullStars - (hasHalf ? 1 : 0);
      %>
        <div class="rec-card">
          <h3>🎬 <%= movieName %></h3>
          <p><b>Genre:</b> <%= genre %></p>
          <div class="stars-row">
            <div class="stars">
              <% for(int i=0;i<fullStars;i++){ %>
                <span class="star filled">★</span>
              <% } %>
              <% if(hasHalf){ %>
                <span class="star half">★</span>
              <% } %>
              <% for(int i=0;i<emptyStars;i++){ %>
                <span class="star empty">★</span>
              <% } %>
            </div>
            <span class="rating-num"><%= rating %>/10</span>
          </div>
          <form method="post" style="margin-top:10px;">
            <input type="hidden" name="watchMovie" value="<%= movieName %>">
            <button type="submit" style="padding:6px 15px;font-size:13px;">▶ Watch</button>
          </form>
        </div>
      <%
        }
      %>
      </div>
    </div>
  <% } else if(watchMessage != null && !watchMessage.isEmpty() && !recommendations.isEmpty()) { %>
    <div class="recommendations-section">
      <div class="no-recommendations">
        😅 No other movies found in the genre "<%= watchedMovieGenre %>"
      </div>
    </div>
  <% } %>

  <div class="bottom">
    <a href="dashboard.jsp"><button>🏠 Dashboard</button></a>
    <a href="admin.jsp"><button>⚙️ Admin Panel</button></a>
    <a href="logout.jsp"><button style="background:#DC2626;">🚪 Logout</button></a>
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