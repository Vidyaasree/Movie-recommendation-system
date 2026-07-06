<%@ page import="java.sql.*" %>

<%
try
{
    String username = (String)session.getAttribute("username");

    if(username != null)
    {
        Class.forName("com.mysql.cj.jdbc.Driver");

        String dbHost = System.getenv("MYSQL_HOST");
        String dbPort = System.getenv("MYSQL_PORT");
        String dbName = System.getenv("MYSQL_DB");
        String dbUser = System.getenv("MYSQL_USER");
        String dbPass = System.getenv("MYSQL_PASSWORD");
        String dbUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "?sslMode=REQUIRED&useSSL=true&serverTimezone=UTC";

        Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        PreparedStatement ps = con.prepareStatement(
            "DELETE FROM watch_history WHERE username = ?"
        );
        ps.setString(1, username);
        ps.executeUpdate();

        ps.close();
        con.close();
    }
}
catch(Exception e)
{
    e.printStackTrace();
}

session.invalidate();
response.sendRedirect("login.jsp");
%>
