<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
if(session.getAttribute("login") == null)
{
    response.sendRedirect("login.jsp");
    return;
}

List<Map<String, Object>> allMovies = new ArrayList<>();

Connection con = null;
Statement st = null;
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

    st = con.createStatement();
    rs = st.executeQuery("SELECT * FROM movies ORDER BY movie_name");

    while(rs.next())
    {
        Map<String, Object> movie = new HashMap<>();
        movie.put("movie_name", rs.getString("movie_name"));
        movie.put("genre", rs.getString("genre"));
        movie.put("rating", rs.getDouble("rating"));
        allMovies.add(movie);
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Panel</title>
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
max-width:1200px;
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
.nav-left{
display:flex;
align-items:center;
gap:20px;
}
.nav-logo{
color:var(--text);
font-size:20px;
font-weight:bold;
letter-spacing:1px;
}
.nav-links{
display:flex;
gap:12px;
}
.nav-links a{
text-decoration:none;
}
.nav-links button{
padding:10px 20px;
background:transparent;
border:1px solid var(--border);
border-radius:8px;
color:var(--text);
cursor:pointer;
transition:.2s;
font-size:14px;
font-weight:500;
}
.nav-links button:hover{
border-color:var(--accent);
}
.nav-links .active{
background:var(--accent);
border-color:var(--accent);
}
.nav-links .active:hover{
background:var(--accent-hover);
}
.nav-user{
color:var(--muted);
font-size:14px;
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
.header{
text-align:center;
color:var(--text);
margin-bottom:35px;
}
.header h1{
font-size:32px;
margin-bottom:8px;
}
.header p{
color:var(--muted);
}
.table-wrap{
background:var(--panel);
border:1px solid var(--border);
border-radius:14px;
overflow:hidden;
margin-bottom:40px;
}
table{
width:100%;
border-collapse:collapse;
}
thead th{
text-align:left;
padding:16px 20px;
background:var(--panel-2);
color:var(--muted);
font-size:13px;
text-transform:uppercase;
letter-spacing:.5px;
border-bottom:1px solid var(--border);
}
tbody td{
padding:16px 20px;
color:var(--text);
font-size:15px;
border-bottom:1px solid var(--border);
vertical-align:middle;
}
tbody tr:last-child td{
border-bottom:none;
}
tbody tr:hover{
background:var(--panel-2);
}
.genre-tag{
display:inline-block;
padding:4px 12px;
border-radius:20px;
font-size:12px;
font-weight:600;
background:var(--panel-2);
color:var(--muted);
border:1px solid var(--border);
}
.stars-row{
display:flex;
align-items:center;
gap:8px;
}
.stars{
display:flex;
gap:2px;
}
.star{ font-size:15px; }
.star.filled { color:var(--gold); }
.star.half   { color:var(--gold); opacity:.6; }
.star.empty  { color:#3a3a40; }
.rating-num{
font-size:13px;
color:var(--muted);
}
.watch-btn{
padding:9px 18px;
background:var(--accent);
color:white;
border:none;
border-radius:8px;
cursor:pointer;
font-size:13px;
font-weight:600;
transition:.2s;
}
.watch-btn:hover{
background:var(--accent-hover);
}
.empty-row td{
text-align:center;
color:var(--muted);
padding:40px;
font-size:16px;
}
.bottom{
text-align:center;
margin-top:20px;
}
.bottom a{
text-decoration:none;
margin:10px;
}
.bottom button{
padding:13px 28px;
background:var(--accent);
color:white;
border:none;
border-radius:8px;
cursor:pointer;
font-size:15px;
transition:.2s;
}
.bottom button:hover{
background:var(--accent-hover);
}
</style>
</head>
<body>
<div class="container">

  <div class="navbar">
    <div class="nav-left">
      <span class="nav-logo">MovieApp</span>
      <div class="nav-links">
        <a href="dashboard.jsp"><button>Dashboard</button></a>
        <a href="admin.jsp"><button>Admin</button></a>
        <a href="user.jsp"><button class="active">User Panel</button></a>
      </div>
    </div>
    <div style="display:flex;align-items:center;gap:15px;">
      <span class="nav-user"><%= session.getAttribute("username") %></span>
      <a href="logout.jsp"><button class="logout-btn">Logout</button></a>
    </div>
  </div>

  <div class="header">
    <h1>Movie Recommendation System</h1>
    <p>Select a movie to watch and get a recommendation in the same genre</p>
  </div>

  <div class="table-wrap">
    <table>
      <thead>
        <tr>
          <th>Movie Name</th>
          <th>Genre</th>
          <th>Rating</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
      <%
        if(!allMovies.isEmpty())
        {
            for(Map<String, Object> movie : allMovies)
            {
                String movieName = (String) movie.get("movie_name");
                String genre = (String) movie.get("genre");
                double rating = (Double) movie.get("rating");

                int fullStars = (int) rating;
                boolean hasHalf = (rating - fullStars) >= 0.4;
                int emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);
      %>
        <tr>
          <td><%= movieName %></td>
          <td><span class="genre-tag"><%= genre %></span></td>
          <td>
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
              <span class="rating-num"><%= rating %>/5</span>
            </div>
          </td>
          <td>
            <form method="post" action="recommend.jsp">
              <input type="hidden" name="watchMovie" value="<%= movieName %>">
              <button type="submit" class="watch-btn">Watch Movie</button>
            </form>
          </td>
        </tr>
      <%
            }
        }
        else
        {
      %>
        <tr class="empty-row"><td colspan="4">No movies available. Please check back later.</td></tr>
      <%
        }
      %>
      </tbody>
    </table>
  </div>

  <div class="bottom">
    <a href="dashboard.jsp"><button>Dashboard</button></a>
    <a href="admin.jsp"><button>Admin Panel</button></a>
    <a href="logout.jsp"><button style="background:var(--danger);">Logout</button></a>
  </div>
</div>
</body>
</html>

<%
    if(rs != null) rs.close();
    if(st != null) st.close();
}
catch(Exception e)
{
    out.println("<h3 style='color:#e5484d;text-align:center;'>Error: " + e.getMessage() + "</h3>");
}
finally
{
    try { if(con != null) con.close(); } catch(Exception e) {}
}
%>
