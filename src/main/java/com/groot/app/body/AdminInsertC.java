import com.groot.app.body.AdminDAO;
import com.groot.app.body.BodyDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// AdminInsertC.java - 영양소 등록 처리
@WebServlet("/admin/insert")
public class AdminInsertC extends HttpServlet {
    private final AdminDAO dao = new AdminDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        try {
            BodyDTO dto = buildDto(request);
            dao.insertSupplement(dto);

            String bodyIdParam = request.getParameter("bodyId");
            if (bodyIdParam != null && !bodyIdParam.isEmpty()) {
                dao.linkBodySupplement(Integer.parseInt(bodyIdParam), dto.getSupplementId());
            }
            response.sendRedirect("../admin/main"); // 등록 후 목록으로
        } catch (Exception e) {
            response.sendError(500, e.getMessage());
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    }

    private BodyDTO buildDto(HttpServletRequest request) {
        BodyDTO dto = new BodyDTO();
        dto.setSupplementName(request.getParameter("supplementName"));
        dto.setSupplementEfficacy(request.getParameter("supplementEfficacy"));
        dto.setSupplementDosage(request.getParameter("supplementDosage"));
        dto.setSupplementTiming(request.getParameter("supplementTiming"));
        dto.setSupplementCaution(request.getParameter("supplementCaution"));
        dto.setSupplementImagePath(request.getParameter("supplementImagePath"));
        return dto;
    }
}