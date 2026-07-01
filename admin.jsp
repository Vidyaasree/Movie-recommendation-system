<%@ page import="java.sql.*" %>

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

    // Database connection parameters - UPDATED FOR AIVEN
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

    // Always fetch movies after any POST operation to show updated list
    st = con.createStatement();
    rs = st.executeQuery("SELECT * FROM movies ORDER BY rating DESC");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Panel</title>
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
.form-box{
background:rgba(255,255,255,.08);
backdrop-filter:blur(15px);
padding:30px;
border-radius:20px;
box-shadow:0 15px 30px rgba(0,0,0,.4);
margin-bottom:40px;
}
.form-box h2{
color:white;
margin-bottom:20px;
font-size:22px;
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
color:#CBD5E1;
margin-bottom:8px;
font-weight:600;
font-size:14px;
}
input{
width:100%;
padding:13px;
border:none;
border-radius:10px;
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
.add-btn{
padding:13px 35px;
background:#2563EB;
color:white;
border:none;
border-radius:10px;
cursor:pointer;
font-size:15px;
font-weight:600;
margin-top:22px;
transition:.3s;
}
.add-btn:hover{
background:#1D4ED8;
transform:translateY(-2px);
box-shadow:0 8px 20px rgba(37,99,235,.4);
}
.success{
margin-top:15px;
color:#4ADE80;
font-weight:bold;
font-size:15px;
}
.error-msg{
margin-top:15px;
color:#F87171;
font-weight:bold;
font-size:15px;
}
.section-title{
color:white;
font-size:24px;
margin-bottom:25px;
padding-bottom:10px;
border-bottom:1px solid rgba(255,255,255,.1);
}
.movies-grid{
display:grid;
grid-template-columns:repeat(auto-fill, minmax(200px, 1fr));
gap:24px;
margin-bottom:40px;
}
.movie-card{
background:rgba(255,255,255,.08);
backdrop-filter:blur(15px);
border-radius:16px;
border:1px solid rgba(255,255,255,.1);
overflow:hidden;
box-shadow:0 10px 25px rgba(0,0,0,.4);
transition:.3s;
}
.movie-card:hover{
transform:translateY(-6px);
box-shadow:0 18px 35px rgba(37,99,235,.3);
border-color:rgba(56,189,248,.4);
}
.poster{
height:140px;
display:flex;
flex-direction:column;
align-items:center;
justify-content:center;
font-size:52px;
position:relative;
}
.poster-label{
position:absolute;
bottom:8px;
right:10px;
font-size:11px;
font-weight:700;
padding:3px 10px;
border-radius:20px;
letter-spacing:.5px;
}
.genre-action    { background:linear-gradient(135deg,#7F1D1D,#DC2626); }
.genre-drama     { background:linear-gradient(135deg,#1E3A5F,#2563EB); }
.genre-comedy    { background:linear-gradient(135deg,#78350F,#F59E0B); }
.genre-scifi     { background:linear-gradient(135deg,#134E4A,#0D9488); }
.genre-horror    { background:linear-gradient(135deg,#1F0A2E,#7C3AED); }
.genre-romance   { background:linear-gradient(135deg,#831843,#EC4899); }
.genre-thriller  { background:linear-gradient(135deg,#1C1917,#57534E); }
.genre-animation { background:linear-gradient(135deg,#14532D,#16A34A); }
.genre-default   { background:linear-gradient(135deg,#1E293B,#334155); }
.card-body{
padding:14px 16px 16px;
}
.card-body h3{
color:white;
font-size:15px;
margin-bottom:6px;
white-space:nowrap;
overflow:hidden;
text-overflow:ellipsis;
}
.card-body .genre-tag{
font-size:12px;
color:#94A3B8;
margin-bottom:10px;
}
.stars-row{
display:flex;
align-items:center;
gap:6px;
}
.stars{
display:flex;
gap:2px;
}
.star{ font-size:15px; }
.star.filled { color:#FBBF24; }
.star.half   { color:#FBBF24; opacity:.6; }
.star.empty  { color:#475569; }
.rating-num{
font-size:13px;
color:#94A3B8;
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
        <a href="admin.jsp"><button class="active">⚙️ Admin</button></a>
        <a href="user.jsp"><button>🎥 User Panel</button></a>
      </div>
    </div>
    <div style="display:flex;align-items:center;gap:15px;">
      <span class="nav-user">👤 <%= session.getAttribute("username") %></span>
      <a href="logout.jsp"><button class="logout-btn">🚪 Logout</button></a>
    </div>
  </div>

  <div class="header">
    <h1>&#9881; Admin Panel</h1>
    <p>Manage Movie Collection</p>
  </div>
  
  <div class="form-box">
    <h2>&#127916; Add New Movie</h2>
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
      <button type="submit" class="add-btn">&#43; Add Movie</button>
    </form>
    <% if(!message.equals("")){ 
        boolean isError = message.contains("Invalid") || message.contains("required") || message.contains("between") || message.contains("Failed") || message.contains("Database error");
    %>
      <p class="<%= isError ? "error-msg" : "success" %>"><%= message %></p>
    <% } %>
  </div>
  
  <h2 class="section-title">&#127902; Movie Library</h2>
  <div class="movies-grid">
  <%
    if(rs != null) {
        boolean hasMovies = false;
        while(rs.next())
        {
            hasMovies = true;
            String mName   = rs.getString("movie_name");
            String mGenre  = rs.getString("genre");
            double mRating = rs.getDouble("rating");

            String emoji = "&#127916;";
            String genreClass = "genre-default";
            String genreLow = mGenre.toLowerCase();

            if(genreLow.contains("action"))         { emoji="&#128293;"; genreClass="genre-action"; }
            else if(genreLow.contains("drama"))      { emoji="&#127914;"; genreClass="genre-drama"; }
            else if(genreLow.contains("comedy"))     { emoji="&#128514;"; genreClass="genre-comedy"; }
            else if(genreLow.contains("sci"))        { emoji="&#128640;"; genreClass="genre-scifi"; }
            else if(genreLow.contains("horror"))     { emoji="&#128123;"; genreClass="genre-horror"; }
            else if(genreLow.contains("romance"))    { emoji="&#10084;";  genreClass="genre-romance"; }
            else if(genreLow.contains("thriller"))   { emoji="&#128269;"; genreClass="genre-thriller"; }
            else if(genreLow.contains("animation"))  { emoji="&#127752;"; genreClass="genre-animation"; }

            int fullStars  = (int) mRating;
            boolean hasHalf = (mRating - fullStars) >= 0.4;
            int emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);
  %>
    <div class="movie-card">
      <div class="poster <%= genreClass %>">
        <%= emoji %>
        <span class="poster-label" style="background:rgba(0,0,0,.45);color:white;">
          <%= mGenre %>
        </span>
      </div>
      <div class="card-body">
        <h3 title="<%= mName %>"><%= mName %></h3>
        <div class="genre-tag">ID: <%= rs.getInt("id") %></div>
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
      </div>
    </div>
  <%
        }
        if(!hasMovies) {
  %>
    <div style="grid-column:1/-1;text-align:center;color:#94A3B8;padding:40px;font-size:18px;">
      No movies available. Add your first movie above!
    </div>
  <%
        }
    }
  %>
  </div>
  
  <div class="bottom">
    <a href="dashboard.jsp"><button>&#127968; Dashboard</button></a>
    <a href="user.jsp"><button>&#127902; User Panel</button></a>
    <a href="logout.jsp"><button style="background:#DC2626;">&#128682; Logout</button></a>
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
    out.println("<h3 style='color:red;text-align:center;'>Error: " + e.getMessage() + "</h3>");
}
%>