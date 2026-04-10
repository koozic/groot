import com.groot.app.body.AdminDAO;
import com.groot.app.body.BodyDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// AdminFormC.java - 등록/수정 폼
@WebServlet("/admin/form")
public class AdminFormC extends HttpServlet {
    private final AdminDAO dao = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect("../login_view");
            return;
        }
        String suppIdParam = request.getParameter("suppId");
        try {
            if (suppIdParam != null && !suppIdParam.isEmpty()) {
                BodyDTO dto = dao.getSupplementById(Integer.parseInt(suppIdParam));
                request.setAttribute("supp", dto);
            }
            request.getRequestDispatcher("/body/admin_form.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendError(500, e.getMessage());
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    }
}