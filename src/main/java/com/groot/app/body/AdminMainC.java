import com.groot.app.body.AdminDAO;
import com.groot.app.body.BodyDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

// AdminMainC.java - 관리자 메인 목록
@WebServlet("/admin/main")
public class AdminMainC extends HttpServlet {
    private final AdminDAO dao = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect("../login_view");
            return;
        }
        try {
            List<BodyDTO> list = dao.getAllSupplements();
            request.setAttribute("suppList", list);
            request.getRequestDispatcher("/body/admin_main.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendError(500, e.getMessage());
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    }
}