<%@ page import="java.sql.*" %>

<%
try
{
    String username = (String)session.getAttribute("username");
    
    if(username != null)
    {
        Class.forName("com.mysql.cj.jdbc.Driver");

        String dbHost = "localhost";
        String dbPort = "3306";
        String dbName = "moviedb";
        String dbUser = "root";
        String dbPass = "";
        String dbUrl  = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName;
        
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