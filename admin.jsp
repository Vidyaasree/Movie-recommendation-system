<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
if(session.getAttribute("login") == null)
{
    response.sendRedirect("login.jsp");
    return;
}

Connection con = null;
PreparedStatement ps = null;
Statement st = null;
ResultSet rs = null;
String message = "";

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

    if("POST".equalsIgnoreCase(request.getMethod()))
    {
        String movie  = request.getParameter("movie");
        String genre  = request.getParameter("genre");
        String rating = request.getParameter("rating");

        if(movie != null && !movie.trim().isEmpty() &&
           genre != null && !genre.trim().isEmpty() &&
           rating != null && !rating.trim().isEmpty())
        {
            try {
                double ratingVal = Double.parseDouble(rating);
                if(ratingVal < 1 || ratingVal > 5) {
                    message = "Rating must be between 1 and 5";
                } else {
                    ps = con.prepareStatement(
                        "INSERT INTO movies(movie_name, genre, rating) VALUES(?,?,?)"
                    );
                    ps.setString(1, movie.trim());
                    ps.setString(2, genre.trim());
                    ps.setDouble(3, ratingVal);
                    int rowsAffected = ps.executeUpdate();
                    ps.close();

                    if(rowsAffected > 0) {
                        message = "Movie Added Successfully!";
                    } else {
                        message = "Failed to add movie. Please try again.";
                    }
                }
            } catch(NumberFormatException e) {
                message = "Invalid rating format. Please enter a number.";
            } catch(SQLException e) {
                message = "Database error: " + e.getMessage();
            }
        } else {
            message = "All fields are required";
        }
    }

    st = con.createStatement();
    rs = st.executeQuery("SELECT * FROM movies ORDER BY rating DESC");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Panel</title>
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
  --success:#3fb950;
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
.form-box{
background:var(--panel);
padding:28px;
border-radius:14px;
border:1px solid var(--border);
margin-bottom:40px;
}
.form-box h2{
color:var(--text);
margin-bottom:20px;
font-size:20px;
}
.form-row{
display:flex;
gap:20px;
flex-wrap:wrap;
}
.form-group{
flex:1;
min-width:160px;
}
label{
display:block;
color:var(--muted);
margin-bottom:8px;
font-weight:600;
font-size:14px;
}
input{
width:100%;
padding:13px;
border:1px solid var(--border);
border-radius:8px;
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
.add-btn{
padding:13px 32px;
background:var(--accent);
color:white;
border:none;
border-radius:8px;
cursor:pointer;
font-size:15px;
font-weight:600;
margin-top:22px;
transition:.2s;
}
.add-btn:hover{
background:var(--accent-hover);
}
.success{
margin-top:15px;
color:var(--success);
font-weight:bold;
font-size:15px;
}
.error-msg{
margin-top:15px;
color:var(--danger);
font-weight:bold;
font-size:15px;
}
.section-title{
color:var(--text);
font-size:22px;
margin-bottom:20px;
padding-bottom:10px;
border-bottom:1px solid var(--border);
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
margin:8px;
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
        <a href="admin.jsp"><button class="active">Admin</button></a>
        <a href="user.jsp"><button>User Panel</button></a>
      </div>
    </div>
    <div style="display:flex;align-items:center;gap:15px;">
      <span class="nav-user"><%= session.getAttribute("username") %></span>
      <a href="logout.jsp"><button class="logout-btn">Logout</button></a>
    </div>
  </div>

  <div class="header">
    <h1>Admin Panel</h1>
    <p>Manage Movie Collection</p>
  </div>

  <div class="form-box">
    <h2>Add New Movie</h2>
    <form method="post">
      <div class="form-row">
        <div class="form-group">
          <label>Movie Name</label>
          <input type="text" name="movie" placeholder="e.g. Inception" required>
        </div>
        <div class="form-group">
          <label>Genre</label>
          <input type="text" name="genre" placeholder="e.g. Sci-Fi" required>
        </div>
        <div class="form-group">
          <label>Rating (1 - 5)</label>
          <input type="number" step="0.1" min="1" max="5" name="rating" placeholder="e.g. 4.5" required>
        </div>
      </div>
      <button type="submit" class="add-btn">+ Add Movie</button>
    </form>
    <% if(!message.equals("")){
        boolean isError = message.contains("Invalid") || message.contains("required") || message.contains("between") || message.contains("Failed") || message.contains("Database error");
    %>
      <p class="<%= isError ? "error-msg" : "success" %>"><%= message %></p>
    <% } %>
  </div>

  <h2 class="section-title">Movie Library</h2>
  <div class="table-wrap">
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Movie Name</th>
          <th>Genre</th>
          <th>Rating</th>
        </tr>
      </thead>
      <tbody>
      <%
        if(rs != null) {
            boolean hasMovies = false;
            while(rs.next())
            {
                hasMovies = true;
                int mId        = rs.getInt("id");
                String mName   = rs.getString("movie_name");
                String mGenre  = rs.getString("genre");
                double mRating = rs.getDouble("rating");

                int fullStars  = (int) mRating;
                boolean hasHalf = (mRating - fullStars) >= 0.4;
                int emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);
      %>
        <tr>
          <td>#<%= mId %></td>
          <td><%= mName %></td>
          <td><span class="genre-tag"><%= mGenre %></span></td>
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
              <span class="rating-num"><%= mRating %>/5</span>
            </div>
          </td>
        </tr>
      <%
            }
            if(!hasMovies) {
      %>
        <tr class="empty-row"><td colspan="4">No movies available. Add your first movie above!</td></tr>
      <%
            }
        }
      %>
      </tbody>
    </table>
  </div>

  <div class="bottom">
    <a href="dashboard.jsp"><button>Dashboard</button></a>
    <a href="user.jsp"><button>User Panel</button></a>
    <a href="logout.jsp"><button style="background:var(--danger);">Logout</button></a>
  </div>
</div>
</body>
</html>

<%
    if(rs != null) rs.close();
    if(st != null) st.close();
    if(con != null) con.close();
}
catch(Exception e)
{
    out.println("<h3 style='color:#e5484d;text-align:center;'>Error: " + e.getMessage() + "</h3>");
}
%>
