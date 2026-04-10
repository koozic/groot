import com.groot.app.body.AdminDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// AdminDeleteC.java - 영양소 삭제 처리
@WebServlet("/admin/delete")
public class AdminDeleteC extends HttpServlet {
    private final AdminDAO dao = new AdminDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        String suppIdStr = request.getParameter("suppId");
        if (suppIdStr == null || suppIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "삭제할 ID가 없습니다.");
            return;
        }
        try {
            int suppId = Integer.parseInt(suppIdStr);
            dao.deleteBodySupplementLinks(suppId);
            dao.deleteSupplementLikes(suppId);
            dao.deleteSupplement(suppId);
            response.sendRedirect("../admin/main");
        } catch (Exception e) {
            response.sendError(500, e.getMessage());
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    }
}