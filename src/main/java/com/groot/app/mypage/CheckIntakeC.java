import com.groot.app.mypage.MyPageDAO;
import com.groot.app.user.UserDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/mypage/check-intake")
public class CheckIntakeC extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        UserDTO user = (UserDTO) request.getSession().getAttribute("loginUser");
        int productId = Integer.parseInt(request.getParameter("productId"));
        boolean isTaken = Boolean.parseBoolean(request.getParameter("isTaken"));

        boolean success = MyPageDAO.MDAO.updateIntakeStatus(user.getUser_id(), productId, isTaken);
        response.getWriter().print(success ? "success" : "fail");
    }
}