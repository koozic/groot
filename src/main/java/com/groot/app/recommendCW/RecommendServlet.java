package com.groot.app.recommendCW;

import com.google.gson.Gson;
import com.groot.app.user.UserDTO;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.List;
import java.util.Map;

/**
 * 영양제 분석 Controller
 *
 * [GET]  /recommend         → 추천 페이지 화면 반환
 * [POST] /recommend/analyze → AJAX 분석 요청 처리 (비회원/회원 모두 가능)
 *
 * 비회원: 분석 결과만 보여줌 (저장 X)
 * 회원:   분석 결과 보여줌 + 히스토리 저장 (추후 구현)
 */
@WebServlet(urlPatterns = {"/reco", "/recommend/analyze"})
public class RecommendServlet extends HttpServlet {

    private final Gson gson = new Gson();

    // ── GET: 추천 페이지 화면 ─────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("content",   "views/recommend.jsp");
        req.setAttribute("activeTab", "recommend");
        req.getRequestDispatcher("index.jsp").forward(req, resp);
    }

    // ── POST: AJAX 분석 요청 ──────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            // 1. 요청 body 읽기
            StringBuilder sb = new StringBuilder();
            String line;
            try (BufferedReader br = req.getReader()) {
                while ((line = br.readLine()) != null) sb.append(line);
            }

            Map<String, Object> body = gson.fromJson(sb.toString(), Map.class);
            List<String> supplements = (List<String>) body.get("supplements");
            String       type        = (String) body.get("type"); // my | deficiency | compatibility

            if (supplements == null || supplements.isEmpty()) {
                out.print(gson.toJson(Map.of("success", false, "message", "영양제를 선택해주세요")));
                return;
            }

            // 2. 분석기 선택 (다형성)
            SupplementAnalyzer analyzer = switch (type != null ? type : "my") {
                case "deficiency"    -> new DeficiencyAnalyzer();
                case "compatibility" -> new CompatibilityAnalyzer();
                default              -> new MySupplementAnalyzer();
            };

            // 3. 분석 실행 (비회원/회원 동일)
            AnalysisResult result = analyzer.analyze(supplements);

            // 4. 로그인 여부 확인
            HttpSession session  = req.getSession(false);
            UserDTO loginUser = (session != null)
                    ? (UserDTO) session.getAttribute("loginUser")
                    : null;

            // 5. 회원이면 히스토리 저장 (추후 DAO 연결)
            if (loginUser != null) {
                // TODO: RecommendDAO.saveHistory(loginUser.getUserId(), supplements, result);
                result.setMessage("분석 완료! 히스토리에 저장됐어요 ✅");
            } else {
                result.setMessage("분석 완료! 로그인하면 히스토리를 저장할 수 있어요");
            }

            out.print(gson.toJson(result));

        } catch (Exception e) {
            out.print(gson.toJson(Map.of("success", false, "message", "서버 오류가 발생했어요")));
            e.printStackTrace();
        }
    }
}
